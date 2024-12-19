class AddIsMemberToPublisher < ActiveRecord::Migration[7.0]
  def change
    add_column :publishers, :is_member, :boolean, default: true
  end
end
