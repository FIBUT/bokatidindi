# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :book_authors, dependent: :restrict_with_error
  has_many :books, through: :book_authors

  enum :gender, %i[undefined male female non_binary]

  before_validation :set_name
  before_create :set_slug, :set_order_by_name
  before_update :set_order_by_name

  validates :firstname, :lastname, presence: true

  def book_count
    Book.includes(
      :book_editions, :book_authors, :authors
    ).where(
      book_authors: { authors: { id: } },
      book_editions: { 'edition_id': Edition.current.first.id }
    ).count
  end

  def set_order_by_name
    if is_icelandic == true
      return self.order_by_name = "#{firstname} #{lastname}"
    end

    self.order_by_name = "#{lastname}, #{firstname}"
  end

  def set_name
    self[:name] = "#{firstname} #{lastname}"
  end

  def set_slug
    parameterized_name = name.parameterize(locale: :is).first(64)

    # Prevent the slug from ending with a dash
    if parameterized_name.end_with?('-')
      parameterized_name = parameterized_name.chop
    end
    self.slug = "#{parameterized_name}-#{source_id}"
  end
end
