# frozen_string_literal: true

class Book < ApplicationRecord
  PERMITTED_IMAGE_FORMATS = ['image/jpeg', 'image/png', 'image/webp',
                             'image/jp2', 'image/jxl', ' image/avif'].freeze

  PERMITTED_AUDIO_FORMATS = ['audio/aac', 'audio/mpeg', 'audio/ogg'].freeze

  COVER_IMAGE_VARIANTS = [150, 260, 550, 1200, 1600].freeze
  SAMPLE_PAGE_VARIANTS = [50, 100, 150, 260, 550, 1200, 1600].freeze
  IMAGE_QUALITY        = 80

  PRIORITY_COUNTRIES_OF_ORIGIN = ['IS', 'US', 'GB', 'DK', 'FI', 'FR', 'IT',
                                  'NO', 'ES', 'SE', 'DE'].freeze

  HYPENATION_SEPARATOR    = '|'
  HYPENATION_SYMBOL       = "\u00AD"
  HYPENATION_ALTERNATIVES = [
    '|', '&shy;', "\u00AD", '&#xAD;', '&#173;', '&shy;'
  ].freeze

  PRE_TITLE_MAX_LENGTH        = 60
  TITLE_MAX_LENGTH            = 120
  POST_TITLE_MAX_LENGTH       = 60
  DESCRIPTION_MAX_LENGTH      = 350
  LONG_DESCRIPTION_MAX_LENGTH = 3000
  BLOCKQUOTE_MAX_LENGTH       = 255
  BLOCKQUOTE_CITE_MAX_LENGTH  = 63

  include ActionView::Helpers::UrlHelper
  include PgSearch::Model

  SEARCH_COLUMNS = %i[
    source_id pre_title title_noshy post_title description long_description
    original_title
  ].freeze
  AUTHORS_SEARCH_COLUMMNS          = %i[firstname lastname].freeze
  CATEGORIES_SEARCH_COLUMNS        = %i[origin_name slug].freeze
  BOOK_BINDING_TYPE_SEARCH_COLUMNS = %i[barcode].freeze

  PRINT_RES = 330 / 25.4

  PAGINATION = 18

  multisearchable against: %i[pre_title title_noshy post_title description
                              long_description]

  pg_search_scope :search,
                  against: SEARCH_COLUMNS, associated_against: {
                    authors: AUTHORS_SEARCH_COLUMMNS,
                    categories: CATEGORIES_SEARCH_COLUMNS,
                    book_binding_types: BOOK_BINDING_TYPE_SEARCH_COLUMNS,
                    publisher: :name
                  }

  has_many :book_authors, dependent: :destroy, inverse_of: :book
  has_many :authors, through: :book_authors
  has_many :book_categories, dependent: :destroy, inverse_of: :book
  has_many :categories, through: :book_categories
  has_many :author_types, through: :book_authors
  has_many :book_binding_types, dependent: :destroy, inverse_of: :book
  has_many :binding_types, through: :book_binding_types

  has_many :blockquotes, dependent: :destroy, inverse_of: :book

  # This prevents the deletion of books that have been assigned bo editions.
  has_many :book_editions, dependent: :restrict_with_error
  has_many :editions, through: :book_editions

  belongs_to :publisher

  accepts_nested_attributes_for :book_authors, allow_destroy: true
  accepts_nested_attributes_for :book_categories, allow_destroy: true
  accepts_nested_attributes_for :book_binding_types, allow_destroy: true
  accepts_nested_attributes_for :blockquotes, allow_destroy: true

  has_one_attached :cover_image, dependent: :destroy
  has_one_attached :audio_sample, dependent: :destroy

  has_many_attached :sample_pages, dependent: :destroy

  paginates_per PAGINATION

  before_validation :sanitize_title, :sanitize_description
  before_create :set_title_hypenation, :set_slug
  before_update :set_title_hypenation
  after_update :reset_book_edition_categories

  attribute :cover_image_file
  attribute :audio_sample_file
  attribute :delete_audio_sample
  attribute :sample_pages_files
  attribute :delete_sample_pages

  validates :publisher, :title, :description, presence: true
  validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }
  validates :long_description, length: { maximum: LONG_DESCRIPTION_MAX_LENGTH }

  validates :book_authors, length: { minimum: 1 }
  validates :book_binding_types, length: { minimum: 1 }

  scope :old, lambda {
    includes(
      :publisher, :categories,
      book_authors: %i[author author_type],
      book_editions: %i[book_edition_categories edition]
    ).where.not(
      book_editions: { edition_id: Edition.current_edition[:id] }
    ).order(:title)
  }

  scope :by_edition, lambda { |edition_id|
    includes(
      :publisher, :categories,
      book_authors: %i[author author_type],
      book_editions: %i[book_edition_categories edition]
    ).where(
      book_editions: { edition_id: }
    ).order(:title)
  }

  scope :current, -> { by_edition(Edition.current) }

  scope :for_web, lambda {
    where(
      book_editions: {
        book_edition_categories: { for_web: true }
      }
    )
  }

  scope :for_print, lambda {
    where(
      book_editions: {
        book_edition_categories: { for_print: true }
      }
    )
  }

  scope :by_category, lambda { |cateogry_id|
    where(
      book_editions: {
        book_edition_categories: { category_id: cateogry_id }
      }
    )
  }

  scope :by_publisher, ->(publisher_id) { where(publisher_id:) }

  scope :by_author, lambda { |author_id|
    includes(
      :book_authors
    ).where(
      book_authors: { author_id: }
    ).left_joins(
      :book_authors
    )
  }

  def self.ransackable_associations(_auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s }
  end

  def self.ransackable_attributes(_auth_object = nil)
    column_names
  end

  def structured_data
    result = {
      '@context': 'https://schema.org',
      '@type': 'Book',
      '@id': "https://www.bokatidindi.is/bok/#{slug}",
      '@url': "https://www.bokatidindi.is/bok/#{slug}",
      name: full_title_noshy,
      author: structured_data_authors,
      translator: structured_data_authors(:translator),
      editor: structured_data_authors(:editor),
      illustrator: structured_data_authors(:illustrator),
      contributor: structured_data_authors(:contributor),
      producer: structured_data_authors(:producer),
      description: description,
      genre: categories.map { |c| c.name_with_group('>') },
      workExample: book_binding_types.map(&:structured_data),
      publisher: publisher.ld_json,
      maintainer: structured_data_fibut
    }

    if original_title
      result[:translationOfWork] = { type: 'Book', name: original_title }
    end

    result[:inLanguage] = language_codes if language_codes

    result[:sameAs] = structured_data_url unless structured_data_url.empty?

    result[:image] = cover_image_url('jpg') if cover_image.attached?

    sample_pages.each_with_index do |_sp, i|
      result[:image] << sample_page_url(i, 'jpg')
    end

    result
  end

  def structured_data_publication
    result = {
      '@context': 'https://schema.org/',
      '@id': 'https://www.bokatidindi.is/',
      '@type': ['WebSite', 'Periodical'],
      name: 'Bókatíðindi',
      abstract: WelcomeController::META_DESCRIPTION,
      inLanguage: 'is',
      image: [
        ActionController::Base.helpers.asset_url('favicon-512.png'),
        ActionController::Base.helpers.asset_url('logotype-cropped.svg')
      ],
      maintainer: structured_data_fibut,
      url: 'https://www.bokatidindi.is/',
      potentialAction: {
        '@type': 'SearchAction',
        target: 'https://www.bokatidindi.is/baekur?search={search_term_string}',
        'query-input': 'required name=search_term_string'
      }
    }

    temporal_coverage = editions.pluck(:year) - [nil]

    result[:temporalCoverage] = temporal_coverage if temporal_coverage.any?

    result
  end

  def structured_data_fibut
    {
      '@type': ['Organization'],
      name: 'Félag íslenskra bókaútgefenda',
      alternateName: 'FÍBÚT',
      url: 'https://fibut.is/',
      address: {
        '@type': 'PostalAddress',
        addressLocality: 'Reykjavík',
        postalCode: '101',
        streetAddress: 'Barónsstíg 5',
        addressCountry: 'IS'
      }
    }
  end

  def structured_data_isbn
    book_binding_types.joins(
      :binding_type
    ).where(
      binding_type: { barcode_type: 'ISBN' }
    ).pluck(:barcode)
  end

  def structured_data_url
    book_binding_types.where.not(url: '').pluck(:url).uniq
  end

  def structured_data_authors(schema_role = :author)
    book_authors.includes(
      :author_type, :author
    ).where(author_type: { schema_role: schema_role }).map do |ba|
      {
        '@type': ba.author.schema_type,
        name: ba.name,
        jobTitle: ba.author_type.name,
        url: "https://www.bokatidindi.is/baekur/hofundur/#{ba.author.slug}"
      }
    end
  end

  def main_authors_ids
    book_authors.where(
      author_type_id: 2
    ).pluck(
      :author_id
    )
  end

  def main_authors_string
    authors.where(id: main_authors_ids).pluck(:name).to_sentence
  end

  def other_authors_string
    nodes = []
    records = book_authors.joins(
      :author
    ).where.not(
      author: { id: main_authors_ids }
    )
    records.each do |r|
      nodes << "#{r.author.name} (#{r.author_type.name})"
    end
    nodes.to_sentence
  end

  def isbns_string
    nodes = []
    records = book_binding_types.joins(:binding_type)
    records.each do |r|
      nodes << "#{r.barcode} (#{r.binding_type.name})"
    end
    nodes.to_sentence
  end

  def inactive_edition_ids
    editions.inactive.pluck(:id).to_a
  end

  def language_codes
    book_binding_types.where.not(language: 'is').map(&:language)
  end

  def language_names
    languages = []
    language_codes.each do |l|
      languages << I18n.t("languages.#{l}")
    end
    languages.to_sentence
  end

  # This is a dummy attribute that is intended to make ActiveAdmin accept
  # rendering and accepting a file input
  def cover_image_file(_action_dispatch = nil); end

  def audio_sample_file(_action_dispatch = nil); end

  def delete_audio_sample; end

  def sample_pages_files(_action_dispatch = nil); end

  def delete_sample_pages; end

  def cover_image?
    cover_image.attached?
  end

  def cover_image_proportions
    return 0.0 unless cover_image.attached? &&
                      cover_image.metadata.key?(:height) &&
                      cover_image.metadata.key?(:width)

    cover_image.metadata[:height] / cover_image.metadata[:width].to_f
  end

  def audio_sample?
    audio_sample.attached?
  end

  def description_for_print
    description.gsub(/\r\n\r\n/, "\r\n")[0, 380]
  end

  def sanitize_description
    self.description = description.gsub(/[\r\n]+/, "\r\n\r\n")
                                  .gsub('.  ', '. ')
                                  .gsub('`', '\'')
                                  .gsub('´', '\'')
                                  .gsub(Unicode::Emoji::REGEX_WELL_FORMED, '')
                                  .strip&.upcase_first

    self.long_description = long_description.gsub(/[\r\n]+/, "\r\n\r\n")
                                            .gsub('.  ', '. ')
                                            .gsub('`', '\'')
                                            .gsub('´', '\'')
                                            .gsub(
                                              Unicode::Emoji::REGEX_WELL_FORMED,
                                              ''
                                            )
                                            .strip&.upcase_first
    nil
  end

  def sanitize_title
    self.title      = title&.upcase_first
    self.pre_title  = pre_title&.upcase_first

    self.title      = title&.chop if title.last == '.'
    self.pre_title  = title&.chop if pre_title.last == '.'
    nil
  end

  def page_count
    book_binding_types.each do |b|
      return b[:page_count] if b[:page_count]
    end

    nil
  end

  def minutes
    book_binding_types.each do |b|
      return b[:minutes] if b[:minutes]
    end

    nil
  end

  def hours
    return nil unless minutes

    book_binding_types.each do |b|
      return b.hours if b[:minutes]
    end
  end

  def store_url
    binding_types = book_binding_types.includes(:binding_type).where(
      binding_type: { group: :printed_books }
    )
    return binding_types.first[:url] unless binding_types.empty?

    nil
  end

  def audio_url
    binding_types = book_binding_types.includes(:binding_type).where(
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

  def cover_image_url(image_format = 'webp', original = false)
    return '' unless cover_image.attached?

    if original != true && cover_image_srcsets&.key?(image_format)
      return cover_image_srcsets[image_format].split(', ').last.split(' ').first
    end

    cover_variant = cover_image.variant(format: image_format,
                                        saver: { quality: IMAGE_QUALITY })

    if ['local', 'test'].include?(ActiveStorage::Blob.service.name.to_s)
      return Rails.application.routes.url_helpers.url_for(cover_variant)
    end

    cover_variant.processed.url
  end

  def audio_sample_url
    if ['local', 'test'].include?(ActiveStorage::Blob.service.name.to_s)
      return Rails.application.routes.url_helpers.url_for(audio_sample)
    end

    audio_sample.url
  end

  def cover_image_variant_url(width, image_format = 'webp')
    cover_variant = cover_image.variant(resize_to_limit: [width, nil],
                                        format: image_format,
                                        saver: { quality: IMAGE_QUALITY })

    if ['local', 'test'].include?(ActiveStorage::Blob.service.name.to_s)
      return Rails.application.routes.url_helpers.url_for(cover_variant)
    end

    cover_variant.processed.url
  end

  def update_srcsets
    unless update_cover_image_srcsets && update_sample_pages_srcsets
      return false
    end

    true
  end

  def update_sample_pages_srcsets
    update_attribute(
      'sample_pages_srcsets',
      { webp: sample_page_srcsets('webp'), jpg: sample_page_srcsets('jpg') }
    )
  end

  def update_cover_image_srcsets
    update_attribute(
      'cover_image_srcsets',
      { webp: cover_img_srcset('webp'), jpg: cover_img_srcset('jpg') }
    )
  end

  def cover_img_srcset(format = 'webp')
    return '' unless cover_image.attached?

    srcset = []
    COVER_IMAGE_VARIANTS.each do |v|
      srcset << cover_image_variant_url(v, format) + " #{v}w"
    end
    srcset.join(', ')
  end

  def sample_page_srcsets(format = 'webp')
    srcset_array = []
    sample_pages.each_with_index do |_sp, i|
      srcset_array[i] = []
      SAMPLE_PAGE_VARIANTS.each do |v|
        srcset_array[i] << "#{sample_page_variant_url(i, v, format)} #{v}w"
      end
    end
    srcset_array
  end

  def sample_page_url(index, format = 'webp')
    if sample_pages_srcsets[format].empty?
      return sample_page_variant_url(index, 150, @image_format)
    end

    sample_pages_srcsets[format][index]&.last&.split(' ')&.first
  end

  def short_description
    description.truncate(DESCRIPTION_MAX_LENGTH).html_safe
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

    book_authors_in_order = book_authors.order(id: :asc)

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

    selected_book_authors = book_authors.includes(:author_type).where(
      author_type: { name: 'Höfundur' }
    )
    return nil if selected_book_authors.empty?

    selected_book_authors.each do |a|
      author_names << a.author.name
    end

    author_names.to_sentence
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
    random_string       = rand(10_000..99_999)

    # Prevent the slug from ending with a dash
    if parameterized_title.end_with?('-')
      parameterized_title = parameterized_title.chop
    end

    self.slug = "#{parameterized_title}-#{random_string}"
  end

  def current_edition?
    (Edition.current.pluck(:id) & edition_ids).any?
  end

  def attach_cover_image_from_string(string)
    return false if cover_image.attached?

    cover_image.attach(io: StringIO.new(string), filename: SecureRandom.uuid)

    attach_cover_image_variants
    true
  end

  def attach_audio_sample_from_string(string)
    return false if audio_sample.attached?

    audio_sample.attach(io: StringIO.new(string), filename: SecureRandom.uuid)
  end

  def attach_sample_page_from_string(string)
    sample_pages.attach(io: StringIO.new(string), filename: SecureRandom.uuid)
    attach_sample_page_variants
  end

  def attach_sample_page_variants
    SAMPLE_PAGE_VARIANTS.each do |v|
      sample_pages.each do |s|
        s.variant(resize_to_limit: [v, nil], format: 'webp').processed
        s.variant(resize_to_limit: [v, nil], format: 'jpg').processed
      end
    end
    update_sample_pages_srcsets
  end

  def sample_page_variant_url(index, width, format)
    sample_page_variant = sample_pages[index].variant(
      resize_to_limit: [width, nil], format:
    )

    if ActiveStorage::Blob.service.name.to_s == 'local'
      return Rails.application.routes.url_helpers.url_for(sample_page_variant)
    end

    sample_page_variant.url
  end

  def attach_print_image_variant
    cover_image.variant(resize_to_limit: [325, nil],
                        copy: { xres: PRINT_RES,
                                yres: PRINT_RES },
                        format: 'tiff').processed
  end

  def print_image_variant_url
    cover_variant = cover_image.variant(resize_to_limit: [325, nil],
                                        copy: { xres: PRINT_RES,
                                                yres: PRINT_RES },
                                        format: 'tiff')

    if ActiveStorage::Blob.service.name == :local
      return Rails.application.routes.url_helpers.url_for(cover_variant)
    end

    cover_variant.processed.url
  end

  def reset_book_edition_categories
    # book_editions.active.each(&:update_book_edition_categories)
  end

  def attach_cover_image_variants
    return nil unless cover_image.attached?

    attach_cover_image_variant('webp')
    attach_cover_image_variant('jpg')
    COVER_IMAGE_VARIANTS.each do |v|
      attach_cover_image_variant('webp', v)
      attach_cover_image_variant('jpg', v)
    end
    attach_print_image_variant
    update_cover_image_srcsets
  end

  private

  def attach_cover_image_variant(image_format, width = nil)
    if width
      return cover_image.variant(resize_to_limit: [width, nil],
                                 format: image_format,
                                 saver: { quality: IMAGE_QUALITY }).processed
    end
    cover_image.variant(format: image_format,
                        saver: { quality: IMAGE_QUALITY }).processed
  end

  def author_group_name_plural(count, singular, plural)
    return singular if count == 1

    plural
  end

  def author_group_hash(author_type, authors)
    { authors:,
      name: author_group_name_plural(
        authors.count, author_type.name, author_type.plural_name
      ),
      name_abbr: author_type.abbreviation,
      author_links: (
        authors.map do |a|
          if a.author.book_count.positive?
            link_to(a.name, "/baekur/hofundur/#{a.author.slug}",
                    class: 'author-link')
          else
            a.name
          end
        end
      ).to_sentence }
  end
end
