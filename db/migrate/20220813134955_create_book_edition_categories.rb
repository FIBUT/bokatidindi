# frozen_string_literal: true

class CreateBookEditionCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :book_edition_categories do |t|
      t.integer :book_edition_id
      t.integer :category_id

      t.boolean :for_web, default: true, null: false
      t.boolean :for_print, default: true, null: false

      t.timestamps
    end
  end
end
