# frozen_string_literal: true

class AddKennitalaToPublisher < ActiveRecord::Migration[7.0]
  def change
    add_column :publishers, :kennitala, :string
    add_index :publishers, :kennitala
  end
end
