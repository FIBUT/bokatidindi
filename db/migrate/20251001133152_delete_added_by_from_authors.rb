# frozen_string_literal: true

class DeleteAddedByFromAuthors < ActiveRecord::Migration[8.0]
  def up
    remove_column :authors, :added_by_id
  end

  def down
    add_column :authors, :added_by_id, :integer
  end
end
