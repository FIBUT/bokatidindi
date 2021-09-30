class Author < ApplicationRecord
  has_many :book_authors
  has_many :books, through: :book_authors

  before_create :set_slug

  def name
    firstname + ' ' + lastname
  end

  private

  def set_slug
    parameterized_name = name.parameterize(locale: :is).first(64)
    parameterized_name = parameterized_name.chop if parameterized_name.end_with?('-')
    self.slug = "#{parameterized_name}-#{source_id}"
  end
end
