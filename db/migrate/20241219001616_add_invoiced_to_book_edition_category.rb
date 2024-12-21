# frozen_string_literal: true

class AddInvoicedToBookEditionCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :book_edition_categories, :invoiced, :boolean, default: false
    add_index :book_edition_categories, :invoiced
  end
end
