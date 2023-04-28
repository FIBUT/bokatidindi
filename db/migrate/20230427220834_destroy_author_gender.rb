class DestroyAuthorGender < ActiveRecord::Migration[7.0]
  def change
    remove_column :authors, :gender, :integer
  end
end
