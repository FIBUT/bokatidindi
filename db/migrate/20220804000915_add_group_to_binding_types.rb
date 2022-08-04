# frozen_string_literal: true

class AddGroupToBindingTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :binding_types, :group, :integer, null: false, default: 0, index: true
  end
end
