# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :book_authors, dependent: :restrict_with_error
  has_many :books, through: :book_authors

  enum :schema_type, { Person: 0, Organization: 1 }

  before_validation :strip_text
  before_validation :set_name
  before_create :set_slug, :set_order_by_name
  before_update :set_order_by_name

  validates :firstname, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    ['name', 'is_icelandic']
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def book_count
    Book.includes(
      :book_editions, :book_authors, :authors
    ).where(
      book_authors: { authors: { id: } },
      book_editions: { 'edition_id': Edition.current.pluck(:id) }
    ).count
  end

  def set_order_by_name
    return self.order_by_name = firstname if lastname.empty?

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
    random_string = rand(1000..9999)

    # Prevent the slug from ending with a dash
    if parameterized_name.end_with?('-')
      parameterized_name = parameterized_name.chop
    end
    self.slug = "#{parameterized_name}-#{random_string}"
  end

  def strip_text
    self.firstname = firstname.try(:strip)
    self.lastname  = lastname.try(:strip)
  end

  def structured_data
    {
      '@type': schema_type,
      name: name,
      url: "https://www.bokatidindi.is/baekur/hofundur/#{slug}"
    }
  end
end
