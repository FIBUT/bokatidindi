# frozen_string_literal: true

class BookEditionCategory < ApplicationRecord
  DK_WEB_ITEM_CODE   = ENV['DK_PRINT_ITEM_CODE']
  DK_PRINT_ITEM_CODE = ENV['DK_WEB_ITEM_CODE']

  belongs_to :book_edition
  has_one :book, through: :book_edition
  belongs_to :category

  scope :by_edition, lambda { |edition_id|
    joins(
      book_edition: [:edition]
    ).where(
      book_edition: { edition: edition_id }
    )
  }

  scope :by_publisher, lambda { |publisher_id|
    joins(
      book_edition: { book: [:publisher] }
    ).where(
      book: { publisher: publisher_id }
    )
  }

  scope :invoiced, lambda {
    where(invoiced: true)
  }

  scope :uninvoiced, lambda {
    where(invoiced: false)
  }

  def to_dk_invoice_lines
    lines = []

    if for_web
      lines.push build_dk_invoice_line('Vefbirting í Bókatíðindum',
                                       DK_WEB_ITEM_CODE)
    end
    if for_print
      lines.push build_dk_invoice_line('Prentbirting í Bókatíðindum',
                                       DK_PRINT_ITEM_CODE)
    end

    lines
  end

  def build_dk_invoice_line(type, item_code)
    {
      ItemCode: item_code,
      Text: "#{type}, #{book.full_title_noshy} (#{category.name})",
      Quantity: 1
    }
  end
end
