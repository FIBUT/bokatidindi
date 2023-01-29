# frozen_string_literal: true

class AddAddedByToAuthors < ActiveRecord::Migration[7.0]
  def change
    add_column :authors, :added_by_id, :integer
    add_foreign_key :authors, :admin_users, column: :added_by_id
  end
end
