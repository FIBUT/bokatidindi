# frozen_string_literal: true

class RenameCategoryNameToOriginName < ActiveRecord::Migration[6.1]
  def change
    rename_column :categories, :name, :origin_name
  end
end
