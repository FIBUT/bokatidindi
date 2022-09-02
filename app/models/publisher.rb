# frozen_string_literal: true

class Publisher < ApplicationRecord
  has_many :books, dependent: :restrict_with_error

  before_create :set_slug

  default_scope { order(:name) }

  validates :url, url: true, allow_blank: true
  validates :email_address, format: { with: Devise.email_regexp },
                            allow_blank: true

  def book_count
    Book.includes(
      :book_editions
    ).where(
      publisher_id: id,
      book_editions: { 'edition_id': Edition.current_edition[:id] }
    ).count
  end

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
