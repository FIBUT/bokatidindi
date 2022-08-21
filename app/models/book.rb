# frozen_string_literal: true

class Book < ApplicationRecord
  PERMITTED_IMAGE_FORMATS = [
    'image/jpeg', 'image/png', 'image/webp', 'image/jp2', 'image/jxl'
  ].freeze

  COVER_IMAGE_VARIANTS = [266, 364, 550, 768, 992, 1200, 1386, 1600].freeze
  IMAGE_QUALITY        = 80

  PRIORITY_COUNTRIES_OF_ORIGIN = ['IS', 'US', 'GB', 'DK', 'FI', 'FR', 'IT',
                                  'NO', 'ES', 'SE', 'DE'].freeze

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

  TITLE_MAX_LENGTH            = 110
  DESCRIPTION_MAX_LENGTH      = 380
  LONG_DESCRIPTION_MAX_LENGTH = 3000

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

  has_many :book_authors, dependent: :destroy, inverse_of: :book
  has_many :authors, through: :book_authors
  has_many :book_categories, dependent: :destroy, inverse_of: :book
  has_many :categories, through: :book_categories
  has_many :author_types, through: :book_authors
  has_many :book_binding_types, dependent: :destroy, inverse_of: :book
  has_many :binding_types, through: :book_binding_types

  # This prevents the deletion of books that have been assigned bo editions.
  has_many :book_editions, dependent: :restrict_with_error
  has_many :editions, through: :book_editions

  belongs_to :publisher

  accepts_nested_attributes_for :book_authors, allow_destroy: true
  accepts_nested_attributes_for :book_categories, allow_destroy: true
  accepts_nested_attributes_for :book_binding_types, allow_destroy: true

  has_one_attached :cover_image, dependent: :destroy

  paginates_per 18

  before_validation :sanitize_title
  before_create :set_title_hypenation, :set_slug
  before_update :set_title_hypenation

  attribute :cover_image_file

  validates :publisher, :title, :description, presence: true

  validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }
  validates :long_description, length: { maximum: LONG_DESCRIPTION_MAX_LENGTH }

  scope :current, lambda {
    left_joins(
      book_editions: [:book_edition_categories]
    ).where(
      book_editions: { edition_id: Edition.active.first },
      book_edition_categories: { for_web: true }
    ).order(:title).group('books.id')
  }

  scope :current_by_category, lambda { |category_id|
    joins(
      book_editions: :book_edition_categories
    ).where(
      book_editions: { edition_id: Edition.active.first },
      book_edition_categories: {
        category_id:, for_web: true
      }
    ).order(:title).group('books.id')
  }

  scope :current_by_publisher, lambda { |publisher_id|
    joins(
      book_editions: :book_edition_categories
    ).where(
      publisher_id:,
      book_editions: { edition_id: Edition.active.first },
      book_edition_categories: { for_web: true }
    ).order(:title).group('books.id')
  }

  scope :current_by_author, lambda { |author_id|
    left_joins(
      :book_authors
    ).left_joins(
      book_editions: [:book_edition_categories]
    ).where(
      book_authors: { author_id: },
      book_editions: { edition_id: Edition.active.first },
      book_edition_categories: { for_web: true }
    ).order(:title).group('books.id')
  }

  def cover_image_file(_action_dispatch = nil); end

  def cover_image?
    cover_image.attached?
  end

  def sanitize_title
    self.title      = title&.upcase_first
    self.pre_title  = pre_title&.upcase_first
    self.post_title = post_title&.upcase_first

    self.title      = title&.chop if title.last == '.'
    self.pre_title  = title&.chop if pre_title.last == '.'
    nil
  end

  def page_count
    binding_types = book_binding_types.where.not(page_count: [nil, ''])
    return binding_types.first[:page_count] unless binding_types.empty?

    nil
  end

  def minutes
    binding_types = book_binding_types.where.not(page_count: [nil, ''])
    return binding_types.first[:minutes] unless binding_types.empty?

    nil
  end

  def store_url
    binding_types = book_binding_types.joins(:binding_type).where(
      binding_type: { group: :printed_books }
    )
    return binding_types.first[:url] unless binding_types.empty?

    nil
  end

  def audio_url
    binding_types = book_binding_types.joins(:binding_type).where(
      binding_type: { group: :audiobooks }
    )
    return binding_types.first[:url] unless binding_types.empty?

    nil
  end

  def domain_to_buy
    uri = URI.parse(uri_to_buy)
    uri.host.delete_prefix('www.')
  end

  def domain_to_audiobook
    uri = URI.parse(uri_to_audiobook)
    uri.host.delete_prefix('www.')
  end

  def cover_image_url(image_format = 'webp')
    return '' unless cover_image.attached?

    cover_variant = cover_image.variant(
      format: image_format,
      saver: { quality: IMAGE_QUALITY }
    )

    if ActiveStorage::Blob.service.name.to_s == 'local'
      return Rails.application.routes.url_helpers.url_for(cover_variant)
    end

    cover_variant.processed.url
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

  def short_description
    description.truncate(DESCRIPTION_MAX_LENGTH).html_safe
  end

  def hours
    return nil if minutes.nil? || minutes <= 1

    minutes / 60
  end

  def categories_label
    return 'Vöruflokkar' if categories.count > 1

    'Vöruflokkur'
  end

  def category_links
    links = []
    categories.each do |c|
      links << link_to(
        c.name_with_group, "/baekur/flokkur/#{c.slug}",
        title: "Skoða fleiri bækur í flokknum #{c.name}"
      )
    end
    links.to_sentence
  end

  def full_title_noshy
    [
      pre_title, title_noshy, post_title
    ].reject(&:blank?).flatten.compact.join(' ')
  end

  def author_groups
    groups = []

    book_authors_in_order = book_authors.includes(:author_type).order(
      id: :asc
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
      author_type: { name: 'Höfundur' }
    )
    return nil if selected_book_authors.empty?

    selected_book_authors.each do |a|
      author_names << a.author.name
    end

    author_names.to_sentence
  end

  def authors_brief
    book_authors.joins(:author_type).where(author_type: { name: 'Höfundur' })
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
    random_string       = rand(1000..9999)

    # Prevent the slug from ending with a dash
    if parameterized_title.end_with?('-')
      parameterized_title = parameterized_title.chop
    end

    self.slug = "#{parameterized_title}-#{random_string}"
  end

  def current_edition?
    editions.pluck(:id).include?(Edition.current.first.id)
  end

  def attach_cover_image_from_string(string)
    cover_image.attach(
      io: StringIO.new(string),
      filename: SecureRandom.uuid
    )

    return false if cover_image.attached?

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
          if a.author.book_count.positive?
            link_to(
              a.name,
              "/baekur/hofundur/#{a.author.slug}",
              class: 'author-link'
            )
          else
            a.name
          end
        end
      ).to_sentence
    }
  end
end
