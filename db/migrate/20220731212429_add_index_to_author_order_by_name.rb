# frozen_string_literal: true

class AddIndexToAuthorOrderByName < ActiveRecord::Migration[7.0]
  def change
    add_index :authors, :order_by_name
    add_index :authors, :is_icelandic
  end
end
