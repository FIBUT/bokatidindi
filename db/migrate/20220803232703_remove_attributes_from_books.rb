class RemoveAttributesFromBooks < ActiveRecord::Migration[7.0]
  def change
    remove_column(:books, :page_count, type: :integer)
    remove_column(:books, :minutes, type: :integer)
    remove_column(:books, :store_url, type: :string)
    remove_column(:books, :sample_url, type: :string)
    remove_column(:books, :audio_url, type: :string)
    remove_column(:books, :book_author_id, type: :string)
  end
end
