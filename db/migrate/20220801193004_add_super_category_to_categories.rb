class AddSuperCategoryToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :group, :integer
  end
end
