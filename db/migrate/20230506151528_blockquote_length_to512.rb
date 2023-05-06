# frozen_string_literal: true

class BlockquoteLengthTo512 < ActiveRecord::Migration[7.0]
  def change
    change_column :blockquote, :quote, :string, limit: 512
  end
end
