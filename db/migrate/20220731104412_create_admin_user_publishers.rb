# frozen_string_literal: true

class CreateAdminUserPublishers < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_user_publishers do |t|
      t.integer :admin_user_id
      t.integer :publisher_id
      t.timestamps
    end
    remove_column :admin_users, :publisher_id, :integer
  end
end
