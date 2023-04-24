# frozen_string_literal: true

class AddBlockquoteToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :blockquote, :string, limit: 255
    add_column :books, :blockquote_source, :string, limit: 63
  end
end
