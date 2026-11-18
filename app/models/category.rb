# frozen_string_literal: true

class Category < ApplicationRecord
  GROUPS = %i[childrens_books fiction non_fiction].freeze

  has_many :book_categories, dependent: :restrict_with_error
  has_many :books, through: :book_categories

  enum :group, GROUPS

  before_create :set_slug

  before_update :update_tags

  def self.grouped_options
    optgroups = {}
    GROUPS.each do |group|
      group_name = I18n.t("activerecord.attributes.category.groups.#{group}")
      optgroups[group_name] =
        Category.where(group:).order(rod: :asc).pluck(:name, :id)
    end
    optgroups
  end

  def name_with_group(separator = '-')
    translated_group_name = I18n.t(
      "activerecord.attributes.category.groups.#{group}"
    )
    if group_before_type_cast.zero?
      return "#{translated_group_name} #{separator} #{name}"
    end

    name
  end

  def self.update_all_counts
    Category.all.find_each do |c|
      c.update_counts
      c.save
    end
  end

  def update_counts
    self.book_count       = book_count_collection.count
    self.book_count_web   = book_count_collection.where(for_web: true).count
    self.book_count_print = book_count_collection.where(for_print: true).count
  end

  def update_tags
    self.tag_ids = current_tags.ids
  end

  def tags
    Tag.where(id: tag_ids)
  end

  def current_tags
    book_tag_ids = BookTag.where(book_id: books.current.for_web.ids).ids

    Tag.where(id: book_tag_ids)
  end

  private

  def book_count_collection
    BookEditionCategory.joins(
      :book_edition,
      :category
    ).where(
      category_id: id,
      book_edition: { edition_id: Edition.current }
    )
  end

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
