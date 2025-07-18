# frozen_string_literal: true

class Publisher < ApplicationRecord
  has_many :books, dependent: :restrict_with_error

  enum :schema_type, { Person: 0, Organization: 1 }

  before_create :set_slug

  default_scope { order(:name) }

  validates :url, url: true, allow_blank: true
  validates :email_address, format: { with: Devise.email_regexp },
                            allow_blank: true

  def self.ransackable_attributes(_auth_object = nil)
    ['name', 'created_at', 'updated_at']
  end

  def book_edition_categories_by_edition_id(edition_id)
    BookEditionCategory.joins(
      book_edition: [:edition, { book: [:publisher] }]
    ).where(
      'books.publisher_id': id, 'book_editions.edition_id': edition_id
    )
  end

  def book_count
    Book.includes(
      :book_editions
    ).where(
      publisher_id: id,
      book_editions: { 'edition_id': Edition.current.pluck(:id) }
    ).count
  end

  def ld_json
    {
      '@id': "https://www.bokatidindi.is/baekur/utgefandi/#{slug}",
      '@type': schema_type,
      url: "https://www.bokatidindi.is/baekur/utgefandi/#{slug}",
      name: name
    }
  end

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
