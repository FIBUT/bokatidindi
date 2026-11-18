# frozen_string_literal: true

class AddTagsToCategory < ActiveRecord::Migration[8.1]
  def up
    add_column :categories, :tag_ids, :json, default: [], null: false
  end

  def down
    remove_column :categories, :tag_ids
  end
end
