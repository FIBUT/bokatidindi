# frozen_string_literal: true

class CreateEditions < ActiveRecord::Migration[6.1]
  def change
    create_table :editions do |t|
      t.string :title
      t.string :original_title_id_string
      t.boolean :active

      t.timestamps
    end
    create_table :book_editions do |t|
      t.belongs_to :book, index: true
      t.belongs_to :edition, index: true

      t.timestamps
    end
  end
end
