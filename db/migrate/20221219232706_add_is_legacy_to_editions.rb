# frozen_string_literal: true

class AddIsLegacyToEditions < ActiveRecord::Migration[7.0]
  def change
    add_column :editions, :is_legacy, :boolean
    add_column :editions, :year, :int
  end
end
