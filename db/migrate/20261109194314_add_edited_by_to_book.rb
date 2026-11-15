class AddEditedByToBook < ActiveRecord::Migration[8.1]
  def up
    add_column :books, :edited_by_id, :integer
  end

  def down
    remove_column :books, :edited_by_id
  end
end
