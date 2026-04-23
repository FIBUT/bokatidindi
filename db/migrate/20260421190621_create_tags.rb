# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[8.1]
  def up
    create_table :tags do |t|
      t.string :title, null: false
      t.string :title_plural, null: false
      t.string :slug, null: false
      t.string :description, default: '', null: false
      t.boolean :active, default: true, null: false
      t.integer :rod, default: 0, null: false
      t.timestamps
      t.index :title
    end
  end

  def down
    drop_table :tags
  end
end
