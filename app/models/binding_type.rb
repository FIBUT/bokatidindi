# frozen_string_literal: true

class BindingType < ApplicationRecord
  AUDIO_BOOK_SOURCES = [3, 14, 15].freeze

  enum :group, { printed_books: 0, ebooks: 1, audiobooks: 2 }

  enum :barcode_type, { ISBN: 0, ISSN: 1 }

  default_scope { order('rod ASC, name ASC') }
  scope :open, -> { order('rod ASC, name ASC').where(open: true) }

  has_many :book_binding_types, dependent: :restrict_with_error
  has_many :books, through: :book_binding_types

  before_create :set_slug

  def book_count
    Book.includes(
      :book_editions, :book_binding_types, :binding_types
    ).where(
      book_binding_types: { binding_types: { id: } },
      book_editions: { 'edition_id': Edition.current }
    ).count
  end

  def corrected_name
    return 'Hljóðbók' if group == 'audiobooks'

    name
  end

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
