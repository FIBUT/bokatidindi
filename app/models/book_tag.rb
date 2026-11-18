# frozen_string_literal: true

class BookTag < ApplicationRecord
  belongs_to :book
  belongs_to :tag

  after_create :update_category_tags
  after_update :update_category_tags

  def self.ransackable_attributes(_auth_object = nil)
    ['book_id', 'created_at', 'id', 'id_value', 'tag_id', 'updated_at']
  end

  def update_category_tags
    book.categories.each do |c|
      c.update_tags
      c.save!
    end
  end
end
