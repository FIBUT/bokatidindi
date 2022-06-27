# frozen_string_literal: true

class AddUrlsToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :uri_to_buy, :string
    add_column :books, :uri_to_sample, :string
    add_column :books, :uri_to_audiobook, :string
  end
end
