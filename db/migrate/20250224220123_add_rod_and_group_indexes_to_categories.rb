# frozen_string_literal: true

class AddRodAndGroupIndexesToCategories < ActiveRecord::Migration[7.0]
  def change
    add_index :categories, :rod
    add_index :categories, :group
  end
end
