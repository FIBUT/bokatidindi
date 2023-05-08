# frozen_string_literal: true

class AddTypeToBlockquotes < ActiveRecord::Migration[7.0]
  def change
    add_column :blockquotes, :quote_type, :integer, default: 0
  end
end
