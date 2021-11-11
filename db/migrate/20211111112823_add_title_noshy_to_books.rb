class AddTitleNoshyToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :title_noshy, :string
  end
end
