# frozen_string_literal: true

class AddSchemaRoleToAuthorType < ActiveRecord::Migration[7.0]
  def change
    add_column :author_types, :schema_role, :integer, default: 0
  end
end
