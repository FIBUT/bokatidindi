class Publisher < ApplicationRecord
  has_many :books

  before_create :set_slug

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
