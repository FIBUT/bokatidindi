# frozen_string_literal: true

class Publisher < ApplicationRecord
  has_many :books, dependent: :restrict_with_error

  before_create :set_slug

  default_scope { order(:name) }

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
