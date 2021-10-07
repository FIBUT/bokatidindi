class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :publishers do |t|
      t.integer :source_id, index: { unique: true }

      t.string :name, collation: 'is_IS.utf8'
      t.string :slug, index: { unique: true }
      t.string :url

      t.timestamps
    end

    create_table :categories do |t|
      t.integer :source_id, index: { unique: true }

      t.string :name, collation: 'is_IS.utf8'
      t.string :slug, index: { unique: true }
      t.integer :rod

      t.timestamps
    end

    create_table :books do |t|
      t.integer :source_id, index: { unique: true }

      t.string :pre_title, collation: 'is_IS.utf8'
      t.string :title, collation: 'is_IS.utf8'
      t.string :post_title, collation: 'is_IS.utf8'
      t.string :slug, index: { unique: true }

      t.string :description
      t.string :long_description

      t.integer :page_count
      t.integer :minutes

      t.string :store_url
      t.string :sample_url
      t.string :audio_url

      t.belongs_to :publisher, index: true
      t.belongs_to :book_author, index: true
  
      t.timestamps
    end

    create_table :book_categories do |t|
      t.belongs_to :book
      t.belongs_to :category

      t.timestamps
    end

    create_table :binding_types do |t|
      t.integer :source_id, index: { unique: true }
  
      t.string :name, collation: 'is_IS.utf8', index: { unique: true }
      t.string :slug, collation: 'is_IS.utf8', index: { unique: true }
      t.integer :rod
      t.boolean :open

      t.timestamps
    end

    create_table :book_binding_types do |t|
      t.string :barcode, index: true
      t.belongs_to :book, index: true
      t.belongs_to :binding_type, index: true

      t.timestamps
    end

    create_table :authors do |t|
      t.integer :source_id, index: { unique: true }

      t.string :firstname, collation: 'is_IS.utf8'
      t.string :lastname, collation: 'is_IS.utf8'
      t.string :slug, index: { unique: true }

      t.timestamps
    end

    create_table :author_types do |t|
      t.integer :source_id, index: { unique: true }

      t.string :name, collation: 'is_IS.utf8'
      t.string :slug, index: { unique: true }
      t.integer :rod

      t.timestamps
    end

    create_table :book_authors do |t|
      t.integer :source_id, index: { unique: true }

      t.belongs_to :book

      t.belongs_to :author, index: true,  foreign_key: true
      t.belongs_to :author_type, index: true, foreign_key: true

      t.timestamps
    end
  end
end
