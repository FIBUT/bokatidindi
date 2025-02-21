class AddSchemaTypeToAuthor < ActiveRecord::Migration[7.0]
  def change
    add_column :authors, :schema_type, :integer, default: 0, null: false
  end
end
