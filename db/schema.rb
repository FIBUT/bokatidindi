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

ActiveRecord::Schema[7.0].define(version: 2022_05_01_202915) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "author_types", force: :cascade do |t|
    t.integer "source_id"
    t.string "name"
    t.string "slug"
    t.integer "rod"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_author_types_on_slug", unique: true
    t.index ["source_id"], name: "index_author_types_on_source_id", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.integer "source_id"
    t.string "firstname"
    t.string "lastname"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_authors_on_slug", unique: true
    t.index ["source_id"], name: "index_authors_on_source_id", unique: true
  end

  create_table "binding_types", force: :cascade do |t|
    t.integer "source_id"
    t.string "name"
    t.string "slug"
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
    t.string "pre_title"
    t.string "title"
    t.string "post_title"
    t.string "slug"
    t.string "description"
    t.string "long_description"
    t.integer "page_count"
    t.integer "minutes"
    t.string "store_url"
    t.string "sample_url"
    t.string "audio_url"
    t.bigint "publisher_id"
    t.bigint "book_author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uri_to_buy"
    t.string "uri_to_sample"
    t.string "uri_to_audiobook"
    t.string "title_noshy"
    t.index ["book_author_id"], name: "index_books_on_book_author_id"
    t.index ["publisher_id"], name: "index_books_on_publisher_id"
    t.index ["slug"], name: "index_books_on_slug", unique: true
    t.index ["source_id"], name: "index_books_on_source_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.integer "source_id"
    t.string "origin_name"
    t.string "slug"
    t.integer "rod"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.index ["source_id"], name: "index_categories_on_source_id", unique: true
  end

  create_table "editions", force: :cascade do |t|
    t.string "title"
    t.string "original_title_id_string"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "name"
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
