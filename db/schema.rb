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

ActiveRecord::Schema[8.1].define(version: 2026_04_21_191300) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_user_publishers", force: :cascade do |t|
    t.integer "admin_user_id"
    t.datetime "created_at", null: false
    t.integer "publisher_id"
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_admin_user_publishers_on_admin_user_id"
    t.index ["publisher_id"], name: "index_admin_user_publishers_on_publisher_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true
  end

  create_table "author_types", force: :cascade do |t|
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "plural_name"
    t.integer "rod"
    t.integer "schema_role", default: 0
    t.string "slug"
    t.integer "source_id"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_author_types_on_slug", unique: true
    t.index ["source_id"], name: "index_author_types_on_source_id", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.integer "added_by_id"
    t.integer "birthyear"
    t.datetime "created_at", null: false
    t.string "firstname"
    t.boolean "is_icelandic"
    t.string "lastname"
    t.string "name"
    t.string "order_by_name"
    t.integer "schema_type", default: 0, null: false
    t.string "slug"
    t.integer "source_id"
    t.datetime "updated_at", null: false
    t.index ["is_icelandic"], name: "index_authors_on_is_icelandic"
    t.index ["order_by_name"], name: "index_authors_on_order_by_name"
    t.index ["slug"], name: "index_authors_on_slug", unique: true
    t.index ["source_id"], name: "index_authors_on_source_id", unique: true
  end

  create_table "binding_types", force: :cascade do |t|
    t.integer "barcode_type", default: 0
    t.datetime "created_at", null: false
    t.integer "group", default: 0, null: false
    t.string "name"
    t.boolean "open"
    t.integer "rod"
    t.string "slug"
    t.integer "source_id"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_binding_types_on_name", unique: true
    t.index ["slug"], name: "index_binding_types_on_slug", unique: true
    t.index ["source_id"], name: "index_binding_types_on_source_id", unique: true
  end

  create_table "blockquotes", force: :cascade do |t|
    t.bigint "book_id"
    t.string "citation", limit: 63
    t.datetime "created_at", null: false
    t.string "heading", limit: 128
    t.integer "location", default: 0
    t.string "quote", limit: 512
    t.integer "quote_type", default: 0
    t.integer "size", default: 0
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_blockquotes_on_book_id"
  end

  create_table "book_authors", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "author_type_id"
    t.bigint "book_id"
    t.datetime "created_at", null: false
    t.integer "source_id"
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_book_authors_on_author_id"
    t.index ["author_type_id"], name: "index_book_authors_on_author_type_id"
    t.index ["book_id"], name: "index_book_authors_on_book_id"
    t.index ["source_id"], name: "index_book_authors_on_source_id", unique: true
  end

  create_table "book_binding_types", force: :cascade do |t|
    t.integer "availability", default: 0, null: false
    t.string "barcode"
    t.bigint "binding_type_id"
    t.bigint "book_id"
    t.datetime "created_at", null: false
    t.string "language", limit: 2, default: "is", null: false
    t.integer "minutes"
    t.integer "page_count"
    t.date "publication_date"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["barcode"], name: "index_book_binding_types_on_barcode"
    t.index ["binding_type_id"], name: "index_book_binding_types_on_binding_type_id"
    t.index ["book_id"], name: "index_book_binding_types_on_book_id"
    t.index ["language"], name: "index_book_binding_types_on_language"
  end

  create_table "book_categories", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.boolean "for_print", default: true, null: false
    t.boolean "for_web", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_categories_on_book_id"
    t.index ["category_id"], name: "index_book_categories_on_category_id"
    t.index ["for_print"], name: "index_book_categories_on_for_print"
    t.index ["for_web"], name: "index_book_categories_on_for_web"
  end

  create_table "book_edition_categories", force: :cascade do |t|
    t.integer "book_edition_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.string "dk_invoice_number"
    t.boolean "for_print", default: true, null: false
    t.boolean "for_web", default: true, null: false
    t.boolean "invoiced", default: false
    t.datetime "updated_at", null: false
    t.index ["invoiced"], name: "index_book_edition_categories_on_invoiced"
  end

  create_table "book_editions", force: :cascade do |t|
    t.bigint "book_id"
    t.datetime "created_at", null: false
    t.bigint "edition_id"
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_editions_on_book_id"
    t.index ["edition_id"], name: "index_book_editions_on_edition_id"
  end

  create_table "book_tags", force: :cascade do |t|
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "books", force: :cascade do |t|
    t.string "country_of_origin"
    t.json "cover_image_srcsets"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "long_description"
    t.string "original_language", limit: 2
    t.string "original_title"
    t.string "post_title"
    t.string "pre_title"
    t.bigint "publisher_id"
    t.json "sample_pages_srcsets"
    t.string "slug"
    t.integer "source_id"
    t.string "title"
    t.string "title_hypenated"
    t.string "title_noshy"
    t.datetime "updated_at", null: false
    t.string "uri_to_audiobook"
    t.string "uri_to_buy"
    t.string "uri_to_sample"
    t.index ["country_of_origin"], name: "index_books_on_country_of_origin"
    t.index ["publisher_id"], name: "index_books_on_publisher_id"
    t.index ["slug"], name: "index_books_on_slug", unique: true
    t.index ["source_id"], name: "index_books_on_source_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.integer "book_count"
    t.integer "book_count_print"
    t.integer "book_count_web"
    t.datetime "created_at", null: false
    t.string "description", limit: 160, default: ""
    t.integer "group"
    t.string "name"
    t.string "origin_name"
    t.integer "rod"
    t.string "slug"
    t.integer "source_id"
    t.datetime "updated_at", null: false
    t.index ["group"], name: "index_categories_on_group"
    t.index ["rod"], name: "index_categories_on_rod"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.index ["source_id"], name: "index_categories_on_source_id", unique: true
  end

  create_table "editions", force: :cascade do |t|
    t.datetime "closing_date"
    t.json "cover_image_srcsets", default: {"webp" => "", "jpg" => ""}
    t.datetime "created_at", null: false
    t.boolean "is_legacy"
    t.boolean "online", default: false
    t.datetime "online_date"
    t.boolean "open_to_print_registrations", default: false
    t.boolean "open_to_web_registrations", default: false
    t.datetime "opening_date"
    t.string "original_title_id_string"
    t.datetime "print_date"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["closing_date"], name: "index_editions_on_closing_date"
    t.index ["online"], name: "index_editions_on_online"
    t.index ["online_date"], name: "index_editions_on_online_date"
    t.index ["open_to_print_registrations"], name: "index_editions_on_open_to_print_registrations"
    t.index ["open_to_web_registrations"], name: "index_editions_on_open_to_web_registrations"
    t.index ["opening_date"], name: "index_editions_on_opening_date"
    t.index ["print_date"], name: "index_editions_on_print_date"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "pages", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "searchable_id"
    t.string "searchable_type"
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "print_locations", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.integer "region", default: 1, null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true
  end

  create_table "publishers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address"
    t.boolean "is_member", default: true
    t.string "kennitala"
    t.string "name"
    t.integer "schema_type", default: 1, null: false
    t.string "slug"
    t.integer "source_id"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["kennitala"], name: "index_publishers_on_kennitala"
    t.index ["slug"], name: "index_publishers_on_slug", unique: true
    t.index ["source_id"], name: "index_publishers_on_source_id", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.integer "rod", default: 0, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.string "title_plural", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_tags_on_title"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_user_publishers", "admin_users"
  add_foreign_key "admin_user_publishers", "publishers"
  add_foreign_key "book_authors", "author_types"
  add_foreign_key "book_authors", "authors"
  add_foreign_key "book_authors", "books"
  add_foreign_key "book_binding_types", "binding_types"
  add_foreign_key "book_binding_types", "books"
  add_foreign_key "book_categories", "books"
  add_foreign_key "book_categories", "categories"
  add_foreign_key "book_editions", "books"
  add_foreign_key "book_editions", "editions"
  add_foreign_key "book_tags", "books"
  add_foreign_key "book_tags", "tags"
  add_foreign_key "books", "publishers"
end
