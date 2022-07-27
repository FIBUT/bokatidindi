# frozen_string_literal: true

class AddCountryOfOriginToBook < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :country_of_origin, :string
  end
end
