# frozen_string_literal: true

class ChangeBookBindingTypeDateTimeToDate < ActiveRecord::Migration[7.0]
  def up
    change_column :book_binding_types, :publication_date, :date
  end

  def down
    change_column :book_binding_types, :publication_date, :datetime
  end
end
