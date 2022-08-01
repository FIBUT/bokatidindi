# frozen_string_literal: true

class AddIsIcelandicToAuthors < ActiveRecord::Migration[7.0]
  def change
    add_column :authors, :is_icelandic, :boolean
    add_column :authors, :order_by_name, :string
    add_column :authors, :gender, :integer
  end
end
