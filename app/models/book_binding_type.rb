# frozen_string_literal: true

class BookBindingType < ApplicationRecord
  AVAILABLE_LANGUAGES = ISO_639::ISO_639_2.pluck(
    2, 3
  ).delete_if { |l| l[0] == '' }

  AVAILABILITIES = %i[unknown pending available sold_out reprint_pending].freeze

  enum :availability, AVAILABILITIES

  belongs_to :book
  belongs_to :binding_type

  delegate :name, to: :binding_type

  validates :barcode, :book, :language, presence: true
  validates(
    :barcode, isbn_format: {
      with: :isbn13,
      message: 'þarf að vera gilt ISBN-13-númer'
    },
              unless: proc { |bbt| bbt.barcode.blank? }
  )
  validates(
    :barcode, uniqueness: true,
              allow_nil: true,
              unless: proc { |bbt| bbt.barcode.blank? }
  )

  validates :language, inclusion: {
    in: BookBindingType::AVAILABLE_LANGUAGES.pluck(0)
  }

  validates(
    :page_count,
    numericality: true,
    if: proc { |bbt| bbt.binding_type&.printed_books? }
  )
  validates(
    :minutes, numericality: true,
              if: proc { |bbt| bbt.binding_type&.audiobooks? }
  )

  validates :url, url: true, allow_blank: true

  def self.random_isbn
    isbn10            = FFaker::Book.isbn
    isbn13_sans_check = "978#{isbn10[0...-1]}"
    check_digit       = ISBN::Calculator.calculate(isbn13_sans_check)
    "#{isbn13_sans_check}#{check_digit}"
  end

  def language_name
    language_a[0]
  end

  private

  def language_a
    AVAILABLE_LANGUAGES.find { |l| l[1] == language }
  end
end
