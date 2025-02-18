# frozen_string_literal: true

class ReplaceDatesWithBoolsInEditions < ActiveRecord::Migration[7.0]
  def up
    add_column :editions, :online, :boolean, default: false
    add_column :editions, :open_to_web_registrations, :boolean, default: false
    add_column :editions, :open_to_print_registrations, :boolean, default: false

    add_index :editions, :online
    add_index :editions, :open_to_web_registrations
    add_index :editions, :open_to_print_registrations
  end

  def down
    remove_column :editions, :online
    remove_column :editions, :open_to_web_registrations
    remove_column :editions, :open_to_print_registrations
  end
end
