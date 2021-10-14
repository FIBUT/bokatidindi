class Book < ApplicationRecord
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
    Rails.application.routes.url_helpers.url_for(
      cover_image.variant(format: format)
    )
  end

  def attach_cover_image
    cover_image.attach(io: URI.parse(original_cover_bucket_url).open, filename: "#{id}.jpg")
  end

  def cover_image_variant_url(width, format = 'webp')
    Rails.application.routes.url_helpers.url_for(
      cover_image.variant(resize: width, quality: 80, format: format)
    )
  end

  def srcset_variants(format = 'webp')
    [
      { url: cover_image_variant_url(266, format), w: 266 },
      { url: cover_image_variant_url(364, format), w: 364 },
      { url: cover_image_variant_url(550, format), w: 550 },
      { url: cover_image_variant_url(768, format), w: 768 },
      { url: cover_image_variant_url(992, format), w: 992 },
      { url: cover_image_variant_url(1200, format), w: 1200 },
      { url: cover_image_variant_url(1386, format), w: 1386 },
      { url: cover_image_variant_url(1600, format), w: 1600 }
    ]
  end

  def cover_img_srcset(format = 'webp')
    output = ''
    srcset_variants(format).each do |v|
      output << "#{v[:url]} #{v[:w]}w,"
    end
    output.delete_suffix(',')
  end

  def cover_img_tag_sizes
    '(max-width: 768px) 1386px, (max-width: 992px) 550px, (min-width: 1200px) 1200px, 1600px'
  end

  def thumbnail_img_tag_sizes
    '(max-width: 576px) 364px, (max-width: 768px) 556px, (max-width: 992px) 780px, (min-width: 1200px) 266px, 992px'
  end

  def cover_img_tag(format = 'webp')
    return "<img src=\"#{original_cover_bucket_url}\" class=\"img-fluid\">" unless cover_image.attached?
 
    "<img src=\"#{cover_image_url(format)}\" srcset=\"#{cover_img_srcset(format)}\" sizes=\"#{cover_img_tag_sizes}\" class=\"img-fluid\">"
  end

  def thumbnail_img_tag(format = 'webp')
    return "<img src=\"#{original_cover_bucket_url}\" class=\"img-fluid\">" unless cover_image.attached?
 
    "<img src=\"#{cover_image_url(format)}\" srcset=\"#{cover_img_srcset(format)}\" sizes=\"#{thumbnail_img_tag_sizes}\" class=\"img-fluid\">"
  end

  def original_cover_bucket_url
    "https://storage.googleapis.com/bokatidindi-covers-original/#{source_id}_86941.jpg"
  end

  def show_description
    return description if long_description.empty?

    long_description
  end

  def short_description
    return long_description.truncate(128) if description.empty?

    description.truncate(128)
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
      links << link_to( c.name, "/baekur/?category=#{c.slug}", title: "Skoða fleiri bækur í flokknum #{c.name}" )
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

  def mock_image
    return [
      'satan.jpg', 'lesbian-pulp-1.jpg', 'price-of-salt.jpg', 'barracks.jpg',
      'lion-house.jpg', 'queer-affair.jpg', 'sin-girls.jpg'
    ].sample
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
      authors: authors,
      author_links: (
        authors.map do |a|
          link_to a.name, "/baekur/?author=#{a.author.slug}"
        end
      ).to_sentence
    }
  end

  def set_slug
    parameterized_title = title.parameterize(locale: :is).first(64)
    parameterized_title = parameterized_title.chop if parameterized_title.end_with?('-')
    self.slug = parameterized_title + '-' + source_id.to_s
  end
end
