# frozen_string_literal: true

class AddOriginalLanguageToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :original_language, :string, limit: 2
  end
end
