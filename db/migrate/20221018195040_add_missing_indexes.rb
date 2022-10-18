# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :admin_user_publishers, :admin_users
    add_foreign_key :admin_user_publishers, :publishers
    add_index :admin_user_publishers, :admin_user_id
    add_index :admin_user_publishers, :publisher_id

    add_index :authors, :gender

    add_foreign_key :book_authors, :books

    add_foreign_key :book_binding_types, :books
    add_foreign_key :book_binding_types, :binding_types
    add_index :book_binding_types, :language

    add_foreign_key :book_categories, :books
    add_foreign_key :book_categories, :categories
    add_index :book_categories, :for_print
    add_index :book_categories, :for_web

    add_foreign_key :book_editions, :books
    add_foreign_key :book_editions, :editions

    add_foreign_key :books, :publishers
    add_index :books, :country_of_origin

    add_index :editions, :print_date
    add_index :editions, :closing_date
    add_index :editions, :opening_date
    add_index :editions, :online_date
  end
end
