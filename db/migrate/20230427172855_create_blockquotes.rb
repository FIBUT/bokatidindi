# frozen_string_literal: true

class CreateBlockquotes < ActiveRecord::Migration[7.0]
  def up
    create_table :blockquotes do |t|
      t.string :quote, limit: 255
      t.string :citation, limit: 63
      t.integer :location, default: 0
      t.integer :size, default: 0

      t.belongs_to :book
      t.timestamps
    end

    books = Book.where.not(blockquote: nil)
    books.each do |b|
      bq = Blockquote.create(
        book_id: b.id, quote: b.blockquote, citation: b.blockquote_source
      )
      bq.save
    end

    remove_column :books, :blockquote, :string
    remove_column :books, :blockquote_source, :string
  end

  def down
    drop_table :blockquotes
  end
end
