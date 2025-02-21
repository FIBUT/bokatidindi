class AddSchemaTypeToPublisher < ActiveRecord::Migration[7.0]
  def change
    add_column :publishers, :schema_type, :integer, default: 1, null: false
  end
end
