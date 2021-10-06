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

  paginates_per 25

  before_create :set_slug

  def show_description
    return description if long_description.empty?

    long_description
  end

  def short_description
    return long_description.truncate(256) if description.empty?

    description
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
    categories.each_with_index do |c|
      links << link_to( c.name, "/baekur/?author=#{c.slug}", title: "Skoða fleiri bækur í flokknum #{c.name}" )
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
