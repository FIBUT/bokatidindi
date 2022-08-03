# frozen_string_literal: true

class AddNewAttributesToBookBindings < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :book_binding_types,
      :language, :string, index: true, limit: 2, null: false, default: 'is'
    )
    add_column :book_binding_types, :url, :string
    add_column :book_binding_types, :page_count, :integer
    add_column :book_binding_types, :minutes, :integer
  end
end
