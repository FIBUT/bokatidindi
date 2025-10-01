# frozen_string_literal: true

class AddBirthyearToAuthors < ActiveRecord::Migration[8.0]
  def up
    add_column :authors, :birthyear, :integer, default: nil, null: true
  end

  def down
    remove_column :authors, :birthyear
  end
end
