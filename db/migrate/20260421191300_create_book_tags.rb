# frozen_string_literal: true

class CreateBookTags < ActiveRecord::Migration[8.1]
  def up
    create_table :book_tags do |t|
      t.integer :book_id, null: false
      t.integer :tag_id, null: false
      t.timestamps
    end
    add_foreign_key :book_tags, :books
    add_foreign_key :book_tags, :tags
  end

  def down
    drop_table :book_tags
  end
end
