# frozen_string_literal: true

class Publisher < ApplicationRecord
  has_many :books, dependent: :restrict_with_error

  before_create :set_slug

  default_scope { order(:name) }

  validates :url, url: true, allow_blank: true
  validates :email_address, format: { with: Devise.email_regexp },
                            allow_blank: true

  def book_edition_categories_by_edition_id(edition_id)
    BookEditionCategory.joins(
      book_edition: [book: [:publisher]]
    ).where(
      'books.publisher_id': id, 'book_editions.edition.id': edition_id
    )
  end

  def book_count
    Book.includes(
      :book_editions
    ).where(
      publisher_id: id,
      book_editions: { 'edition_id': Edition.current_edition[:id] }
    ).count
  end

  def ld_json
    {
      '@id': "https://www.bokatidindi.is/baekur/utgefandi/#{slug}",
      '@type': 'Organization',
      url: ld_json_urls,
      name: name
    }
  end

  private

  def ld_json_urls
    urls = ["https://www.bokatidindi.is/baekur/utgefandi/#{slug}"]
    urls << url if URI(url).scheme

    return urls.first if urls.length == 1

    urls
  end

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
