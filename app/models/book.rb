class Book < ApplicationRecord
  COVER_IMAGE_VARIANTS  = [266, 364, 550, 768, 992, 1200, 1386, 1600].freeze
  IMAGE_QUALITY         = 80
  IMAGE_VIBRANCE        = 20

  include ActionView::Helpers::UrlHelper

  has_many :book_authors
  has_many :authors, through: :book_authors
  has_many :book_categories
  has_many :categories, through: :book_categories
  has_many :author_types, through: :book_authors
  has_many :book_binding_types
  has_many :binding_types, through: :book_binding_types
  belongs_to :publisher

  has_one_attached :cover_image

  paginates_per 18

  before_create :set_slug

  def cover_image_url(format = 'webp')
    return original_cover_bucket_url unless cover_image.attached?

    Rails.application.routes.url_helpers.url_for(
      cover_image.variant(format: format, vibrance: IMAGE_VIBRANCE)
    )
  end

  def attach_cover_image
    cover_image.attach(
      io: URI.parse(original_cover_bucket_url).open, filename: "#{id}.jpg"
    )
  end

  def cover_image_variant_url(width, format = 'webp')
    Rails.application.routes.url_helpers.url_for(
      cover_image.variant(resize: width, quality: IMAGE_QUALITY, format: format)
    )
  end

  def cover_img_srcset(format = 'webp')
    return '' unless cover_image.attached?

    srcset = ''
    COVER_IMAGE_VARIANTS.each do |v|
      srcset << cover_image_variant_url(v, format)
      srcset << " #{v}w, "
    end
    srcset.delete_suffix(', ')
  end

  def original_cover_bucket_url
    "https://storage.googleapis.com/bokatidindi-covers-original/#{source_id}_86941.jpg"
  end

  def show_title
    coder = HTMLEntities.new
    coder.decode(title)
  end

  def show_description
    if long_description.empty?
      return description.html_safe
    end

    long_description.html_safe
  end

  def short_description
    if description.empty?
      return long_description.truncate(128).html_safe
    end

    description.truncate(128).html_safe
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
        c.name, "/baekur/?category=#{c.slug}",
        title: "Skoða fleiri bækur í flokknum #{c.name}",
      )
    end
    links.to_sentence
  end

  def author_groups
    groups = []

    book_authors_with_type = book_authors.includes(:author_type)
    book_authors_in_order  = book_authors_with_type.order('author_types.rod ASC')

    group_records = book_authors_in_order.group_by(&:author_type)
    group_records.each do |author_type, book_authors|
      authors = book_authors
      groups.push author_group_hash(author_type, authors)
    end

    groups
  end

  def full_title
    [pre_title, title, post_title].reject(&:blank?).flatten.compact.join(' ')
  end

  private

  def author_group_name_plural(count, singular, plural)
    return singular if count == 1

    plural
  end

  def author_group_hash(author_type, authors)
    {
      name: author_group_name_plural(
        authors.count, author_type.name, author_type.plural_name
      ),
      authors: authors, author_links: (
        authors.map do |a|
          link_to(
            a.name,
            "/baekur/?author=#{a.author.slug}",
            class: 'author-link'
          )
        end
      ).to_sentence
    }
  end

  def set_slug
    parameterized_title = title.parameterize(locale: :is).first(64)
    parameterized_title = parameterized_title.chop if parameterized_title.end_with?('-')
    self.slug = "#{parameterized_title}-#{source_id}"
  end
end
