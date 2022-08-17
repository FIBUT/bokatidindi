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
