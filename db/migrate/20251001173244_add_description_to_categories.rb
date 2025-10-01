# frozen_string_literal: true

class AddDescriptionToCategories < ActiveRecord::Migration[8.0]
  def up
    add_column :categories, :description, :string, default: '', limit: 160
  end

  def down
    remove_column :categories, :description
  end
end
