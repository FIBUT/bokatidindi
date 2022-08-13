# frozen_string_literal: true

class BookEdition < ApplicationRecord
  belongs_to :book
  belongs_to :edition
  has_many :book_edition_categories, dependent: :destroy
  has_many :categories, through: :book_edition_categories

  # Editions that are open for registration
  scope :active, lambda {
    joins(:edition).where(
      "opening_date < '#{DateTime.now.to_fs(:db)}' "\
      "AND closing_date > '#{DateTime.now.to_fs(:db)}'"
    )
  }

  scope :inactive, lambda {
    joins(:edition).where.not(
      "opening_date < '#{DateTime.now.to_fs(:db)}' "\
      "AND closing_date > '#{DateTime.now.to_fs(:db)}'"
    )
  }

  # Editions that are currently visible online
  scope :current, lambda {
    joins(:edition).where(
      "online_date < '#{DateTime.now.to_fs(:db)}' "\
    ).order(id: :desc).limit(1)
  }

  after_create :set_book_edition_categories
  after_update :reset_book_edition_categories

  def reset_book_edition_categories
    book_edition_categories.destroy_all
    set_book_edition_categories
  end

  def set_book_edition_categories
    book.book_categories.each do |bc|
      BookEditionCategory.create(
        book_edition_id: id,
        category_id: bc.category_id,
        for_web: bc.for_web,
        for_print: bc.for_print
      )
    end
  end
end
