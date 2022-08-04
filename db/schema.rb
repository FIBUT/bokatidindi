# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_08_03_232703) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_user_publishers", force: :cascade do |t|
    t.integer "admin_user_id"
    t.integer "publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true
  end

  create_table "author_types", force: :cascade do |t|
    t.integer "source_id"
    t.string "name", collation: "is_IS"
    t.string "slug"
    t.integer "rod"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_author_types_on_slug", unique: true
    t.index ["source_id"], name: "index_author_types_on_source_id", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.integer "source_id"
    t.string "firstname", collation: "is_IS"
    t.string "lastname", collation: "is_IS"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_icelandic"
    t.string "order_by_name", collation: "is_IS"
    t.integer "gender"
    t.index ["is_icelandic"], name: "index_authors_on_is_icelandic"
    t.index ["order_by_name"], name: "index_authors_on_order_by_name"
    t.index ["slug"], name: "index_authors_on_slug", unique: true
    t.index ["source_id"], name: "index_authors_on_source_id", unique: true
  end

  create_table "binding_types", force: :cascade do |t|
    t.integer "source_id"
    t.string "name", collation: "is_IS"
    t.string "slug", collation: "is_IS"
    t.integer "rod"
    t.boolean "open"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_binding_types_on_name", unique: true
    t.index ["slug"], name: "index_binding_types_on_slug", unique: true
    t.index ["source_id"], name: "index_binding_types_on_source_id", unique: true
  end

  create_table "book_authors", force: :cascade do |t|
    t.integer "source_id"
    t.bigint "book_id"
    t.bigint "author_id"
    t.bigint "author_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_book_authors_on_author_id"
    t.index ["author_type_id"], name: "index_book_authors_on_author_type_id"
    t.index ["book_id"], name: "index_book_authors_on_book_id"
    t.index ["source_id"], name: "index_book_authors_on_source_id", unique: true
  end

  create_table "book_binding_types", force: :cascade do |t|
    t.string "barcode"
    t.bigint "book_id"
    t.bigint "binding_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language", limit: 2, default: "is", null: false
    t.string "url"
    t.integer "page_count"
    t.integer "minutes"
    t.index ["barcode"], name: "index_book_binding_types_on_barcode"
    t.index ["binding_type_id"], name: "index_book_binding_types_on_binding_type_id"
    t.index ["book_id"], name: "index_book_binding_types_on_book_id"
  end

  create_table "book_categories", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_categories_on_book_id"
    t.index ["category_id"], name: "index_book_categories_on_category_id"
  end

  create_table "book_editions", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "edition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_editions_on_book_id"
    t.index ["edition_id"], name: "index_book_editions_on_edition_id"
  end

  create_table "books", force: :cascade do |t|
    t.integer "source_id"
    t.string "pre_title", collation: "is_IS"
    t.string "title", collation: "is_IS"
    t.string "post_title", collation: "is_IS"
    t.string "slug"
    t.string "description"
    t.string "long_description"
    t.bigint "publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uri_to_buy"
    t.string "uri_to_sample"
    t.string "uri_to_audiobook"
    t.string "title_noshy"
    t.string "title_hypenated"
    t.string "country_of_origin"
    t.string "original_title"
    t.index ["publisher_id"], name: "index_books_on_publisher_id"
    t.index ["slug"], name: "index_books_on_slug", unique: true
    t.index ["source_id"], name: "index_books_on_source_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.integer "source_id"
    t.string "origin_name", collation: "is_IS"
    t.string "slug"
    t.integer "rod"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group"
    t.string "name"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.index ["source_id"], name: "index_categories_on_source_id", unique: true
  end

  create_table "editions", force: :cascade do |t|
    t.string "title"
    t.string "original_title_id_string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "print_date"
    t.datetime "closing_date"
    t.datetime "opening_date"
    t.datetime "online_date"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "publishers", force: :cascade do |t|
    t.integer "source_id"
    t.string "name", collation: "is_IS"
    t.string "slug"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_publishers_on_slug", unique: true
    t.index ["source_id"], name: "index_publishers_on_source_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "book_authors", "author_types"
  add_foreign_key "book_authors", "authors"
end
