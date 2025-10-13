# frozen_string_literal: true

class CreatePrintLocations < ActiveRecord::Migration[8.0]
  def up
    create_table :print_locations do |t|
      t.column :name, :string
      t.column :address, :string
      t.column :region, :integer, default: 1, null: false
      t.column :latitude, :float
      t.column :longitude, :float
      t.column :visible, :boolean, default: true
      t.timestamps
    end
  end

  def down
    drop_table :print_locations
  end
end
