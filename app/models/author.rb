# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :book_authors, dependent: :restrict_with_error
  has_many :books, through: :book_authors

  before_create :set_slug

  def name
    "#{firstname} #{lastname}"
  end

  private

  def set_slug
    parameterized_name = name.parameterize(locale: :is).first(64)

    # Prevent the slug from ending with a dash
    if parameterized_name.end_with?('-')
      parameterized_name = parameterized_name.chop
    end
    self.slug = "#{parameterized_name}-#{source_id}"
  end
end
