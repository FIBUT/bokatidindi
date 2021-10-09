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

ActiveRecord::Schema.define(version: 2021_09_16_174837) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "author_types", force: :cascade do |t|
    t.integer "source_id"
    t.string "name", collation: "is_IS.UTF8"
    t.string "slug"
    t.integer "rod"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_author_types_on_slug", unique: true
    t.index ["source_id"], name: "index_author_types_on_source_id", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.integer "source_id"
    t.string "firstname", collation: "is_IS.UTF8"
    t.string "lastname", collation: "is_IS.UTF8"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_authors_on_slug", unique: true
    t.index ["source_id"], name: "index_authors_on_source_id", unique: true
  end

  create_table "binding_types", force: :cascade do |t|
    t.integer "source_id"
    t.string "name", collation: "is_IS.UTF8"
    t.string "slug", collation: "is_IS.UTF8"
    t.integer "rod"
    t.boolean "open"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_binding_types_on_name", unique: true
    t.index ["slug"], name: "index_binding_types_on_slug", unique: true
    t.index ["source_id"], name: "index_binding_types_on_source_id", unique: true
  end

  create_table "book_authors", force: :cascade do |t|
    t.integer "source_id"
    t.bigint "book_id"
    t.bigint "author_id"
    t.bigint "author_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_book_authors_on_author_id"
    t.index ["author_type_id"], name: "index_book_authors_on_author_type_id"
    t.index ["book_id"], name: "index_book_authors_on_book_id"
    t.index ["source_id"], name: "index_book_authors_on_source_id", unique: true
  end

  create_table "book_binding_types", force: :cascade do |t|
    t.string "barcode"
    t.bigint "book_id"
    t.bigint "binding_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["barcode"], name: "index_book_binding_types_on_barcode"
    t.index ["binding_type_id"], name: "index_book_binding_types_on_binding_type_id"
    t.index ["book_id"], name: "index_book_binding_types_on_book_id"
  end

  create_table "book_categories", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_book_categories_on_book_id"
    t.index ["category_id"], name: "index_book_categories_on_category_id"
  end

  create_table "books", force: :cascade do |t|
    t.integer "source_id"
    t.string "pre_title", collation: "is_IS.UTF8"
    t.string "title", collation: "is_IS.UTF8"
    t.string "post_title", collation: "is_IS.UTF8"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_author_id"], name: "index_books_on_book_author_id"
    t.index ["publisher_id"], name: "index_books_on_publisher_id"
    t.index ["slug"], name: "index_books_on_slug", unique: true
    t.index ["source_id"], name: "index_books_on_source_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.integer "source_id"
    t.string "name", collation: "is_IS.UTF8"
    t.string "slug"
    t.integer "rod"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.index ["source_id"], name: "index_categories_on_source_id", unique: true
  end

  create_table "publishers", force: :cascade do |t|
    t.integer "source_id"
    t.string "name", collation: "is_IS.UTF8"
    t.string "slug"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_publishers_on_slug", unique: true
    t.index ["source_id"], name: "index_publishers_on_source_id", unique: true
  end

  add_foreign_key "book_authors", "author_types"
  add_foreign_key "book_authors", "authors"
end
