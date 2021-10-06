class Category < ApplicationRecord
  has_many :books, through: :book_categories

  before_create :set_slug

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
