# frozen_string_literal: true

class AddForPrintAndForWebToBookCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :book_categories, :for_print, :boolean, null: false, default: true
    add_column :book_categories, :for_web, :boolean, null: false, default: true
  end
end
