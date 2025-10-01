# frozen_string_literal: true

class RemoveAddedByIndexFromAuthors < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :authors, :admin_users, column: :added_by_id
  end

  def down
    add_foreign_key :authors, :admin_users, column: :added_by_id
  end
end
