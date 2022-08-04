# frozen_string_literal: true

class RemoveAttributesFromBooks < ActiveRecord::Migration[7.0]
  def change
    remove_column :books, :page_count, :integer, index: true
    remove_column :books, :minutes, :integer, index: true
    remove_column :books, :store_url, :string
    remove_column :books, :sample_url, :string
    remove_column :books, :audio_url, :string
    remove_column :books, :book_author_id, :string
  end
end
