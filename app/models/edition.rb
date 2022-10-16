# frozen_string_literal: true

class Edition < ApplicationRecord
  has_many :book_editions, dependent: :restrict_with_error
  has_many :book_edition_categories, through: :book_editions

  # Editions that are open for registration
  scope :active, lambda {
    where(
      "opening_date < '#{DateTime.now.to_fs(:db)}' "\
      "AND closing_date > '#{DateTime.now.to_fs(:db)}'"\
    )
  }

  scope :frozen, lambda {
    where(
      "closing_date < '#{DateTime.now.to_fs(:db)}' and "\
      "print_date > '#{DateTime.now.to_fs(:db)}'"
    )
  }

  scope :inactive, lambda {
    where.not(
      id: Edition.current.ids
    )
  }

  # Editions that are currently visible online
  scope :current, lambda {
    where(
      "online_date < '#{DateTime.now.to_fs(:db)}'"
    ).order(id: :desc).limit(1)
  }

  scope :active_for_web_only, lambda {
    where(
      "opening_date >= '#{Edition.current.first.opening_date.to_fs(:db)}' and "\
      "print_date < '#{DateTime.now.to_fs(:db)}'"
    )
  }

  has_many :book_editions, dependent: :destroy
  has_many :books, through: :book_editions

  def active?
    Edition.active.ids.include?(id)
  end

  def self.form_collection
    editions = (Edition.active + Edition.active_for_web_only)

    form_collection = []
    editions.each do |e|
      form_collection << [e.form_label, e[:id]]
    end

    form_collection
  end

  def form_label
    if print_registration_over?
      return "#{title} (lokað fyrr skráningu í prentútgáfu)"
    end

    title
  end

  def print_registration_over?
    true if print_date < DateTime.now
  end

  def self.current_edition
    Edition.where(
      "online_date < '#{DateTime.now.to_fs(:db)}'"
    ).order(id: :desc).limit(1).first
  end

  def book_count
    Book.includes(
      :book_editions
    ).where(
      book_editions: { 'edition_id': id }
    ).count
  end
end
