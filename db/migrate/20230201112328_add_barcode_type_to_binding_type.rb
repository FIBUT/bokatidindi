# frozen_string_literal: true

class AddBarcodeTypeToBindingType < ActiveRecord::Migration[7.0]
  def change
    add_column :binding_types, :barcode_type, :integer, default: 0
  end
end
