# frozen_string_literal: true

class AddStatusToBookBindingTypes < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :book_binding_types, :availability, :integer, null: false, default: 0
    )
    add_column :book_binding_types, :publication_date, :datetime
  end
end
