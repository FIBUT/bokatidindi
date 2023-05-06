# frozen_string_literal: true

class AddHeadingToBlockquotes < ActiveRecord::Migration[7.0]
  def change
    add_column :blockquotes, :heading, :string, limit: 128
  end
end
