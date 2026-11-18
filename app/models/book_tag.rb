# frozen_string_literal: true

class BookTag < ApplicationRecord
  belongs_to :book
  belongs_to :tag

  after_create :update_category_tags
  after_update :update_category_tags

  def update_category_tags
    book.categories.each do |c|
      c.update_tags
      c.save!
    end
  end
end
