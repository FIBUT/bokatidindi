# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :book_categories, dependent: :restrict_with_error
  has_many :books, through: :book_categories

  enum :group, %i[childrens_books fiction non_fiction]

  before_create :set_slug

  def name_with_group
    translated_group_name = I18n.t(
      "activerecord.attributes.category.groups.#{group}"
    )
    return "#{translated_group_name} - #{name}" if group_before_type_cast.zero?

    name
  end

  def book_count
    book_count_collection.count
  end

  def book_count_print
    book_count_collection.where(for_print: true).count
  end

  def book_count_web
    book_count_collection.where(for_print: true).count
  end

  private

  def book_count_collection
    BookEditionCategory.joins(
      :book_edition,
      :category
    ).where(
      category_id: id,
      book_edition: { edition_id: Edition.current.last.id }
    )
  end

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
