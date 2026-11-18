# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :book_tags, dependent: :destroy
  has_many :books, through: :book_tags

  def self.ransackable_attributes(_auth_object = nil)
    ['title', 'title_plural', 'slug', 'description', 'active', 'rod']
  end

  scope :current, lambda {
    where(
      id: BookTag.where(
        book_id: Book.current.ids
      ).group(
        :tag_id
      ).pluck(
        :tag_id
      )
    )
  }

  before_create :pluralize_title, :generate_slug

  def path(category)
    return "/baekur/#{slug}" if category.blank?

    "/baekur/flokkur/#{category.slug}/#{slug}"
  end

  def generate_slug
    return if slug.present?

    self.slug = I18n.transliterate(
      title_plural.downcase
    ).parameterize(
      separator: '_'
    )
  end

  def pluralize_title
    return if title_plural.present?

    self.title_plural = title.pluralize
  end
end
