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

ActiveRecord::Schema[8.0].define(version: 2025_07_17_154838) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

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
    t.index ["admin_user_id"], name: "index_admin_user_publishers_on_admin_user_id"
    t.index ["publisher_id"], name: "index_admin_user_publishers_on_publisher_id"
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
    t.string "name"
    t.string "slug"
    t.integer "rod"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "abbreviation"
    t.string "plural_name"
    t.integer "schema_role", default: 0
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
    t.boolean "is_icelandic"
    t.string "order_by_name"
    t.string "name"
    t.integer "added_by_id"
    t.integer "schema_type", default: 0, null: false
    t.index ["is_icelandic"], name: "index_authors_on_is_icelandic"
    t.index ["order_by_name"], name: "index_authors_on_order_by_name"
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
    t.integer "group", default: 0, null: false
    t.integer "barcode_type", default: 0
    t.index ["name"], name: "index_binding_types_on_name", unique: true
    t.index ["slug"], name: "index_binding_types_on_slug", unique: true
    t.index ["source_id"], name: "index_binding_types_on_source_id", unique: true
  end

  create_table "blockquotes", force: :cascade do |t|
    t.string "quote", limit: 512
    t.string "citation", limit: 63
    t.integer "location", default: 0
    t.integer "size", default: 0
    t.bigint "book_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "heading", limit: 128
    t.integer "quote_type", default: 0
    t.index ["book_id"], name: "index_blockquotes_on_book_id"
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
    t.integer "availability", default: 0, null: false
    t.date "publication_date"
    t.index ["barcode"], name: "index_book_binding_types_on_barcode"
    t.index ["binding_type_id"], name: "index_book_binding_types_on_binding_type_id"
    t.index ["book_id"], name: "index_book_binding_types_on_book_id"
    t.index ["language"], name: "index_book_binding_types_on_language"
  end

  create_table "book_categories", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "for_print", default: true, null: false
    t.boolean "for_web", default: true, null: false
    t.index ["book_id"], name: "index_book_categories_on_book_id"
    t.index ["category_id"], name: "index_book_categories_on_category_id"
    t.index ["for_print"], name: "index_book_categories_on_for_print"
    t.index ["for_web"], name: "index_book_categories_on_for_web"
  end

  create_table "book_edition_categories", force: :cascade do |t|
    t.integer "book_edition_id"
    t.integer "category_id"
    t.boolean "for_web", default: true, null: false
    t.boolean "for_print", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "invoiced", default: false
    t.string "dk_invoice_number"
    t.index ["invoiced"], name: "index_book_edition_categories_on_invoiced"
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
    t.json "cover_image_srcsets"
    t.json "sample_pages_srcsets"
    t.string "original_language", limit: 2
    t.index ["country_of_origin"], name: "index_books_on_country_of_origin"
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
    t.integer "group"
    t.string "name"
    t.integer "book_count"
    t.integer "book_count_web"
    t.integer "book_count_print"
    t.index ["group"], name: "index_categories_on_group"
    t.index ["rod"], name: "index_categories_on_rod"
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
    t.json "cover_image_srcsets", default: {"webp" => "", "jpg" => ""}
    t.boolean "is_legacy"
    t.integer "year"
    t.boolean "online", default: false
    t.boolean "open_to_web_registrations", default: false
    t.boolean "open_to_print_registrations", default: false
    t.index ["closing_date"], name: "index_editions_on_closing_date"
    t.index ["online"], name: "index_editions_on_online"
    t.index ["online_date"], name: "index_editions_on_online_date"
    t.index ["open_to_print_registrations"], name: "index_editions_on_open_to_print_registrations"
    t.index ["open_to_web_registrations"], name: "index_editions_on_open_to_web_registrations"
    t.index ["opening_date"], name: "index_editions_on_opening_date"
    t.index ["print_date"], name: "index_editions_on_print_date"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
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
    t.string "title"
    t.text "body"
    t.string "slug"
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
    t.string "email_address"
    t.string "kennitala"
    t.boolean "is_member", default: true
    t.integer "schema_type", default: 1, null: false
    t.index ["kennitala"], name: "index_publishers_on_kennitala"
    t.index ["slug"], name: "index_publishers_on_slug", unique: true
    t.index ["source_id"], name: "index_publishers_on_source_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_user_publishers", "admin_users"
  add_foreign_key "admin_user_publishers", "publishers"
  add_foreign_key "authors", "admin_users", column: "added_by_id"
  add_foreign_key "book_authors", "author_types"
  add_foreign_key "book_authors", "authors"
  add_foreign_key "book_authors", "books"
  add_foreign_key "book_binding_types", "binding_types"
  add_foreign_key "book_binding_types", "books"
  add_foreign_key "book_categories", "books"
  add_foreign_key "book_categories", "categories"
  add_foreign_key "book_editions", "books"
  add_foreign_key "book_editions", "editions"
  add_foreign_key "books", "publishers"
end
