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
              unless: proc { |bbt| bbt.barcode.blank? },
              if: proc { |bbt| bbt&.binding_type&.barcode_type == 'ISBN' }
  )
  validates(
    :barcode, uniqueness: true,
              allow_nil: true,
              if: proc { |bbt| bbt&.binding_type&.barcode_type == 'ISBN' },
              unless: proc { |bbt| bbt.barcode.blank? }
  )

  validates :language, inclusion: {
    in: BookBindingType::AVAILABLE_LANGUAGES.pluck(0)
  }

  validates :url, url: true, allow_blank: true

  before_validation :sanitize_barcode, :strip_url

  validate :issn_must_be_valid

  def issn_must_be_valid
    return nil unless binding_type.barcode_type == 'ISSN' && !valid_issn?

    errors.add(:barcode, 'Þarf að vera gilt ISSN-númer')
  end

  def valid_issn?
    return true if barcode.starts_with?('977') && EAN13.new(barcode).valid?

    return true if StdNum::ISSN.valid?(barcode)

    false
  end

  def self.random_isbn
    isbn10            = rand(11_111..99_999).to_s
    prefix            = 978
    country_prefix    = 9935
    isbn13_sans_check = "#{prefix}#{country_prefix}#{isbn10}"
    check_digit       = ISBN::Calculator.calculate(isbn13_sans_check)
    "#{isbn13_sans_check}#{check_digit}"
  end

  def language_name
    language_a[0]
  end

  def hours
    return nil unless minutes

    Time.at(60 * minutes).utc.strftime('%H:%M')
  end

  def structured_data
    result = {
      '@type': 'Book',
      disambiguatingDescription: binding_type.name
    }

    if binding_type.group == 'audiobooks'
      result['@type'] = ['Book', 'Audiobook']
    end

    if binding_type.barcode_type == 'ISSN'
      result['@type'] = ['Book', 'Periodical']
    end

    result[:isbn]          = barcode if binding_type.barcode_type == 'ISBN'
    result[:datePublished] = publication_date if publication_date
    result[:numberOfPages] = page_count if page_count
    result[:inLanguage]    = language if language

    result
  end

  private

  def sanitize_barcode
    barcode.delete('^0-9')
  end

  def strip_url
    url&.strip!
  end

  def language_a
    AVAILABLE_LANGUAGES.find { |l| l[1] == language }
  end
end
