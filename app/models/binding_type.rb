# frozen_string_literal: true

class BindingType < ApplicationRecord
  AUDIO_BOOK_SOURCES = [3, 14, 15].freeze

  default_scope { order('rod ASC, name ASC') }
  scope :open, -> { order('rod ASC, name ASC').where(open: true) }

  has_many :book_binding_types, dependent: :destroy
  has_many :books, through: :book_binding_types

  before_create :set_slug

  def book_count
    Book.includes(
      :book_editions, :book_binding_types, :binding_types
    ).where(
      book_binding_types: { binding_types: { id: } },
      book_editions: { 'edition_id': Edition.current.first.id }
    ).count
  end

  def corrected_name
    return 'Hljóðbók' if AUDIO_BOOK_SOURCES.include?(source_id)

    name
  end

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
