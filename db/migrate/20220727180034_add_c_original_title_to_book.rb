# frozen_string_literal: true

class AddCOriginalTitleToBook < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :original_title, :string
  end
end
