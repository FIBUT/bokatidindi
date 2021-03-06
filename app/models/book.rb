# frozen_string_literal: true

class Book < ApplicationRecord
  COVER_IMAGE_VARIANTS  = [266, 364, 550, 768, 992, 1200, 1386, 1600].freeze
  IMAGE_QUALITY         = 80
  IMAGE_FILE_SUFFIX     = '.jpg'
  IMAGE_FILE_TYPE       = 'image/jpeg'

  HYPENATION_SEPARATOR    = '|'
  HYPENATION_SYMBOL       = "\u00AD"
  HYPENATION_ALTERNATIVES = [
    '|', '&shy;', "\u00AD", '&#xAD;', '&#173;', '&shy;'
  ].freeze

  SEARCH_COLUMNS = %i[
    source_id pre_title title post_title description long_description
  ].freeze
  AUTHORS_SEARCH_COLUMMNS   = %i[firstname lastname].freeze
  CATEGORIES_SEARCH_COLUMNS = %i[origin_name slug].freeze

  include ActionView::Helpers::UrlHelper
  include PgSearch::Model

  multisearchable against: %i[
    pre_title title_noshy post_title description long_description
  ]

  pg_search_scope :search,
                  against: SEARCH_COLUMNS, associated_against: {
                    authors: AUTHORS_SEARCH_COLUMMNS,
                    categories: CATEGORIES_SEARCH_COLUMNS,
                    publisher: :name
                  }

  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors
  has_many :book_categories, dependent: :destroy
  has_many :categories, through: :book_categories
  has_many :author_types, through: :book_authors
  has_many :book_binding_types, dependent: :destroy
  has_many :binding_types, through: :book_binding_types
  has_many :book_editions, dependent: :restrict_with_error
  has_many :editions, through: :book_editions
  belongs_to :publisher

  has_one_attached :cover_image, dependent: :destroy

  paginates_per 18

  before_create :set_title_hypenation, :set_slug
  before_update :set_title_hypenation

  def domain_to_buy
    uri = URI.parse(uri_to_buy)
    uri.host.delete_prefix('www.')
  end

  def domain_to_sample
    uri = URI.parse(uri_to_sample)
    uri.host.delete_prefix('www.')
  end

  def domain_to_audiobook
    uri = URI.parse(uri_to_audiobook)
    uri.host.delete_prefix('www.')
  end

  def cover_image_url(image_format = 'webp')
    return original_cover_bucket_url unless cover_image.attached?

    cover_variant = cover_image.variant(
      format: image_format,
      saver: { quality: IMAGE_QUALITY }
    )

    if ActiveStorage::Blob.service.name.to_s == 'local'
      return Rails.application.routes.url_helpers.url_for(cover_variant)
    end

    cover_variant.processed.url
  end

  def attach_cover_image
    image_uri = URI.parse(original_cover_bucket_url)
    response  = Net::HTTP.get_response(image_uri)

    return false unless response.is_a?(Net::HTTPSuccess)
    return false unless response['content-type'] == IMAGE_FILE_TYPE

    if response.is_a?(Net::HTTPSuccess)
      attach_cover_image_from_string(response.body)
    end
    true
  end

  def cover_image_variant_url(width, image_format = 'webp')
    cover_variant = cover_image.variant(
      resize_to_limit: [width, width],
      format: image_format,
      saver: { quality: IMAGE_QUALITY }
    )

    if ActiveStorage::Blob.service.name.to_s == 'local'
      return Rails.application.routes.url_helpers.url_for(cover_variant)
    end

    cover_variant.processed.url
  end

  def cover_img_srcset(format = 'webp')
    return '' unless cover_image.attached?

    srcset = []
    COVER_IMAGE_VARIANTS.each do |v|
      srcset << cover_image_variant_url(v, format) + " #{v}w"
    end
    srcset.join(', ')
  end

  def original_cover_bucket_url
    bucket_url = 'https://storage.googleapis.com/bokatidindi-covers-original/'
    "#{bucket_url}#{source_id}#{IMAGE_FILE_SUFFIX}"
  end

  def show_description
    return description.html_safe if long_description.empty?

    long_description.html_safe
  end

  def short_description
    return long_description.truncate(256).html_safe if description.empty?

    description.truncate(383).html_safe
  end

  def hours
    return nil if minutes.nil? || minutes <= 1

    minutes / 60
  end

  def categories_label
    return 'V??ruflokkar' if categories.count > 1

    'V??ruflokkur'
  end

  def category_links
    links = []
    categories.each do |c|
      links << link_to(
        c.name_with_group, "/baekur/flokkur/#{c.slug}",
        title: "Sko??a fleiri b??kur ?? flokknum #{c.name}"
      )
    end
    links.to_sentence
  end

  def author_groups
    groups = []

    book_authors_in_order = book_authors.includes(:author_type).order(
      'author_types.rod': :asc, id: :desc
    )

    group_records = book_authors_in_order.group_by(&:author_type)
    group_records.each do |author_type, book_authors|
      authors = book_authors
      groups.push author_group_hash(author_type, authors)
    end

    groups
  end

  def full_title
    [
      pre_title, title_noshy, post_title
    ].reject(&:blank?).flatten.compact.join(' ')
  end

  def full_title_with_author
    return "#{full_title} - #{author_names_string}" if author_names_string

    full_title
  end

  def author_names_string
    author_names = []

    selected_book_authors = book_authors.joins(:author_type).where(
      author_type: { name: 'H??fundur' }
    )
    return nil if selected_book_authors.empty?

    selected_book_authors.each do |a|
      author_names << a.author.name
    end

    author_names.to_sentence
  end

  def authors_brief
    book_authors.joins(:author_type).where(author_type: { name: 'H??fundur' })
  end

  def set_title_hypenation
    HYPENATION_ALTERNATIVES.each do |a|
      self.title = title.gsub(a, HYPENATION_SEPARATOR)
    end
    self.title_noshy = title.gsub(HYPENATION_SEPARATOR, '')
    self.title_hypenated = title.gsub(HYPENATION_SEPARATOR, HYPENATION_SYMBOL)
  end

  def set_slug
    parameterized_title = title_noshy.parameterize(locale: :is).first(64)

    # Prevent the slug from ending with a dash
    if parameterized_title.end_with?('-')
      parameterized_title = parameterized_title.chop
    end

    self.slug = "#{parameterized_title}-#{source_id}"
  end

  def current_edition?
    editions.pluck(:id).include?(Edition.find_by(active: true).id)
  end

  def attach_cover_image_from_string(string)
    success = cover_image.attach(
      io: StringIO.new(string),
      filename: "#{SecureRandom.uuid}.jpg"
    )

    return false unless success

    attach_cover_image_variants
    true
  end

  private

  def attach_cover_image_variants
    attach_cover_image_variant('webp')
    attach_cover_image_variant('jpg')
    COVER_IMAGE_VARIANTS.each do |v|
      attach_cover_image_variant('webp', v)
      attach_cover_image_variant('jpg', v)
    end
  end

  def attach_cover_image_variant(image_format, width = nil)
    if width
      return cover_image.variant(
        resize_to_limit: [width, width],
        format: image_format,
        saver: { quality: IMAGE_QUALITY }
      ).process
    end
    cover_image.variant(
      format: image_format,
      saver: { quality: IMAGE_QUALITY }
    ).process
  end

  def author_group_name_plural(count, singular, plural)
    return singular if count == 1

    plural
  end

  def author_group_hash(author_type, authors)
    {
      authors:,
      name: author_group_name_plural(
        authors.count, author_type.name, author_type.plural_name
      ),
      author_links: (
        authors.map do |a|
          link_to(
            a.name,
            "/baekur/hofundur/#{a.author.slug}",
            class: 'author-link'
          )
        end
      ).to_sentence
    }
  end
end
