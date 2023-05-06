# frozen_string_literal: true

class BlockquoteLengthTo512 < ActiveRecord::Migration[7.0]
  def up
    change_column :blockquotes, :quote, :string, limit: 512
  end

  def down
    change_column :blockquotes, :quote, :string, limit: 255
  end
end
