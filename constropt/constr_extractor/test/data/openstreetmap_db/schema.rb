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

ActiveRecord::Schema[7.0].define(version: 2022_02_23_140543) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "format_enum", ["html", "markdown", "text"]
  create_enum "gpx_visibility_enum", ["private", "public", "trackable", "identifiable"]
  create_enum "issue_status_enum", ["open", "ignored", "resolved"]
  create_enum "note_event_enum", ["opened", "closed", "reopened", "commented", "hidden"]
  create_enum "note_status_enum", ["open", "closed", "hidden"]
  create_enum "nwr_enum", ["Node", "Way", "Relation"]
  create_enum "user_role_enum", ["administrator", "moderator"]
  create_enum "user_status_enum", ["pending", "active", "confirmed", "suspended", "deleted"]

  create_table "acls", force: :cascade do |t|
    t.inet "address"
    t.string "k", null: false
    t.string "v"
    t.string "domain"
    t.string "mx"
    t.index ["address"], name: "index_acls_on_address", opclass: :inet_ops, using: :gist
    t.index ["domain"], name: "index_acls_on_domain"
    t.index ["k"], name: "acls_k_idx"
    t.index ["mx"], name: "index_acls_on_mx"
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
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "changeset_comments", id: :serial, force: :cascade do |t|
    t.bigint "changeset_id", null: false
    t.bigint "author_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: nil, null: false
    t.boolean "visible", null: false
    t.index ["changeset_id", "created_at"], name: "index_changeset_comments_on_changeset_id_and_created_at"
    t.index ["created_at"], name: "index_changeset_comments_on_created_at"
  end

  create_table "changeset_tags", id: false, force: :cascade do |t|
    t.bigint "changeset_id", null: false
    t.string "k", default: "", null: false
    t.string "v", default: "", null: false
    t.index ["changeset_id"], name: "changeset_tags_id_idx"
  end

  create_table "changesets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "min_lat"
    t.integer "max_lat"
    t.integer "min_lon"
    t.integer "max_lon"
    t.datetime "closed_at", precision: nil, null: false
    t.integer "num_changes", default: 0, null: false
    t.index ["closed_at"], name: "changesets_closed_at_idx"
    t.index ["created_at"], name: "changesets_created_at_idx"
    t.index ["min_lat", "max_lat", "min_lon", "max_lon"], name: "changesets_bbox_idx", using: :gist
    t.index ["user_id", "created_at"], name: "changesets_user_id_created_at_idx"
    t.index ["user_id", "id"], name: "changesets_user_id_id_idx"
  end

  create_table "changesets_subscribers", id: false, force: :cascade do |t|
    t.bigint "subscriber_id", null: false
    t.bigint "changeset_id", null: false
    t.index ["changeset_id"], name: "index_changesets_subscribers_on_changeset_id"
    t.index ["subscriber_id", "changeset_id"], name: "index_changesets_subscribers_on_subscriber_id_and_changeset_id", unique: true
  end

  create_table "client_applications", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "support_url"
    t.string "callback_url"
    t.string "key", limit: 50
    t.string "secret", limit: 50
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "allow_read_prefs", default: false, null: false
    t.boolean "allow_write_prefs", default: false, null: false
    t.boolean "allow_write_diary", default: false, null: false
    t.boolean "allow_write_api", default: false, null: false
    t.boolean "allow_read_gpx", default: false, null: false
    t.boolean "allow_write_gpx", default: false, null: false
    t.boolean "allow_write_notes", default: false, null: false
    t.index ["key"], name: "index_client_applications_on_key", unique: true
    t.index ["user_id"], name: "index_client_applications_on_user_id"
  end

  create_table "current_node_tags", primary_key: ["node_id", "k"], force: :cascade do |t|
    t.bigint "node_id", null: false
    t.string "k", default: "", null: false
    t.string "v", default: "", null: false
  end

  create_table "current_nodes", force: :cascade do |t|
    t.integer "latitude", null: false
    t.integer "longitude", null: false
    t.bigint "changeset_id", null: false
    t.boolean "visible", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.bigint "tile", null: false
    t.bigint "version", null: false
    t.index ["tile"], name: "current_nodes_tile_idx"
    t.index ["timestamp"], name: "current_nodes_timestamp_idx"
  end

  create_table "current_relation_members", primary_key: ["relation_id", "member_type", "member_id", "member_role", "sequence_id"], force: :cascade do |t|
    t.bigint "relation_id", null: false
    t.enum "member_type", null: false, enum_type: "nwr_enum"
    t.bigint "member_id", null: false
    t.string "member_role", null: false
    t.integer "sequence_id", default: 0, null: false
    t.index ["member_type", "member_id"], name: "current_relation_members_member_idx"
  end

  create_table "current_relation_tags", primary_key: ["relation_id", "k"], force: :cascade do |t|
    t.bigint "relation_id", null: false
    t.string "k", default: "", null: false
    t.string "v", default: "", null: false
  end

  create_table "current_relations", force: :cascade do |t|
    t.bigint "changeset_id", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.boolean "visible", null: false
    t.bigint "version", null: false
    t.index ["timestamp"], name: "current_relations_timestamp_idx"
  end

  create_table "current_way_nodes", primary_key: ["way_id", "sequence_id"], force: :cascade do |t|
    t.bigint "way_id", null: false
    t.bigint "node_id", null: false
    t.bigint "sequence_id", null: false
    t.index ["node_id"], name: "current_way_nodes_node_idx"
  end

  create_table "current_way_tags", primary_key: ["way_id", "k"], force: :cascade do |t|
    t.bigint "way_id", null: false
    t.string "k", default: "", null: false
    t.string "v", default: "", null: false
  end

  create_table "current_ways", force: :cascade do |t|
    t.bigint "changeset_id", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.boolean "visible", null: false
    t.bigint "version", null: false
    t.index ["timestamp"], name: "current_ways_timestamp_idx"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "diary_comments", force: :cascade do |t|
    t.bigint "diary_entry_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "visible", default: true, null: false
    t.enum "body_format", default: "markdown", null: false, enum_type: "format_enum"
    t.index ["diary_entry_id", "id"], name: "diary_comments_entry_id_idx", unique: true
    t.index ["user_id", "created_at"], name: "diary_comment_user_id_created_at_index"
  end

  create_table "diary_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.float "latitude"
    t.float "longitude"
    t.string "language_code", default: "en", null: false
    t.boolean "visible", default: true, null: false
    t.enum "body_format", default: "markdown", null: false, enum_type: "format_enum"
    t.index ["created_at"], name: "diary_entry_created_at_index"
    t.index ["language_code", "created_at"], name: "diary_entry_language_code_created_at_index"
    t.index ["user_id", "created_at"], name: "diary_entry_user_id_created_at_index"
  end

  create_table "diary_entry_subscriptions", primary_key: ["user_id", "diary_entry_id"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "diary_entry_id", null: false
    t.index ["diary_entry_id"], name: "index_diary_entry_subscriptions_on_diary_entry_id"
  end

  create_table "friends", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "friend_user_id", null: false
    t.datetime "created_at", precision: nil
    t.index ["friend_user_id"], name: "user_id_idx"
    t.index ["user_id", "created_at"], name: "index_friends_on_user_id_and_created_at"
  end

  create_table "gps_points", id: false, force: :cascade do |t|
    t.float "altitude"
    t.integer "trackid", null: false
    t.integer "latitude", null: false
    t.integer "longitude", null: false
    t.bigint "gpx_id", null: false
    t.datetime "timestamp", precision: nil
    t.bigint "tile"
    t.index ["gpx_id"], name: "points_gpxid_idx"
    t.index ["tile"], name: "points_tile_idx"
  end

  create_table "gpx_file_tags", force: :cascade do |t|
    t.bigint "gpx_id", null: false
    t.string "tag", null: false
    t.index ["gpx_id"], name: "gpx_file_tags_gpxid_idx"
    t.index ["tag"], name: "gpx_file_tags_tag_idx"
  end

  create_table "gpx_files", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "visible", default: true, null: false
    t.string "name", default: "", null: false
    t.bigint "size"
    t.float "latitude"
    t.float "longitude"
    t.datetime "timestamp", precision: nil, null: false
    t.string "description", default: "", null: false
    t.boolean "inserted", null: false
    t.enum "visibility", default: "public", null: false, enum_type: "gpx_visibility_enum"
    t.index ["timestamp"], name: "gpx_files_timestamp_idx"
    t.index ["user_id"], name: "gpx_files_user_id_idx"
    t.index ["visible", "visibility"], name: "gpx_files_visible_visibility_idx"
  end

  create_table "issue_comments", id: :serial, force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["issue_id"], name: "index_issue_comments_on_issue_id"
    t.index ["user_id"], name: "index_issue_comments_on_user_id"
  end

  create_table "issues", id: :serial, force: :cascade do |t|
    t.string "reportable_type", null: false
    t.integer "reportable_id", null: false
    t.integer "reported_user_id"
    t.enum "status", default: "open", null: false, enum_type: "issue_status_enum"
    t.enum "assigned_role", null: false, enum_type: "user_role_enum"
    t.datetime "resolved_at", precision: nil
    t.integer "resolved_by"
    t.integer "updated_by"
    t.integer "reports_count", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["assigned_role"], name: "index_issues_on_assigned_role"
    t.index ["reportable_type", "reportable_id"], name: "index_issues_on_reportable_type_and_reportable_id"
    t.index ["reported_user_id"], name: "index_issues_on_reported_user_id"
    t.index ["status"], name: "index_issues_on_status"
    t.index ["updated_by"], name: "index_issues_on_updated_by"
  end

  create_table "languages", primary_key: "code", id: :string, force: :cascade do |t|
    t.string "english_name", null: false
    t.string "native_name"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "from_user_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.datetime "sent_on", precision: nil, null: false
    t.boolean "message_read", default: false, null: false
    t.bigint "to_user_id", null: false
    t.boolean "to_user_visible", default: true, null: false
    t.boolean "from_user_visible", default: true, null: false
    t.enum "body_format", default: "markdown", null: false, enum_type: "format_enum"
    t.index ["from_user_id"], name: "messages_from_user_id_idx"
    t.index ["to_user_id"], name: "messages_to_user_id_idx"
  end

  create_table "node_tags", primary_key: ["node_id", "version", "k"], force: :cascade do |t|
    t.bigint "node_id", null: false
    t.bigint "version", null: false
    t.string "k", default: "", null: false
    t.string "v", default: "", null: false
  end

  create_table "nodes", primary_key: ["node_id", "version"], force: :cascade do |t|
    t.bigint "node_id", null: false
    t.integer "latitude", null: false
    t.integer "longitude", null: false
    t.bigint "changeset_id", null: false
    t.boolean "visible", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.bigint "tile", null: false
    t.bigint "version", null: false
    t.integer "redaction_id"
    t.index ["changeset_id"], name: "nodes_changeset_id_idx"
    t.index ["tile"], name: "nodes_tile_idx"
    t.index ["timestamp"], name: "nodes_timestamp_idx"
  end

  create_table "note_comments", force: :cascade do |t|
    t.bigint "note_id", null: false
    t.boolean "visible", null: false
    t.datetime "created_at", precision: nil, null: false
    t.inet "author_ip"
    t.bigint "author_id"
    t.text "body"
    t.enum "event", enum_type: "note_event_enum"
    t.index "to_tsvector('english'::regconfig, body)", name: "index_note_comments_on_body", using: :gin
    t.index ["author_id", "created_at"], name: "index_note_comments_on_author_id_and_created_at"
    t.index ["created_at"], name: "index_note_comments_on_created_at"
    t.index ["note_id"], name: "note_comments_note_id_idx"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "latitude", null: false
    t.integer "longitude", null: false
    t.bigint "tile", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.enum "status", null: false, enum_type: "note_status_enum"
    t.datetime "closed_at", precision: nil
    t.index ["created_at"], name: "notes_created_at_idx"
    t.index ["tile", "status"], name: "notes_tile_status_idx"
    t.index ["updated_at"], name: "notes_updated_at_idx"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes", default: "", null: false
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_oauth_applications_on_owner_type_and_owner_id"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_nonces", force: :cascade do |t|
    t.string "nonce"
    t.integer "timestamp"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["nonce", "timestamp"], name: "index_oauth_nonces_on_nonce_and_timestamp", unique: true
  end

  create_table "oauth_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "type", limit: 20
    t.integer "client_application_id"
    t.string "token", limit: 50
    t.string "secret", limit: 50
    t.datetime "authorized_at", precision: nil
    t.datetime "invalidated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "allow_read_prefs", default: false, null: false
    t.boolean "allow_write_prefs", default: false, null: false
    t.boolean "allow_write_diary", default: false, null: false
    t.boolean "allow_write_api", default: false, null: false
    t.boolean "allow_read_gpx", default: false, null: false
    t.boolean "allow_write_gpx", default: false, null: false
    t.string "callback_url"
    t.string "verifier", limit: 20
    t.string "scope"
    t.datetime "valid_to", precision: nil
    t.boolean "allow_write_notes", default: false, null: false
    t.index ["token"], name: "index_oauth_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_oauth_tokens_on_user_id"
  end

  create_table "redactions", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.bigint "user_id", null: false
    t.enum "description_format", default: "markdown", null: false, enum_type: "format_enum"
  end

  create_table "relation_members", primary_key: ["relation_id", "version", "member_type", "member_id", "member_role", "sequence_id"], force: :cascade do |t|
    t.bigint "relation_id", null: false
    t.enum "member_type", null: false, enum_type: "nwr_enum"
    t.bigint "member_id", null: false
    t.string "member_role", null: false
    t.bigint "version", default: 0, null: false
    t.integer "sequence_id", default: 0, null: false
    t.index ["member_type", "member_id"], name: "relation_members_member_idx"
  end

  create_table "relation_tags", primary_key: ["relation_id", "version", "k"], force: :cascade do |t|
    t.bigint "relation_id", null: false
    t.string "k", default: "", null: false
    t.string "v", default: "", null: false
    t.bigint "version", null: false
  end

  create_table "relations", primary_key: ["relation_id", "version"], force: :cascade do |t|
    t.bigint "relation_id", null: false
    t.bigint "changeset_id", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.bigint "version", null: false
    t.boolean "visible", default: true, null: false
    t.integer "redaction_id"
    t.index ["changeset_id"], name: "relations_changeset_id_idx"
    t.index ["timestamp"], name: "relations_timestamp_idx"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "user_id", null: false
    t.text "details", null: false
    t.string "category", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["issue_id"], name: "index_reports_on_issue_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "user_blocks", id: :serial, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "creator_id", null: false
    t.text "reason", null: false
    t.datetime "ends_at", precision: nil, null: false
    t.boolean "needs_view", default: false, null: false
    t.bigint "revoker_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.enum "reason_format", default: "markdown", null: false, enum_type: "format_enum"
    t.index ["user_id"], name: "index_user_blocks_on_user_id"
  end

  create_table "user_preferences", primary_key: ["user_id", "k"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "k", null: false
    t.string "v", null: false
  end

  create_table "user_roles", id: :serial, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.enum "role", null: false, enum_type: "user_role_enum"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.bigint "granter_id", null: false
    t.index ["user_id", "role"], name: "user_roles_id_role_unique", unique: true
  end

  create_table "user_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "expiry", precision: nil, null: false
    t.text "referer"
    t.index ["token"], name: "user_tokens_token_idx", unique: true
    t.index ["user_id"], name: "user_tokens_user_id_idx"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "pass_crypt", null: false
    t.datetime "creation_time", precision: nil, null: false
    t.string "display_name", default: "", null: false
    t.boolean "data_public", default: false, null: false
    t.text "description", default: "", null: false
    t.float "home_lat"
    t.float "home_lon"
    t.integer "home_zoom", limit: 2, default: 3
    t.string "pass_salt"
    t.boolean "email_valid", default: false, null: false
    t.string "new_email"
    t.string "creation_ip"
    t.string "languages"
    t.enum "status", default: "pending", null: false, enum_type: "user_status_enum"
    t.datetime "terms_agreed", precision: nil
    t.boolean "consider_pd", default: false, null: false
    t.string "auth_uid"
    t.string "preferred_editor"
    t.boolean "terms_seen", default: false, null: false
    t.enum "description_format", default: "markdown", null: false, enum_type: "format_enum"
    t.integer "changesets_count", default: 0, null: false
    t.integer "traces_count", default: 0, null: false
    t.integer "diary_entries_count", default: 0, null: false
    t.boolean "image_use_gravatar", default: false, null: false
    t.string "auth_provider"
    t.bigint "home_tile"
    t.datetime "tou_agreed", precision: nil
    t.index "lower((display_name)::text)", name: "users_display_name_lower_idx"
    t.index "lower((email)::text)", name: "users_email_lower_idx"
    t.index ["auth_provider", "auth_uid"], name: "users_auth_idx", unique: true
    t.index ["display_name"], name: "users_display_name_idx", unique: true
    t.index ["email"], name: "users_email_idx", unique: true
    t.index ["home_tile"], name: "users_home_idx"
  end

  create_table "way_nodes", primary_key: ["way_id", "version", "sequence_id"], force: :cascade do |t|
    t.bigint "way_id", null: false
    t.bigint "node_id", null: false
    t.bigint "version", null: false
    t.bigint "sequence_id", null: false
    t.index ["node_id"], name: "way_nodes_node_idx"
  end

  create_table "way_tags", primary_key: ["way_id", "version", "k"], force: :cascade do |t|
    t.bigint "way_id", null: false
    t.string "k", null: false
    t.string "v", null: false
    t.bigint "version", null: false
  end

  create_table "ways", primary_key: ["way_id", "version"], force: :cascade do |t|
    t.bigint "way_id", null: false
    t.bigint "changeset_id", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.bigint "version", null: false
    t.boolean "visible", default: true, null: false
    t.integer "redaction_id"
    t.index ["changeset_id"], name: "ways_changeset_id_idx"
    t.index ["timestamp"], name: "ways_timestamp_idx"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "changeset_comments", "changesets", name: "changeset_comments_changeset_id_fkey"
  add_foreign_key "changeset_comments", "users", column: "author_id", name: "changeset_comments_author_id_fkey"
  add_foreign_key "changeset_tags", "changesets", name: "changeset_tags_id_fkey"
  add_foreign_key "changesets", "users", name: "changesets_user_id_fkey"
  add_foreign_key "changesets_subscribers", "changesets", name: "changesets_subscribers_changeset_id_fkey"
  add_foreign_key "changesets_subscribers", "users", column: "subscriber_id", name: "changesets_subscribers_subscriber_id_fkey"
  add_foreign_key "client_applications", "users", name: "client_applications_user_id_fkey"
  add_foreign_key "current_node_tags", "current_nodes", column: "node_id", name: "current_node_tags_id_fkey"
  add_foreign_key "current_nodes", "changesets", name: "current_nodes_changeset_id_fkey"
  add_foreign_key "current_relation_members", "current_relations", column: "relation_id", name: "current_relation_members_id_fkey"
  add_foreign_key "current_relation_tags", "current_relations", column: "relation_id", name: "current_relation_tags_id_fkey"
  add_foreign_key "current_relations", "changesets", name: "current_relations_changeset_id_fkey"
  add_foreign_key "current_way_nodes", "current_nodes", column: "node_id", name: "current_way_nodes_node_id_fkey"
  add_foreign_key "current_way_nodes", "current_ways", column: "way_id", name: "current_way_nodes_id_fkey"
  add_foreign_key "current_way_tags", "current_ways", column: "way_id", name: "current_way_tags_id_fkey"
  add_foreign_key "current_ways", "changesets", name: "current_ways_changeset_id_fkey"
  add_foreign_key "diary_comments", "diary_entries", name: "diary_comments_diary_entry_id_fkey"
  add_foreign_key "diary_comments", "users", name: "diary_comments_user_id_fkey"
  add_foreign_key "diary_entries", "languages", column: "language_code", primary_key: "code", name: "diary_entries_language_code_fkey"
  add_foreign_key "diary_entries", "users", name: "diary_entries_user_id_fkey"
  add_foreign_key "diary_entry_subscriptions", "diary_entries", name: "diary_entry_subscriptions_diary_entry_id_fkey"
  add_foreign_key "diary_entry_subscriptions", "users", name: "diary_entry_subscriptions_user_id_fkey"
  add_foreign_key "friends", "users", column: "friend_user_id", name: "friends_friend_user_id_fkey"
  add_foreign_key "friends", "users", name: "friends_user_id_fkey"
  add_foreign_key "gps_points", "gpx_files", column: "gpx_id", name: "gps_points_gpx_id_fkey"
  add_foreign_key "gpx_file_tags", "gpx_files", column: "gpx_id", name: "gpx_file_tags_gpx_id_fkey"
  add_foreign_key "gpx_files", "users", name: "gpx_files_user_id_fkey"
  add_foreign_key "issue_comments", "issues", name: "issue_comments_issue_id_fkey"
  add_foreign_key "issue_comments", "users", name: "issue_comments_user_id_fkey"
  add_foreign_key "issues", "users", column: "reported_user_id", name: "issues_reported_user_id_fkey"
  add_foreign_key "issues", "users", column: "resolved_by", name: "issues_resolved_by_fkey"
  add_foreign_key "issues", "users", column: "updated_by", name: "issues_updated_by_fkey"
  add_foreign_key "messages", "users", column: "from_user_id", name: "messages_from_user_id_fkey"
  add_foreign_key "messages", "users", column: "to_user_id", name: "messages_to_user_id_fkey"
  add_foreign_key "node_tags", "nodes", primary_key: "node_id", name: "node_tags_id_fkey"
  add_foreign_key "nodes", "changesets", name: "nodes_changeset_id_fkey"
  add_foreign_key "nodes", "redactions", name: "nodes_redaction_id_fkey"
  add_foreign_key "note_comments", "notes", name: "note_comments_note_id_fkey"
  add_foreign_key "note_comments", "users", column: "author_id", name: "note_comments_author_id_fkey"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "oauth_applications", "users", column: "owner_id"
  add_foreign_key "oauth_tokens", "client_applications", name: "oauth_tokens_client_application_id_fkey"
  add_foreign_key "oauth_tokens", "users", name: "oauth_tokens_user_id_fkey"
  add_foreign_key "redactions", "users", name: "redactions_user_id_fkey"
  add_foreign_key "relation_members", "relations", primary_key: "relation_id", name: "relation_members_id_fkey"
  add_foreign_key "relation_tags", "relations", primary_key: "relation_id", name: "relation_tags_id_fkey"
  add_foreign_key "relations", "changesets", name: "relations_changeset_id_fkey"
  add_foreign_key "relations", "redactions", name: "relations_redaction_id_fkey"
  add_foreign_key "reports", "issues", name: "reports_issue_id_fkey"
  add_foreign_key "reports", "users", name: "reports_user_id_fkey"
  add_foreign_key "user_blocks", "users", column: "creator_id", name: "user_blocks_moderator_id_fkey"
  add_foreign_key "user_blocks", "users", column: "revoker_id", name: "user_blocks_revoker_id_fkey"
  add_foreign_key "user_blocks", "users", name: "user_blocks_user_id_fkey"
  add_foreign_key "user_preferences", "users", name: "user_preferences_user_id_fkey"
  add_foreign_key "user_roles", "users", column: "granter_id", name: "user_roles_granter_id_fkey"
  add_foreign_key "user_roles", "users", name: "user_roles_user_id_fkey"
  add_foreign_key "user_tokens", "users", name: "user_tokens_user_id_fkey"
  add_foreign_key "way_nodes", "ways", primary_key: "way_id", name: "way_nodes_id_fkey"
  add_foreign_key "way_tags", "ways", primary_key: "way_id", name: "way_tags_id_fkey"
  add_foreign_key "ways", "changesets", name: "ways_changeset_id_fkey"
  add_foreign_key "ways", "redactions", name: "ways_redaction_id_fkey"
end
