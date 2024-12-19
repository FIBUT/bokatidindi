class AddDkInvoiceNumberToBookEditionCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :book_edition_categories, :dk_invoice_number, :string
  end
end
