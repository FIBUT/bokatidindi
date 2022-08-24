# frozen_string_literal: true

class AddBookCountToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :book_count, :integer
    add_column :categories, :book_count_web, :integer
    add_column :categories, :book_count_print, :integer
  end
end
