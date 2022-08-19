# frozen_string_literal: true

class AddEmailAddressToPublishers < ActiveRecord::Migration[7.0]
  def change
    add_column :publishers, :email_address, :string
  end
end
