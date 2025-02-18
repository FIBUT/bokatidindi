# frozen_string_literal: true

class BookEdition < ApplicationRecord
  belongs_to :book
  belongs_to :edition
  has_many :book_edition_categories, dependent: :destroy
  has_many :categories, through: :book_edition_categories

  # Editions that are open for registration
  scope :active, lambda {
    joins(:edition).where(open_to_web_registrations: true)
  }

  scope :inactive, lambda {
    joins(:edition).where(open_to_web_registrations: false)
  }

  # Editions that are currently visible online
  scope :current, lambda {
    joins(:edition).where(online: true)
  }

  after_create :create_book_edition_categories

  def update_book_edition_categories(force: true)
    if edition.open_to_print_registrations || force == true
      # Delete the BookEditionCategory records if the current edition is
      # open for both print and web registrations and re-enter them into the
      # database
      update_book_edition_categories_before_print_registration_ends
    elsif edition.open_to_web_registrations
      # Only amend records to set for_web to false if for_print equals true
      # instead of deleting them.
      update_book_edition_categories_after_print_registration
    end

    book_edition_categories.where(for_web: false, for_print: false).destroy_all

    book_edition_categories
  end

  def create_book_edition_categories
    book.book_categories.each do |bc|
      next unless Edition.current.ids.include?(edition.id)

      for_print = if bc.for_print == true
                    if edition.open_to_print_registrations == false
                      false
                    else
                      bc.for_print
                    end
                  else
                    bc.for_print
                  end

      BookEditionCategory.create(
        book_edition_id: id,
        category_id: bc.category_id,
        for_web: bc.for_web,
        for_print:
      )
    end
  end

  private

  def update_book_edition_categories_before_print_registration_ends
    category_ids = book.book_categories.pluck(:category_id)
    book_edition_categories.where.not(
      category_id: category_ids
    ).destroy_all

    book.book_categories.each do |bc|
      current_book_edition_category = book_edition_categories.find_by(
        book_edition_id: id,
        category: bc.category
      )
      if current_book_edition_category.instance_of?(BookEditionCategory)
        current_book_edition_category.for_web = bc.for_web
        current_book_edition_category.for_print = bc.for_print
        current_book_edition_category.save
      else
        BookEditionCategory.create(
          book_edition_id: id, category_id: bc.category_id,
          for_web: bc.for_web, for_print: bc.for_print
        )
      end
    end
  end

  def update_book_edition_categories_after_print_registration
    book.book_categories.each do |bc|
      current_book_edition_category = book_edition_categories.find_by(
        book_edition_id: id,
        category_id: bc.category_id
      )
      if current_book_edition_category.instance_of?(BookEditionCategory)
        current_book_edition_category.for_web = bc.for_web

        current_book_edition_category.save
      elsif bc.for_web == true
        BookEditionCategory.create(
          book_edition_id: id, category_id: bc.category_id,
          for_web: true, for_print: false
        )
      end
    end

    category_ids = book.book_categories.pluck(:category_id)
    book_edition_categories.where.not(
      category_id: category_ids
    ).find_each do |bec|
      if bec.for_print == true
        bec.for_web = false
        bec.save
      else
        bec.destroy
      end
    end
  end
end
