# frozen_string_literal: true

class Edition < ApplicationRecord
  has_many :book_editions, dependent: :restrict_with_error
  has_many :book_edition_categories, through: :book_editions

  # Editions that are open for registration
  scope :active, lambda {
    where(
      "opening_date < '#{DateTime.now.to_fs(:db)}' "\
      "AND closing_date > '#{DateTime.now.to_fs(:db)}'"
    )
  }

  scope :inactive, lambda {
    where.not(
      "opening_date < '#{DateTime.now.to_fs(:db)}' "\
      "AND closing_date > '#{DateTime.now.to_fs(:db)}'"
    )
  }

  # Editions that are currently visible online
  scope :current, lambda {
    where(
      "online_date < '#{DateTime.now.to_fs(:db)}'"
    ).order(id: :desc).limit(1)
  }

  has_many :book_editions, dependent: :destroy
  has_many :books, through: :book_editions

  def self.current_edition
    Edition.where(
      "online_date < '#{DateTime.now.to_fs(:db)}'"
    ).order(id: :desc).limit(1).first
  end

  def closed?
    closing_date < DateTime.now
  end

  def book_count
    Book.includes(
      :book_editions
    ).where(
      book_editions: { 'edition_id': id }
    ).count
  end
end
