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

ActiveRecord::Schema.define(version: 2021_08_02_131421) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "allowed_pm_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "allowed_pm_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["allowed_pm_user_id", "user_id"], name: "index_allowed_pm_users_on_allowed_pm_user_id_and_user_id", unique: true
    t.index ["user_id", "allowed_pm_user_id"], name: "index_allowed_pm_users_on_user_id_and_allowed_pm_user_id", unique: true
  end

  create_table "anonymous_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "master_user_id", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["master_user_id"], name: "index_anonymous_users_on_master_user_id", unique: true, where: "active"
    t.index ["user_id"], name: "index_anonymous_users_on_user_id", unique: true
  end

  create_table "api_key_scopes", force: :cascade do |t|
    t.integer "api_key_id", null: false
    t.string "resource", null: false
    t.string "action", null: false
    t.json "allowed_parameters"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["api_key_id"], name: "index_api_key_scopes_on_api_key_id"
  end

  create_table "api_keys", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.inet "allowed_ips", array: true
    t.boolean "hidden", default: false, null: false
    t.datetime "last_used_at"
    t.datetime "revoked_at"
    t.text "description"
    t.string "key_hash", null: false
    t.string "truncated_key", null: false
    t.index ["key_hash"], name: "index_api_keys_on_key_hash"
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "application_requests", id: :serial, force: :cascade do |t|
    t.date "date", null: false
    t.integer "req_type", null: false
    t.integer "count", default: 0, null: false
    t.index ["date", "req_type"], name: "index_application_requests_on_date_and_req_type", unique: true
  end

  create_table "backup_draft_posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "post_id", null: false
    t.string "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_backup_draft_posts_on_post_id", unique: true
    t.index ["user_id", "key"], name: "index_backup_draft_posts_on_user_id_and_key", unique: true
  end

  create_table "backup_draft_topics", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["topic_id"], name: "index_backup_draft_topics_on_topic_id", unique: true
    t.index ["user_id"], name: "index_backup_draft_topics_on_user_id", unique: true
  end

  create_table "backup_metadata", force: :cascade do |t|
    t.string "name", null: false
    t.string "value"
  end

  create_table "badge_groupings", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badge_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_badge_types_on_name", unique: true
  end

  create_table "badges", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "badge_type_id", null: false
    t.integer "grant_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "allow_title", default: false, null: false
    t.boolean "multiple_grant", default: false, null: false
    t.string "icon", default: "fa-certificate"
    t.boolean "listable", default: true
    t.boolean "target_posts", default: false
    t.text "query"
    t.boolean "enabled", default: true, null: false
    t.boolean "auto_revoke", default: true, null: false
    t.integer "badge_grouping_id", default: 5, null: false
    t.integer "trigger"
    t.boolean "show_posts", default: false, null: false
    t.boolean "system", default: false, null: false
    t.string "image", limit: 255
    t.text "long_description"
    t.integer "image_upload_id"
    t.index ["badge_type_id"], name: "index_badges_on_badge_type_id"
    t.index ["name"], name: "index_badges_on_name", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "topic_id", null: false
    t.bigint "post_id", null: false
    t.string "name", limit: 100
    t.integer "reminder_type"
    t.datetime "reminder_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "reminder_last_sent_at"
    t.datetime "reminder_set_at"
    t.integer "auto_delete_preference", default: 0, null: false
    t.boolean "pinned", default: false
    t.index ["post_id"], name: "index_bookmarks_on_post_id"
    t.index ["reminder_at"], name: "index_bookmarks_on_reminder_at"
    t.index ["reminder_set_at"], name: "index_bookmarks_on_reminder_set_at"
    t.index ["reminder_type"], name: "index_bookmarks_on_reminder_type"
    t.index ["topic_id"], name: "index_bookmarks_on_topic_id"
    t.index ["user_id", "post_id"], name: "index_bookmarks_on_user_id_and_post_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "color", limit: 6, default: "0088CC", null: false
    t.integer "topic_id"
    t.integer "topic_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "topics_year", default: 0
    t.integer "topics_month", default: 0
    t.integer "topics_week", default: 0
    t.string "slug", null: false
    t.text "description"
    t.string "text_color", limit: 6, default: "FFFFFF", null: false
    t.boolean "read_restricted", default: false, null: false
    t.float "auto_close_hours"
    t.integer "post_count", default: 0, null: false
    t.integer "latest_post_id"
    t.integer "latest_topic_id"
    t.integer "position"
    t.integer "parent_category_id"
    t.integer "posts_year", default: 0
    t.integer "posts_month", default: 0
    t.integer "posts_week", default: 0
    t.string "email_in"
    t.boolean "email_in_allow_strangers", default: false
    t.integer "topics_day", default: 0
    t.integer "posts_day", default: 0
    t.boolean "allow_badges", default: true, null: false
    t.string "name_lower", limit: 50, null: false
    t.boolean "auto_close_based_on_last_post", default: false
    t.text "topic_template"
    t.boolean "contains_messages"
    t.string "sort_order"
    t.boolean "sort_ascending"
    t.integer "uploaded_logo_id"
    t.integer "uploaded_background_id"
    t.boolean "topic_featured_link_allowed", default: true
    t.boolean "all_topics_wiki", default: false, null: false
    t.boolean "show_subcategory_list", default: false
    t.integer "num_featured_topics", default: 3
    t.string "default_view", limit: 50
    t.string "subcategory_list_style", limit: 50, default: "rows_with_featured_topics"
    t.string "default_top_period", limit: 20, default: "all"
    t.boolean "mailinglist_mirror", default: false, null: false
    t.integer "minimum_required_tags", default: 0, null: false
    t.boolean "navigate_to_first_post_after_read", default: false, null: false
    t.integer "search_priority", default: 0
    t.boolean "allow_global_tags", default: false, null: false
    t.integer "reviewable_by_group_id"
    t.integer "required_tag_group_id"
    t.integer "min_tags_from_required_group", default: 1, null: false
    t.string "read_only_banner"
    t.string "default_list_filter", limit: 20, default: "all"
    t.boolean "allow_unlimited_owner_edits_on_first_post", default: false, null: false
    t.integer "default_slow_mode_seconds"
    t.index "COALESCE(parent_category_id, '-1'::integer), lower((slug)::text)", name: "unique_index_categories_on_slug", unique: true, where: "((slug)::text <> ''::text)"
    t.index "COALESCE(parent_category_id, '-1'::integer), name", name: "unique_index_categories_on_name", unique: true
    t.index ["email_in"], name: "index_categories_on_email_in", unique: true
    t.index ["reviewable_by_group_id"], name: "index_categories_on_reviewable_by_group_id"
    t.index ["search_priority"], name: "index_categories_on_search_priority"
    t.index ["topic_count"], name: "index_categories_on_topic_count"
  end

  create_table "categories_web_hooks", id: false, force: :cascade do |t|
    t.integer "web_hook_id", null: false
    t.integer "category_id", null: false
    t.index ["web_hook_id", "category_id"], name: "index_categories_web_hooks_on_web_hook_id_and_category_id", unique: true
  end

  create_table "category_custom_fields", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "name", limit: 256, null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "name"], name: "index_category_custom_fields_on_category_id_and_name"
  end

  create_table "category_featured_topics", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rank", default: 0, null: false
    t.index ["category_id", "rank"], name: "index_category_featured_topics_on_category_id_and_rank"
    t.index ["category_id", "topic_id"], name: "cat_featured_threads", unique: true
  end

  create_table "category_groups", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "permission_type", default: 1
    t.index ["group_id"], name: "index_category_groups_on_group_id"
  end

  create_table "category_search_data", primary_key: "category_id", id: :integer, default: nil, force: :cascade do |t|
    t.tsvector "search_data"
    t.text "raw_data"
    t.text "locale"
    t.integer "version", default: 0
    t.index ["search_data"], name: "idx_search_category", using: :gin
  end

  create_table "category_tag_groups", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "tag_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "tag_group_id"], name: "idx_category_tag_groups_ix1", unique: true
  end

  create_table "category_tag_stats", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "tag_id", null: false
    t.integer "topic_count", default: 0, null: false
    t.index ["category_id", "tag_id"], name: "index_category_tag_stats_on_category_id_and_tag_id", unique: true
    t.index ["category_id", "topic_count"], name: "index_category_tag_stats_on_category_id_and_topic_count"
    t.index ["category_id"], name: "index_category_tag_stats_on_category_id"
    t.index ["tag_id"], name: "index_category_tag_stats_on_tag_id"
  end

  create_table "category_tags", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "tag_id"], name: "idx_category_tags_ix1", unique: true
    t.index ["tag_id", "category_id"], name: "idx_category_tags_ix2", unique: true
  end

  create_table "category_users", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "user_id", null: false
    t.integer "notification_level"
    t.datetime "last_seen_at"
    t.index ["category_id", "user_id"], name: "idx_category_users_category_id_user_id", unique: true
    t.index ["user_id", "category_id"], name: "idx_category_users_user_id_category_id", unique: true
    t.index ["user_id", "last_seen_at"], name: "index_category_users_on_user_id_and_last_seen_at"
  end

  create_table "child_themes", id: :serial, force: :cascade do |t|
    t.integer "parent_theme_id"
    t.integer "child_theme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_theme_id", "parent_theme_id"], name: "index_child_themes_on_child_theme_id_and_parent_theme_id", unique: true
    t.index ["parent_theme_id", "child_theme_id"], name: "index_child_themes_on_parent_theme_id_and_child_theme_id", unique: true
  end

  create_table "color_scheme_colors", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "hex", null: false
    t.integer "color_scheme_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["color_scheme_id"], name: "index_color_scheme_colors_on_color_scheme_id"
  end

  create_table "color_schemes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "version", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "via_wizard", default: false, null: false
    t.string "base_scheme_id"
    t.integer "theme_id"
    t.boolean "user_selectable", default: false, null: false
  end

  create_table "custom_emojis", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "upload_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group", limit: 20
    t.index ["name"], name: "index_custom_emojis_on_name", unique: true
  end

  create_table "developers", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_developers_on_user_id", unique: true
  end

  create_table "directory_columns", force: :cascade do |t|
    t.string "name"
    t.integer "automatic_position"
    t.string "icon"
    t.integer "user_field_id"
    t.boolean "enabled", null: false
    t.integer "position", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "automatic", default: true, null: false
    t.integer "type", default: 0, null: false
    t.index ["enabled", "position", "user_field_id"], name: "directory_column_index"
  end

  create_table "directory_items", id: :serial, force: :cascade do |t|
    t.integer "period_type", null: false
    t.integer "user_id", null: false
    t.integer "likes_received", null: false
    t.integer "likes_given", null: false
    t.integer "topics_entered", null: false
    t.integer "topic_count", null: false
    t.integer "post_count", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "days_visited", default: 0, null: false
    t.integer "posts_read", default: 0, null: false
    t.index ["days_visited"], name: "index_directory_items_on_days_visited"
    t.index ["likes_given"], name: "index_directory_items_on_likes_given"
    t.index ["likes_received"], name: "index_directory_items_on_likes_received"
    t.index ["period_type", "user_id"], name: "index_directory_items_on_period_type_and_user_id", unique: true
    t.index ["post_count"], name: "index_directory_items_on_post_count"
    t.index ["posts_read"], name: "index_directory_items_on_posts_read"
    t.index ["topic_count"], name: "index_directory_items_on_topic_count"
    t.index ["topics_entered"], name: "index_directory_items_on_topics_entered"
  end

  create_table "dismissed_topic_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "topic_id"
    t.datetime "created_at"
    t.index ["user_id", "topic_id"], name: "index_dismissed_topic_users_on_user_id_and_topic_id", unique: true
  end

  create_table "do_not_disturb_timings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.boolean "scheduled", default: false
    t.index ["ends_at"], name: "index_do_not_disturb_timings_on_ends_at"
    t.index ["scheduled"], name: "index_do_not_disturb_timings_on_scheduled"
    t.index ["starts_at"], name: "index_do_not_disturb_timings_on_starts_at"
    t.index ["user_id"], name: "index_do_not_disturb_timings_on_user_id"
  end

  create_table "draft_sequences", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "draft_key", null: false
    t.bigint "sequence", null: false
    t.index ["user_id", "draft_key"], name: "index_draft_sequences_on_user_id_and_draft_key", unique: true
  end

  create_table "drafts", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "draft_key", null: false
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sequence", default: 0, null: false
    t.integer "revisions", default: 1, null: false
    t.string "owner"
    t.index ["user_id", "draft_key"], name: "index_drafts_on_user_id_and_draft_key", unique: true
  end

  create_table "email_change_requests", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "old_email"
    t.string "new_email", null: false
    t.integer "old_email_token_id"
    t.integer "new_email_token_id"
    t.integer "change_state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "requested_by_user_id"
    t.index ["requested_by_user_id"], name: "idx_email_change_requests_on_requested_by"
    t.index ["user_id"], name: "index_email_change_requests_on_user_id"
  end

  create_table "email_logs", id: :serial, force: :cascade do |t|
    t.string "to_address", null: false
    t.string "email_type", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "post_id"
    t.uuid "bounce_key"
    t.boolean "bounced", default: false, null: false
    t.string "message_id"
    t.integer "smtp_group_id"
    t.text "cc_addresses"
    t.integer "cc_user_ids", array: true
    t.text "raw"
    t.integer "topic_id"
    t.index ["bounce_key"], name: "index_email_logs_on_bounce_key", unique: true, where: "(bounce_key IS NOT NULL)"
    t.index ["bounced"], name: "index_email_logs_on_bounced"
    t.index ["created_at"], name: "index_email_logs_on_created_at", order: :desc
    t.index ["message_id"], name: "index_email_logs_on_message_id"
    t.index ["post_id"], name: "index_email_logs_on_post_id"
    t.index ["topic_id"], name: "index_email_logs_on_topic_id", where: "(topic_id IS NOT NULL)"
    t.index ["user_id"], name: "index_email_logs_on_user_id"
  end

  create_table "email_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.boolean "confirmed", default: false, null: false
    t.boolean "expired", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_email_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_email_tokens_on_user_id"
  end

  create_table "embeddable_hosts", id: :serial, force: :cascade do |t|
    t.string "host", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "class_name"
    t.string "allowed_paths"
  end

  create_table "external_upload_stubs", force: :cascade do |t|
    t.string "key", null: false
    t.string "original_filename", null: false
    t.integer "status", default: 1, null: false
    t.uuid "unique_identifier", null: false
    t.integer "created_by_id", null: false
    t.string "upload_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_by_id"], name: "index_external_upload_stubs_on_created_by_id"
    t.index ["key"], name: "index_external_upload_stubs_on_key", unique: true
    t.index ["status"], name: "index_external_upload_stubs_on_status"
  end

  create_table "given_daily_likes", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "likes_given", null: false
    t.date "given_date", null: false
    t.boolean "limit_reached", default: false, null: false
    t.index ["limit_reached", "user_id"], name: "index_given_daily_likes_on_limit_reached_and_user_id"
    t.index ["user_id", "given_date"], name: "index_given_daily_likes_on_user_id_and_given_date", unique: true
  end

  create_table "group_archived_messages", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "topic_id"], name: "index_group_archived_messages_on_group_id_and_topic_id", unique: true
  end

  create_table "group_category_notification_defaults", force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "category_id", null: false
    t.integer "notification_level", null: false
    t.index ["group_id", "category_id"], name: "idx_group_category_notification_defaults_unique", unique: true
  end

  create_table "group_custom_fields", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.string "name", limit: 256, null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "name"], name: "index_group_custom_fields_on_group_id_and_name"
  end

  create_table "group_histories", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "acting_user_id", null: false
    t.integer "target_user_id"
    t.integer "action", null: false
    t.string "subject"
    t.text "prev_value"
    t.text "new_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acting_user_id"], name: "index_group_histories_on_acting_user_id"
    t.index ["action"], name: "index_group_histories_on_action"
    t.index ["group_id"], name: "index_group_histories_on_group_id"
    t.index ["target_user_id"], name: "index_group_histories_on_target_user_id"
  end

  create_table "group_mentions", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "post_id"], name: "index_group_mentions_on_group_id_and_post_id", unique: true
    t.index ["post_id", "group_id"], name: "index_group_mentions_on_post_id_and_group_id", unique: true
  end

  create_table "group_requests", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "user_id"], name: "index_group_requests_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_requests_on_group_id"
    t.index ["user_id"], name: "index_group_requests_on_user_id"
  end

  create_table "group_tag_notification_defaults", force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "tag_id", null: false
    t.integer "notification_level", null: false
    t.index ["group_id", "tag_id"], name: "idx_group_tag_notification_defaults_unique", unique: true
  end

  create_table "group_users", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "owner", default: false, null: false
    t.integer "notification_level", default: 2, null: false
    t.datetime "first_unread_pm_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["group_id", "user_id"], name: "index_group_users_on_group_id_and_user_id", unique: true
    t.index ["user_id", "group_id"], name: "index_group_users_on_user_id_and_group_id", unique: true
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "automatic", default: false, null: false
    t.integer "user_count", default: 0, null: false
    t.text "automatic_membership_email_domains"
    t.boolean "primary_group", default: false, null: false
    t.string "title"
    t.integer "grant_trust_level"
    t.string "incoming_email"
    t.boolean "has_messages", default: false, null: false
    t.string "flair_url"
    t.string "flair_bg_color"
    t.string "flair_color"
    t.text "bio_raw"
    t.text "bio_cooked"
    t.boolean "allow_membership_requests", default: false, null: false
    t.string "full_name"
    t.integer "default_notification_level", default: 3, null: false
    t.integer "visibility_level", default: 0, null: false
    t.boolean "public_exit", default: false, null: false
    t.boolean "public_admission", default: false, null: false
    t.text "membership_request_template"
    t.integer "messageable_level", default: 0
    t.integer "mentionable_level", default: 0
    t.string "smtp_server"
    t.integer "smtp_port"
    t.boolean "smtp_ssl"
    t.string "imap_server"
    t.integer "imap_port"
    t.boolean "imap_ssl"
    t.string "imap_mailbox_name", default: "", null: false
    t.integer "imap_uid_validity", default: 0, null: false
    t.integer "imap_last_uid", default: 0, null: false
    t.string "email_username"
    t.string "email_password"
    t.boolean "publish_read_state", default: false, null: false
    t.integer "members_visibility_level", default: 0, null: false
    t.text "imap_last_error"
    t.integer "imap_old_emails"
    t.integer "imap_new_emails"
    t.string "flair_icon"
    t.integer "flair_upload_id"
    t.boolean "allow_unknown_sender_topic_replies", default: false, null: false
    t.boolean "smtp_enabled", default: false
    t.datetime "smtp_updated_at"
    t.integer "smtp_updated_by_id"
    t.boolean "imap_enabled", default: false
    t.datetime "imap_updated_at"
    t.integer "imap_updated_by_id"
    t.index ["incoming_email"], name: "index_groups_on_incoming_email", unique: true
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "groups_web_hooks", id: false, force: :cascade do |t|
    t.integer "web_hook_id", null: false
    t.integer "group_id", null: false
    t.index ["web_hook_id", "group_id"], name: "index_groups_web_hooks_on_web_hook_id_and_group_id", unique: true
  end

  create_table "ignored_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "ignored_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "summarized_at"
    t.datetime "expiring_at", null: false
    t.index ["ignored_user_id", "user_id"], name: "index_ignored_users_on_ignored_user_id_and_user_id", unique: true
    t.index ["user_id", "ignored_user_id"], name: "index_ignored_users_on_user_id_and_ignored_user_id", unique: true
  end

  create_table "imap_sync_logs", force: :cascade do |t|
    t.integer "level", null: false
    t.string "message", null: false
    t.bigint "group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_imap_sync_logs_on_group_id"
    t.index ["level"], name: "index_imap_sync_logs_on_level"
  end

  create_table "incoming_domains", id: :serial, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.boolean "https", default: false, null: false
    t.integer "port", null: false
    t.index ["name", "https", "port"], name: "index_incoming_domains_on_name_and_https_and_port", unique: true
  end

  create_table "incoming_emails", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "topic_id"
    t.integer "post_id"
    t.text "raw"
    t.text "error"
    t.text "message_id"
    t.text "from_address"
    t.text "to_addresses"
    t.text "cc_addresses"
    t.text "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "rejection_message"
    t.boolean "is_auto_generated", default: false
    t.boolean "is_bounce", default: false, null: false
    t.integer "imap_uid_validity"
    t.integer "imap_uid"
    t.boolean "imap_sync"
    t.bigint "imap_group_id"
    t.boolean "imap_missing", default: false, null: false
    t.integer "created_via", default: 0, null: false
    t.index ["created_at"], name: "index_incoming_emails_on_created_at"
    t.index ["error"], name: "index_incoming_emails_on_error"
    t.index ["imap_group_id"], name: "index_incoming_emails_on_imap_group_id"
    t.index ["imap_sync"], name: "index_incoming_emails_on_imap_sync"
    t.index ["message_id"], name: "index_incoming_emails_on_message_id"
    t.index ["post_id"], name: "index_incoming_emails_on_post_id"
    t.index ["user_id"], name: "index_incoming_emails_on_user_id", where: "(user_id IS NOT NULL)"
  end

  create_table "incoming_links", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "user_id"
    t.inet "ip_address"
    t.integer "current_user_id"
    t.integer "post_id", null: false
    t.integer "incoming_referer_id"
    t.index ["created_at", "user_id"], name: "index_incoming_links_on_created_at_and_user_id"
    t.index ["post_id"], name: "index_incoming_links_on_post_id"
  end

  create_table "incoming_referers", id: :serial, force: :cascade do |t|
    t.string "path", limit: 1000, null: false
    t.integer "incoming_domain_id", null: false
    t.index ["path", "incoming_domain_id"], name: "index_incoming_referers_on_path_and_incoming_domain_id", unique: true
  end

  create_table "invited_groups", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "invite_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "invite_id"], name: "index_invited_groups_on_group_id_and_invite_id", unique: true
  end

  create_table "invited_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "invite_id", null: false
    t.datetime "redeemed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["invite_id"], name: "index_invited_users_on_invite_id"
    t.index ["user_id", "invite_id"], name: "index_invited_users_on_user_id_and_invite_id", unique: true, where: "(user_id IS NOT NULL)"
  end

  create_table "invites", id: :serial, force: :cascade do |t|
    t.string "invite_key", limit: 32, null: false
    t.string "email"
    t.integer "invited_by_id", null: false
    t.integer "user_id"
    t.datetime "redeemed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.datetime "invalidated_at"
    t.boolean "moderator", default: false, null: false
    t.text "custom_message"
    t.integer "emailed_status"
    t.integer "max_redemptions_allowed", default: 1, null: false
    t.integer "redemption_count", default: 0, null: false
    t.datetime "expires_at", null: false
    t.string "email_token"
    t.index ["email", "invited_by_id"], name: "index_invites_on_email_and_invited_by_id"
    t.index ["emailed_status"], name: "index_invites_on_emailed_status"
    t.index ["invite_key"], name: "index_invites_on_invite_key", unique: true
    t.index ["invited_by_id"], name: "index_invites_on_invited_by_id"
  end

  create_table "javascript_caches", force: :cascade do |t|
    t.bigint "theme_field_id"
    t.string "digest"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "theme_id"
    t.index ["digest"], name: "index_javascript_caches_on_digest"
    t.index ["theme_field_id"], name: "index_javascript_caches_on_theme_field_id"
    t.index ["theme_id"], name: "index_javascript_caches_on_theme_id"
    t.check_constraint "((theme_id IS NOT NULL) AND (theme_field_id IS NULL)) OR ((theme_id IS NULL) AND (theme_field_id IS NOT NULL))", name: "enforce_theme_or_theme_field"
  end

  create_table "linked_topics", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.bigint "original_topic_id", null: false
    t.integer "sequence", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["topic_id", "original_topic_id"], name: "index_linked_topics_on_topic_id_and_original_topic_id", unique: true
    t.index ["topic_id", "sequence"], name: "index_linked_topics_on_topic_id_and_sequence", unique: true
  end

  create_table "message_bus", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "context"
    t.text "data"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_message_bus_on_created_at"
  end

  create_table "muted_users", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "muted_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["muted_user_id", "user_id"], name: "index_muted_users_on_muted_user_id_and_user_id", unique: true
    t.index ["user_id", "muted_user_id"], name: "index_muted_users_on_user_id_and_muted_user_id", unique: true
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "notification_type", null: false
    t.integer "user_id", null: false
    t.string "data", limit: 1000, null: false
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "topic_id"
    t.integer "post_number"
    t.integer "post_action_id"
    t.boolean "high_priority", default: false, null: false
    t.index ["post_action_id"], name: "index_notifications_on_post_action_id"
    t.index ["topic_id", "post_number"], name: "index_notifications_on_topic_id_and_post_number"
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at"
    t.index ["user_id", "id", "read", "topic_id"], name: "index_notifications_read_or_not_high_priority", order: { id: :desc }, where: "(read OR (high_priority = false))"
    t.index ["user_id", "id"], name: "index_notifications_unique_unread_high_priority", unique: true, where: "((NOT read) AND (high_priority = true))"
    t.index ["user_id", "notification_type"], name: "idx_notifications_speedup_unread_count", where: "(NOT read)"
    t.index ["user_id", "topic_id", "post_number"], name: "index_notifications_on_user_id_and_topic_id_and_post_number"
  end

  create_table "oauth2_user_infos", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "uid", null: false
    t.string "provider", null: false
    t.string "email"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid", "provider"], name: "index_oauth2_user_infos_on_uid_and_provider", unique: true
    t.index ["user_id", "provider"], name: "index_oauth2_user_infos_on_user_id_and_provider"
  end

  create_table "onceoff_logs", id: :serial, force: :cascade do |t|
    t.string "job_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_name"], name: "index_onceoff_logs_on_job_name"
  end

  create_table "optimized_images", id: :serial, force: :cascade do |t|
    t.string "sha1", limit: 40, null: false
    t.string "extension", limit: 10, null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "upload_id", null: false
    t.string "url", null: false
    t.integer "filesize"
    t.string "etag"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["etag"], name: "index_optimized_images_on_etag"
    t.index ["upload_id", "width", "height"], name: "index_optimized_images_on_upload_id_and_width_and_height", unique: true
    t.index ["upload_id"], name: "index_optimized_images_on_upload_id"
  end

  create_table "permalinks", id: :serial, force: :cascade do |t|
    t.string "url", limit: 1000, null: false
    t.integer "topic_id"
    t.integer "post_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_url", limit: 1000
    t.integer "tag_id"
    t.index ["url"], name: "index_permalinks_on_url", unique: true
  end

  create_table "plugin_store_rows", id: :serial, force: :cascade do |t|
    t.string "plugin_name", null: false
    t.string "key", null: false
    t.string "type_name", null: false
    t.text "value"
    t.index ["plugin_name", "key"], name: "index_plugin_store_rows_on_plugin_name_and_key", unique: true
  end

  create_table "poll_options", force: :cascade do |t|
    t.bigint "poll_id"
    t.string "digest", null: false
    t.text "html", null: false
    t.integer "anonymous_votes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id", "digest"], name: "index_poll_options_on_poll_id_and_digest", unique: true
    t.index ["poll_id"], name: "index_poll_options_on_poll_id"
  end

  create_table "poll_votes", id: false, force: :cascade do |t|
    t.bigint "poll_id"
    t.bigint "poll_option_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id", "poll_option_id", "user_id"], name: "index_poll_votes_on_poll_id_and_poll_option_id_and_user_id", unique: true
    t.index ["poll_id"], name: "index_poll_votes_on_poll_id"
    t.index ["poll_option_id"], name: "index_poll_votes_on_poll_option_id"
    t.index ["user_id"], name: "index_poll_votes_on_user_id"
  end

  create_table "polls", force: :cascade do |t|
    t.bigint "post_id"
    t.string "name", default: "poll", null: false
    t.datetime "close_at"
    t.integer "type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "results", default: 0, null: false
    t.integer "visibility", default: 0, null: false
    t.integer "min"
    t.integer "max"
    t.integer "step"
    t.integer "anonymous_voters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chart_type", default: 0, null: false
    t.string "groups"
    t.string "title"
    t.index ["post_id", "name"], name: "index_polls_on_post_id_and_name", unique: true
    t.index ["post_id"], name: "index_polls_on_post_id"
  end

  create_table "post_action_types", id: :serial, force: :cascade do |t|
    t.string "name_key", limit: 50, null: false
    t.boolean "is_flag", default: false, null: false
    t.string "icon", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0, null: false
    t.float "score_bonus", default: 0.0, null: false
    t.integer "reviewable_priority", default: 0, null: false
  end

  create_table "post_actions", id: :serial, force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "user_id", null: false
    t.integer "post_action_type_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "deleted_by_id"
    t.integer "related_post_id"
    t.boolean "staff_took_action", default: false, null: false
    t.integer "deferred_by_id"
    t.boolean "targets_topic", default: false, null: false
    t.datetime "agreed_at"
    t.integer "agreed_by_id"
    t.datetime "deferred_at"
    t.datetime "disagreed_at"
    t.integer "disagreed_by_id"
    t.index ["post_action_type_id", "disagreed_at"], name: "index_post_actions_on_post_action_type_id_and_disagreed_at", where: "(disagreed_at IS NULL)"
    t.index ["post_id"], name: "index_post_actions_on_post_id"
    t.index ["user_id", "post_action_type_id", "post_id", "targets_topic"], name: "idx_unique_actions", unique: true, where: "((deleted_at IS NULL) AND (disagreed_at IS NULL) AND (deferred_at IS NULL))"
    t.index ["user_id", "post_action_type_id"], name: "index_post_actions_on_user_id_and_post_action_type_id", where: "(deleted_at IS NULL)"
    t.index ["user_id", "post_id", "targets_topic"], name: "idx_unique_flags", unique: true, where: "((deleted_at IS NULL) AND (disagreed_at IS NULL) AND (deferred_at IS NULL) AND (post_action_type_id = ANY (ARRAY[3, 4, 7, 8])))"
    t.index ["user_id"], name: "index_post_actions_on_user_id"
  end

  create_table "post_custom_fields", id: :serial, force: :cascade do |t|
    t.integer "post_id", null: false
    t.string "name", limit: 256, null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "name, \"left\"(value, 200)", name: "index_post_custom_fields_on_name_and_value"
    t.index ["post_id", "name"], name: "index_post_custom_fields_on_post_id_and_name"
    t.index ["post_id"], name: "idx_post_custom_fields_akismet", where: "(((name)::text = 'AKISMET_STATE'::text) AND (value = 'needs_review'::text))"
    t.index ["post_id"], name: "index_post_custom_fields_on_notice", unique: true, where: "((name)::text = 'notice'::text)"
    t.index ["post_id"], name: "index_post_custom_fields_on_post_id", unique: true, where: "((name)::text = 'missing uploads'::text)"
    t.index ["post_id"], name: "index_post_id_where_missing_uploads_ignored", unique: true, where: "((name)::text = 'missing uploads ignored'::text)"
    t.index ["post_id"], name: "post_custom_field_broken_images_idx", unique: true, where: "((name)::text = 'broken_images'::text)"
    t.index ["post_id"], name: "post_custom_field_downloaded_images_idx", unique: true, where: "((name)::text = 'downloaded_images'::text)"
    t.index ["post_id"], name: "post_custom_field_large_images_idx", unique: true, where: "((name)::text = 'large_images'::text)"
  end

  create_table "post_details", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.string "key"
    t.string "value"
    t.text "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "key"], name: "index_post_details_on_post_id_and_key", unique: true
  end

  create_table "post_replies", id: false, force: :cascade do |t|
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reply_post_id"
    t.index ["post_id", "reply_post_id"], name: "index_post_replies_on_post_id_and_reply_post_id", unique: true
    t.index ["reply_post_id"], name: "index_post_replies_on_reply_post_id"
  end

  create_table "post_reply_keys", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "post_id", null: false
    t.uuid "reply_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reply_key"], name: "index_post_reply_keys_on_reply_key", unique: true
    t.index ["user_id", "post_id"], name: "index_post_reply_keys_on_user_id_and_post_id", unique: true
  end

  create_table "post_revisions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "post_id"
    t.text "modifications"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false, null: false
    t.index ["post_id", "number"], name: "index_post_revisions_on_post_id_and_number"
    t.index ["post_id"], name: "index_post_revisions_on_post_id"
    t.index ["user_id"], name: "index_post_revisions_on_user_id"
  end

  create_table "post_search_data", primary_key: "post_id", id: :integer, default: nil, force: :cascade do |t|
    t.tsvector "search_data"
    t.text "raw_data"
    t.string "locale"
    t.integer "version", default: 0
    t.boolean "private_message", null: false
    t.index ["post_id", "version", "locale"], name: "index_post_search_data_on_post_id_and_version_and_locale"
    t.index ["search_data"], name: "idx_search_post", using: :gin
  end

  create_table "post_stats", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.integer "drafts_saved"
    t.integer "typing_duration_msecs"
    t.integer "composer_open_duration_msecs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_post_stats_on_post_id"
  end

  create_table "post_timings", id: false, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "post_number", null: false
    t.integer "user_id", null: false
    t.integer "msecs", null: false
    t.index ["topic_id", "post_number", "user_id"], name: "post_timings_unique", unique: true
    t.index ["topic_id", "post_number"], name: "post_timings_summary"
    t.index ["user_id"], name: "index_post_timings_on_user_id"
  end

  create_table "post_uploads", id: :serial, force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "upload_id", null: false
    t.index ["post_id", "upload_id"], name: "idx_unique_post_uploads", unique: true
    t.index ["post_id"], name: "index_post_uploads_on_post_id"
    t.index ["upload_id"], name: "index_post_uploads_on_upload_id"
  end

  create_table "posts", id: :serial, comment: "If you want to query public posts only, use the badge_posts view.", force: :cascade do |t|
    t.integer "user_id"
    t.integer "topic_id", null: false
    t.integer "post_number", null: false, comment: "The position of this post in the topic. The pair (topic_id, post_number) forms a natural key on the posts table."
    t.text "raw", null: false, comment: "The raw Markdown that the user entered into the composer."
    t.text "cooked", null: false, comment: "The processed HTML that is presented in a topic."
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reply_to_post_number", comment: "If this post is a reply to another, this column is the post_number of the post it's replying to. [FKEY posts.topic_id, posts.post_number]"
    t.integer "reply_count", default: 0, null: false
    t.integer "quote_count", default: 0, null: false
    t.datetime "deleted_at"
    t.integer "off_topic_count", default: 0, null: false
    t.integer "like_count", default: 0, null: false
    t.integer "incoming_link_count", default: 0, null: false
    t.integer "bookmark_count", default: 0, null: false
    t.float "score"
    t.integer "reads", default: 0, null: false
    t.integer "post_type", default: 1, null: false
    t.integer "sort_order"
    t.integer "last_editor_id"
    t.boolean "hidden", default: false, null: false
    t.integer "hidden_reason_id"
    t.integer "notify_moderators_count", default: 0, null: false
    t.integer "spam_count", default: 0, null: false
    t.integer "illegal_count", default: 0, null: false
    t.integer "inappropriate_count", default: 0, null: false
    t.datetime "last_version_at", null: false
    t.boolean "user_deleted", default: false, null: false
    t.integer "reply_to_user_id"
    t.float "percent_rank", default: 1.0
    t.integer "notify_user_count", default: 0, null: false
    t.integer "like_score", default: 0, null: false
    t.integer "deleted_by_id"
    t.string "edit_reason"
    t.integer "word_count"
    t.integer "version", default: 1, null: false
    t.integer "cook_method", default: 1, null: false
    t.boolean "wiki", default: false, null: false
    t.datetime "baked_at"
    t.integer "baked_version"
    t.datetime "hidden_at"
    t.integer "self_edits", default: 0, null: false
    t.boolean "reply_quoted", default: false, null: false, comment: "This column is true if the post contains a quote-reply, which causes the in-reply-to indicator to be absent."
    t.boolean "via_email", default: false, null: false
    t.text "raw_email"
    t.integer "public_version", default: 1, null: false
    t.string "action_code"
    t.integer "locked_by_id"
    t.bigint "image_upload_id"
    t.index ["created_at", "topic_id"], name: "idx_posts_created_at_topic_id", where: "(deleted_at IS NULL)"
    t.index ["id", "baked_version"], name: "index_posts_on_id_and_baked_version", order: { id: :desc }, where: "(deleted_at IS NULL)"
    t.index ["id"], name: "index_for_rebake_old", order: :desc, where: "(((baked_version IS NULL) OR (baked_version < 2)) AND (deleted_at IS NULL))"
    t.index ["image_upload_id"], name: "index_posts_on_image_upload_id"
    t.index ["reply_to_post_number"], name: "index_posts_on_reply_to_post_number"
    t.index ["topic_id", "percent_rank"], name: "index_posts_on_topic_id_and_percent_rank"
    t.index ["topic_id", "post_number"], name: "idx_posts_deleted_posts", where: "(deleted_at IS NOT NULL)"
    t.index ["topic_id", "post_number"], name: "index_posts_on_topic_id_and_post_number", unique: true
    t.index ["topic_id", "sort_order"], name: "index_posts_on_topic_id_and_sort_order"
    t.index ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at"
    t.index ["user_id", "like_count", "created_at"], name: "index_posts_user_and_likes", order: { like_count: :desc, created_at: :desc }, where: "(post_number > 1)"
    t.index ["user_id"], name: "idx_posts_user_id_deleted_at", where: "(deleted_at IS NULL)"
  end

  create_table "published_pages", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.string "slug", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "public", default: false, null: false
    t.index ["slug"], name: "index_published_pages_on_slug", unique: true
    t.index ["topic_id"], name: "index_published_pages_on_topic_id", unique: true
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "error_count", default: 0, null: false
    t.datetime "first_error_at"
  end

  create_table "quoted_posts", id: :serial, force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "quoted_post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "quoted_post_id"], name: "index_quoted_posts_on_post_id_and_quoted_post_id", unique: true
    t.index ["quoted_post_id", "post_id"], name: "index_quoted_posts_on_quoted_post_id_and_post_id", unique: true
  end

  create_table "remote_themes", id: :serial, force: :cascade do |t|
    t.string "remote_url", null: false
    t.string "remote_version"
    t.string "local_version"
    t.string "about_url"
    t.string "license_url"
    t.integer "commits_behind"
    t.datetime "remote_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "private_key"
    t.string "branch"
    t.text "last_error_text"
    t.string "authors"
    t.string "theme_version"
    t.string "minimum_discourse_version"
    t.string "maximum_discourse_version"
  end

  create_table "reviewable_claimed_topics", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_reviewable_claimed_topics_on_topic_id", unique: true
  end

  create_table "reviewable_histories", force: :cascade do |t|
    t.integer "reviewable_id", null: false
    t.integer "reviewable_history_type", null: false
    t.integer "status", null: false
    t.integer "created_by_id", null: false
    t.json "edited"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_reviewable_histories_on_created_by_id"
    t.index ["reviewable_id"], name: "index_reviewable_histories_on_reviewable_id"
  end

  create_table "reviewable_scores", force: :cascade do |t|
    t.integer "reviewable_id", null: false
    t.integer "user_id", null: false
    t.integer "reviewable_score_type", null: false
    t.integer "status", null: false
    t.float "score", default: 0.0, null: false
    t.float "take_action_bonus", default: 0.0, null: false
    t.integer "reviewed_by_id"
    t.datetime "reviewed_at"
    t.integer "meta_topic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reason"
    t.float "user_accuracy_bonus", default: 0.0, null: false
    t.index ["reviewable_id"], name: "index_reviewable_scores_on_reviewable_id"
    t.index ["user_id"], name: "index_reviewable_scores_on_user_id"
  end

  create_table "reviewables", force: :cascade do |t|
    t.string "type", null: false
    t.integer "status", default: 0, null: false
    t.integer "created_by_id", null: false
    t.boolean "reviewable_by_moderator", default: false, null: false
    t.integer "reviewable_by_group_id"
    t.integer "category_id"
    t.integer "topic_id"
    t.float "score", default: 0.0, null: false
    t.boolean "potential_spam", default: false, null: false
    t.integer "target_id"
    t.string "target_type"
    t.integer "target_created_by_id"
    t.json "payload"
    t.integer "version", default: 0, null: false
    t.datetime "latest_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "force_review", default: false, null: false
    t.text "reject_reason"
    t.index ["reviewable_by_group_id"], name: "index_reviewables_on_reviewable_by_group_id"
    t.index ["status", "created_at"], name: "index_reviewables_on_status_and_created_at"
    t.index ["status", "score"], name: "index_reviewables_on_status_and_score"
    t.index ["status", "type"], name: "index_reviewables_on_status_and_type"
    t.index ["target_id"], name: "index_reviewables_on_target_id_where_post_type_eq_post", where: "((target_type)::text = 'Post'::text)"
    t.index ["topic_id", "status", "created_by_id"], name: "index_reviewables_on_topic_id_and_status_and_created_by_id"
    t.index ["type", "target_id"], name: "index_reviewables_on_type_and_target_id", unique: true
  end

  create_table "scheduler_stats", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "hostname", null: false
    t.integer "pid", null: false
    t.integer "duration_ms"
    t.integer "live_slots_start"
    t.integer "live_slots_finish"
    t.datetime "started_at", null: false
    t.boolean "success"
    t.text "error"
  end

  create_table "schema_migration_details", id: :serial, force: :cascade do |t|
    t.string "version", null: false
    t.string "name"
    t.string "hostname"
    t.string "git_version"
    t.string "rails_version"
    t.integer "duration"
    t.string "direction"
    t.datetime "created_at", null: false
    t.index ["version"], name: "index_schema_migration_details_on_version"
  end

  create_table "screened_emails", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.integer "action_type", null: false
    t.integer "match_count", default: 0, null: false
    t.datetime "last_match_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.inet "ip_address"
    t.index ["email"], name: "index_screened_emails_on_email", unique: true
    t.index ["last_match_at"], name: "index_screened_emails_on_last_match_at"
  end

  create_table "screened_ip_addresses", id: :serial, force: :cascade do |t|
    t.inet "ip_address", null: false
    t.integer "action_type", null: false
    t.integer "match_count", default: 0, null: false
    t.datetime "last_match_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_address"], name: "index_screened_ip_addresses_on_ip_address", unique: true
    t.index ["last_match_at"], name: "index_screened_ip_addresses_on_last_match_at"
  end

  create_table "screened_urls", id: :serial, force: :cascade do |t|
    t.string "url", null: false
    t.string "domain", null: false
    t.integer "action_type", null: false
    t.integer "match_count", default: 0, null: false
    t.datetime "last_match_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.inet "ip_address"
    t.index ["last_match_at"], name: "index_screened_urls_on_last_match_at"
    t.index ["url"], name: "index_screened_urls_on_url", unique: true
  end

  create_table "search_logs", id: :serial, force: :cascade do |t|
    t.string "term", null: false
    t.integer "user_id"
    t.inet "ip_address"
    t.integer "search_result_id"
    t.integer "search_type", null: false
    t.datetime "created_at", null: false
    t.integer "search_result_type"
    t.index ["created_at"], name: "index_search_logs_on_created_at"
  end

  create_table "shared_drafts", force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_shared_drafts_on_category_id"
    t.index ["topic_id"], name: "index_shared_drafts_on_topic_id", unique: true
  end

  create_table "shelved_notifications", force: :cascade do |t|
    t.integer "notification_id", null: false
    t.index ["notification_id"], name: "index_shelved_notifications_on_notification_id"
  end

  create_table "single_sign_on_records", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "external_id", null: false
    t.text "last_payload", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_username"
    t.string "external_email"
    t.string "external_name"
    t.string "external_avatar_url", limit: 1000
    t.string "external_profile_background_url"
    t.string "external_card_background_url"
    t.index ["external_id"], name: "index_single_sign_on_records_on_external_id", unique: true
    t.index ["user_id"], name: "index_single_sign_on_records_on_user_id"
  end

  create_table "site_settings", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "data_type", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_site_settings_on_name", unique: true
  end

  create_table "skipped_email_logs", force: :cascade do |t|
    t.string "email_type", null: false
    t.string "to_address", null: false
    t.integer "user_id"
    t.integer "post_id"
    t.integer "reason_type", null: false
    t.text "custom_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_skipped_email_logs_on_created_at"
    t.index ["post_id"], name: "index_skipped_email_logs_on_post_id"
    t.index ["reason_type"], name: "index_skipped_email_logs_on_reason_type"
    t.index ["user_id"], name: "index_skipped_email_logs_on_user_id"
  end

  create_table "stylesheet_cache", id: :serial, force: :cascade do |t|
    t.string "target", null: false
    t.string "digest", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "theme_id", default: -1, null: false
    t.text "source_map"
    t.index ["target", "digest"], name: "index_stylesheet_cache_on_target_and_digest", unique: true
  end

  create_table "tag_group_memberships", id: :serial, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "tag_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_group_id", "tag_id"], name: "index_tag_group_memberships_on_tag_group_id_and_tag_id", unique: true
  end

  create_table "tag_group_permissions", force: :cascade do |t|
    t.bigint "tag_group_id", null: false
    t.bigint "group_id", null: false
    t.integer "permission_type", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_tag_group_permissions_on_group_id"
    t.index ["tag_group_id"], name: "index_tag_group_permissions_on_tag_group_id"
  end

  create_table "tag_groups", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_tag_id"
    t.boolean "one_per_topic", default: false
  end

  create_table "tag_search_data", primary_key: "tag_id", id: :serial, force: :cascade do |t|
    t.tsvector "search_data"
    t.text "raw_data"
    t.text "locale"
    t.integer "version", default: 0
    t.index ["search_data"], name: "idx_search_tag", using: :gin
  end

  create_table "tag_users", id: :serial, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "user_id", null: false
    t.integer "notification_level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "user_id", "notification_level"], name: "idx_tag_users_ix2", unique: true
    t.index ["user_id", "tag_id", "notification_level"], name: "idx_tag_users_ix1", unique: true
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "topic_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pm_topic_count", default: 0, null: false
    t.integer "target_tag_id"
    t.index "lower((name)::text)", name: "index_tags_on_lower_name", unique: true
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tags_web_hooks", id: false, force: :cascade do |t|
    t.bigint "web_hook_id", null: false
    t.bigint "tag_id", null: false
    t.index ["web_hook_id", "tag_id"], name: "web_hooks_tags", unique: true
  end

  create_table "theme_fields", id: :serial, force: :cascade do |t|
    t.integer "theme_id", null: false
    t.integer "target_id", null: false
    t.string "name", limit: 255, null: false
    t.text "value", null: false
    t.text "value_baked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "compiler_version", limit: 50, default: "0", null: false
    t.string "error"
    t.integer "upload_id"
    t.integer "type_id", default: 0, null: false
    t.index ["theme_id", "target_id", "type_id", "name"], name: "theme_field_unique_index", unique: true
  end

  create_table "theme_modifier_sets", force: :cascade do |t|
    t.bigint "theme_id", null: false
    t.boolean "serialize_topic_excerpts"
    t.string "csp_extensions", array: true
    t.string "svg_icons", array: true
    t.string "topic_thumbnail_sizes", array: true
    t.index ["theme_id"], name: "index_theme_modifier_sets_on_theme_id", unique: true
  end

  create_table "theme_settings", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.integer "data_type", null: false
    t.text "value"
    t.integer "theme_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "theme_translation_overrides", force: :cascade do |t|
    t.integer "theme_id", null: false
    t.string "locale", null: false
    t.string "translation_key", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id", "locale", "translation_key"], name: "theme_translation_overrides_unique", unique: true
    t.index ["theme_id"], name: "index_theme_translation_overrides_on_theme_id"
  end

  create_table "themes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "compiler_version", default: 0, null: false
    t.boolean "user_selectable", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.integer "color_scheme_id"
    t.integer "remote_theme_id"
    t.boolean "component", default: false, null: false
    t.boolean "enabled", default: true, null: false
    t.boolean "auto_update", default: true, null: false
    t.index ["remote_theme_id"], name: "index_themes_on_remote_theme_id", unique: true
  end

  create_table "top_topics", id: :serial, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "yearly_posts_count", default: 0, null: false
    t.integer "yearly_views_count", default: 0, null: false
    t.integer "yearly_likes_count", default: 0, null: false
    t.integer "monthly_posts_count", default: 0, null: false
    t.integer "monthly_views_count", default: 0, null: false
    t.integer "monthly_likes_count", default: 0, null: false
    t.integer "weekly_posts_count", default: 0, null: false
    t.integer "weekly_views_count", default: 0, null: false
    t.integer "weekly_likes_count", default: 0, null: false
    t.integer "daily_posts_count", default: 0, null: false
    t.integer "daily_views_count", default: 0, null: false
    t.integer "daily_likes_count", default: 0, null: false
    t.float "daily_score", default: 0.0
    t.float "weekly_score", default: 0.0
    t.float "monthly_score", default: 0.0
    t.float "yearly_score", default: 0.0
    t.float "all_score", default: 0.0
    t.integer "daily_op_likes_count", default: 0, null: false
    t.integer "weekly_op_likes_count", default: 0, null: false
    t.integer "monthly_op_likes_count", default: 0, null: false
    t.integer "yearly_op_likes_count", default: 0, null: false
    t.integer "quarterly_posts_count", default: 0, null: false
    t.integer "quarterly_views_count", default: 0, null: false
    t.integer "quarterly_likes_count", default: 0, null: false
    t.float "quarterly_score", default: 0.0
    t.integer "quarterly_op_likes_count", default: 0, null: false
    t.index ["all_score"], name: "index_top_topics_on_all_score"
    t.index ["daily_likes_count"], name: "index_top_topics_on_daily_likes_count", order: :desc
    t.index ["daily_op_likes_count"], name: "index_top_topics_on_daily_op_likes_count"
    t.index ["daily_posts_count"], name: "index_top_topics_on_daily_posts_count", order: :desc
    t.index ["daily_score"], name: "index_top_topics_on_daily_score"
    t.index ["daily_views_count"], name: "index_top_topics_on_daily_views_count", order: :desc
    t.index ["monthly_likes_count"], name: "index_top_topics_on_monthly_likes_count", order: :desc
    t.index ["monthly_op_likes_count"], name: "index_top_topics_on_monthly_op_likes_count"
    t.index ["monthly_posts_count"], name: "index_top_topics_on_monthly_posts_count", order: :desc
    t.index ["monthly_score"], name: "index_top_topics_on_monthly_score"
    t.index ["monthly_views_count"], name: "index_top_topics_on_monthly_views_count", order: :desc
    t.index ["quarterly_likes_count"], name: "index_top_topics_on_quarterly_likes_count"
    t.index ["quarterly_op_likes_count"], name: "index_top_topics_on_quarterly_op_likes_count"
    t.index ["quarterly_posts_count"], name: "index_top_topics_on_quarterly_posts_count"
    t.index ["quarterly_views_count"], name: "index_top_topics_on_quarterly_views_count"
    t.index ["topic_id"], name: "index_top_topics_on_topic_id", unique: true
    t.index ["weekly_likes_count"], name: "index_top_topics_on_weekly_likes_count", order: :desc
    t.index ["weekly_op_likes_count"], name: "index_top_topics_on_weekly_op_likes_count"
    t.index ["weekly_posts_count"], name: "index_top_topics_on_weekly_posts_count", order: :desc
    t.index ["weekly_score"], name: "index_top_topics_on_weekly_score"
    t.index ["weekly_views_count"], name: "index_top_topics_on_weekly_views_count", order: :desc
    t.index ["yearly_likes_count"], name: "index_top_topics_on_yearly_likes_count", order: :desc
    t.index ["yearly_op_likes_count"], name: "index_top_topics_on_yearly_op_likes_count"
    t.index ["yearly_posts_count"], name: "index_top_topics_on_yearly_posts_count", order: :desc
    t.index ["yearly_score"], name: "index_top_topics_on_yearly_score"
    t.index ["yearly_views_count"], name: "index_top_topics_on_yearly_views_count", order: :desc
  end

  create_table "topic_allowed_groups", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "topic_id", null: false
    t.index ["group_id", "topic_id"], name: "index_topic_allowed_groups_on_group_id_and_topic_id", unique: true
    t.index ["topic_id", "group_id"], name: "index_topic_allowed_groups_on_topic_id_and_group_id", unique: true
  end

  create_table "topic_allowed_users", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id", "user_id"], name: "index_topic_allowed_users_on_topic_id_and_user_id", unique: true
    t.index ["user_id", "topic_id"], name: "index_topic_allowed_users_on_user_id_and_topic_id", unique: true
  end

  create_table "topic_custom_fields", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.string "name", limit: 256, null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id", "name"], name: "index_topic_custom_fields_on_topic_id_and_name"
    t.index ["value", "name"], name: "topic_custom_fields_value_key_idx", where: "((value IS NOT NULL) AND (char_length(value) < 400))"
  end

  create_table "topic_embeds", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "post_id", null: false
    t.string "embed_url", limit: 1000, null: false
    t.string "content_sha1", limit: 40
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.index ["embed_url"], name: "index_topic_embeds_on_embed_url", unique: true
  end

  create_table "topic_groups", force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "topic_id", null: false
    t.integer "last_read_post_number", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "topic_id"], name: "index_topic_groups_on_group_id_and_topic_id", unique: true
  end

  create_table "topic_invites", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "invite_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_id"], name: "index_topic_invites_on_invite_id"
    t.index ["topic_id", "invite_id"], name: "index_topic_invites_on_topic_id_and_invite_id", unique: true
  end

  create_table "topic_link_clicks", id: :serial, force: :cascade do |t|
    t.integer "topic_link_id", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.inet "ip_address"
    t.index ["topic_link_id"], name: "by_link"
  end

  create_table "topic_links", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "post_id"
    t.integer "user_id", null: false
    t.string "url", null: false
    t.string "domain", limit: 100, null: false
    t.boolean "internal", default: false, null: false
    t.integer "link_topic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reflection", default: false
    t.integer "clicks", default: 0, null: false
    t.integer "link_post_id"
    t.string "title"
    t.datetime "crawled_at"
    t.boolean "quote", default: false, null: false
    t.string "extension", limit: 10
    t.index ["extension"], name: "index_topic_links_on_extension"
    t.index ["link_post_id", "reflection"], name: "index_topic_links_on_link_post_id_and_reflection"
    t.index ["post_id"], name: "index_topic_links_on_post_id"
    t.index ["topic_id", "post_id", "url"], name: "unique_post_links", unique: true
    t.index ["topic_id"], name: "index_topic_links_on_topic_id"
    t.index ["user_id", "clicks", "created_at"], name: "index_topic_links_on_user_and_clicks", order: { clicks: :desc, created_at: :desc }, where: "((NOT reflection) AND (NOT quote) AND (NOT internal))"
    t.index ["user_id"], name: "index_topic_links_on_user_id"
  end

  create_table "topic_search_data", primary_key: "topic_id", id: :integer, default: nil, force: :cascade do |t|
    t.text "raw_data"
    t.string "locale", null: false
    t.tsvector "search_data"
    t.integer "version", default: 0
    t.index ["search_data"], name: "idx_search_topic", using: :gin
    t.index ["topic_id", "version", "locale"], name: "index_topic_search_data_on_topic_id_and_version_and_locale"
  end

  create_table "topic_tags", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id", "tag_id"], name: "index_topic_tags_on_topic_id_and_tag_id", unique: true
  end

  create_table "topic_thumbnails", force: :cascade do |t|
    t.bigint "upload_id", null: false
    t.bigint "optimized_image_id"
    t.integer "max_width", null: false
    t.integer "max_height", null: false
    t.index ["optimized_image_id"], name: "index_topic_thumbnails_on_optimized_image_id"
    t.index ["upload_id", "max_width", "max_height"], name: "unique_topic_thumbnails", unique: true
    t.index ["upload_id"], name: "index_topic_thumbnails_on_upload_id"
  end

  create_table "topic_timers", id: :serial, force: :cascade do |t|
    t.datetime "execute_at", null: false
    t.integer "status_type", null: false
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.boolean "based_on_last_post", default: false, null: false
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_id"
    t.boolean "public_type", default: true
    t.integer "duration_minutes"
    t.index ["topic_id"], name: "idx_topic_id_public_type_deleted_at", unique: true, where: "((public_type = true) AND (deleted_at IS NULL))"
    t.index ["user_id"], name: "index_topic_timers_on_user_id"
  end

  create_table "topic_users", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.boolean "posted", default: false, null: false
    t.integer "last_read_post_number"
    t.datetime "last_visited_at"
    t.datetime "first_visited_at"
    t.integer "notification_level", default: 1, null: false
    t.datetime "notifications_changed_at"
    t.integer "notifications_reason_id"
    t.integer "total_msecs_viewed", default: 0, null: false
    t.datetime "cleared_pinned_at"
    t.integer "last_emailed_post_number"
    t.boolean "liked", default: false
    t.boolean "bookmarked", default: false
    t.datetime "last_posted_at"
    t.index ["topic_id", "user_id"], name: "index_topic_users_on_topic_id_and_user_id", unique: true
    t.index ["user_id", "topic_id"], name: "index_topic_users_on_user_id_and_topic_id", unique: true
  end

  create_table "topic_views", id: false, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.date "viewed_at", null: false
    t.integer "user_id"
    t.inet "ip_address"
    t.index ["topic_id", "viewed_at"], name: "index_topic_views_on_topic_id_and_viewed_at"
    t.index ["user_id", "ip_address", "topic_id"], name: "uniq_ip_or_user_id_topic_views", unique: true
    t.index ["user_id", "viewed_at"], name: "index_topic_views_on_user_id_and_viewed_at"
    t.index ["viewed_at", "topic_id"], name: "index_topic_views_on_viewed_at_and_topic_id"
  end

  create_table "topics", id: :serial, comment: "To query public topics only: SELECT ... FROM topics t LEFT INNER JOIN categories c ON (t.category_id = c.id AND c.read_restricted = false)", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "last_posted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "views", default: 0, null: false
    t.integer "posts_count", default: 0, null: false
    t.integer "user_id"
    t.integer "last_post_user_id", null: false
    t.integer "reply_count", default: 0, null: false
    t.integer "featured_user1_id"
    t.integer "featured_user2_id"
    t.integer "featured_user3_id"
    t.datetime "deleted_at"
    t.integer "highest_post_number", default: 0, null: false
    t.integer "like_count", default: 0, null: false
    t.integer "incoming_link_count", default: 0, null: false
    t.integer "category_id"
    t.boolean "visible", default: true, null: false
    t.integer "moderator_posts_count", default: 0, null: false
    t.boolean "closed", default: false, null: false
    t.boolean "archived", default: false, null: false
    t.datetime "bumped_at", null: false
    t.boolean "has_summary", default: false, null: false
    t.string "archetype", default: "regular", null: false
    t.integer "featured_user4_id"
    t.integer "notify_moderators_count", default: 0, null: false
    t.integer "spam_count", default: 0, null: false
    t.datetime "pinned_at"
    t.float "score"
    t.float "percent_rank", default: 1.0, null: false
    t.string "subtype"
    t.string "slug"
    t.integer "deleted_by_id"
    t.integer "participant_count", default: 1
    t.integer "word_count"
    t.string "excerpt"
    t.boolean "pinned_globally", default: false, null: false
    t.datetime "pinned_until"
    t.string "fancy_title", limit: 400
    t.integer "highest_staff_post_number", default: 0, null: false
    t.string "featured_link"
    t.float "reviewable_score", default: 0.0, null: false
    t.bigint "image_upload_id"
    t.integer "slow_mode_seconds", default: 0, null: false
    t.datetime "bannered_until"
    t.index "lower((title)::text)", name: "index_topics_on_lower_title"
    t.index ["bannered_until"], name: "index_topics_on_bannered_until", where: "(bannered_until IS NOT NULL)"
    t.index ["bumped_at", "created_at", "updated_at"], name: "index_topics_on_timestamps_private", where: "((deleted_at IS NULL) AND ((archetype)::text = 'private_message'::text))"
    t.index ["bumped_at"], name: "index_topics_on_bumped_at", order: :desc
    t.index ["created_at", "visible"], name: "index_topics_on_created_at_and_visible", where: "((deleted_at IS NULL) AND ((archetype)::text <> 'private_message'::text))"
    t.index ["deleted_at", "visible", "archetype", "category_id", "id"], name: "idx_topics_front_page"
    t.index ["id", "deleted_at"], name: "index_topics_on_id_and_deleted_at"
    t.index ["id"], name: "index_topics_on_id_filtered_banner", unique: true, where: "(((archetype)::text = 'banner'::text) AND (deleted_at IS NULL))"
    t.index ["image_upload_id"], name: "index_topics_on_image_upload_id"
    t.index ["pinned_at"], name: "index_topics_on_pinned_at", where: "(pinned_at IS NOT NULL)"
    t.index ["pinned_globally"], name: "index_topics_on_pinned_globally", where: "pinned_globally"
    t.index ["pinned_until"], name: "index_topics_on_pinned_until", where: "(pinned_until IS NOT NULL)"
    t.index ["slug"], name: "idxtopicslug", where: "((deleted_at IS NULL) AND (slug IS NOT NULL))"
    t.index ["updated_at", "visible", "highest_staff_post_number", "highest_post_number", "category_id", "created_at", "id"], name: "index_topics_on_updated_at_public", where: "(((archetype)::text <> 'private_message'::text) AND (deleted_at IS NULL))"
    t.index ["user_id"], name: "idx_topics_user_id_deleted_at", where: "(deleted_at IS NULL)"
    t.check_constraint "(category_id IS NOT NULL) OR ((archetype)::text <> 'regular'::text)", name: "has_category_id"
    t.check_constraint "(category_id IS NULL) OR ((archetype)::text <> 'private_message'::text)", name: "pm_has_no_category"
  end

  create_table "translation_overrides", id: :serial, force: :cascade do |t|
    t.string "locale", null: false
    t.string "translation_key", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "compiled_js"
    t.index ["locale", "translation_key"], name: "index_translation_overrides_on_locale_and_translation_key", unique: true
  end

  create_table "unsubscribe_keys", primary_key: "key", id: { type: :string, limit: 64 }, force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unsubscribe_key_type"
    t.integer "topic_id"
    t.integer "post_id"
    t.index ["created_at"], name: "index_unsubscribe_keys_on_created_at"
  end

  create_table "uploads", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "original_filename", null: false
    t.integer "filesize", null: false
    t.integer "width"
    t.integer "height"
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sha1", limit: 40
    t.string "origin", limit: 1000
    t.integer "retain_hours"
    t.string "extension", limit: 10
    t.integer "thumbnail_width"
    t.integer "thumbnail_height"
    t.string "etag"
    t.boolean "secure", default: false, null: false
    t.bigint "access_control_post_id"
    t.string "original_sha1"
    t.boolean "animated"
    t.integer "verification_status", default: 1, null: false
    t.datetime "security_last_changed_at"
    t.string "security_last_changed_reason"
    t.index "lower((extension)::text)", name: "index_uploads_on_extension"
    t.index ["access_control_post_id"], name: "index_uploads_on_access_control_post_id"
    t.index ["etag"], name: "index_uploads_on_etag"
    t.index ["id", "url"], name: "index_uploads_on_id_and_url"
    t.index ["original_sha1"], name: "index_uploads_on_original_sha1"
    t.index ["sha1"], name: "index_uploads_on_sha1", unique: true
    t.index ["url"], name: "index_uploads_on_url"
    t.index ["user_id"], name: "index_uploads_on_user_id"
    t.index ["verification_status"], name: "idx_uploads_on_verification_status"
  end

  create_table "user_actions", id: :serial, force: :cascade do |t|
    t.integer "action_type", null: false
    t.integer "user_id", null: false
    t.integer "target_topic_id"
    t.integer "target_post_id"
    t.integer "target_user_id"
    t.integer "acting_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acting_user_id"], name: "index_user_actions_on_acting_user_id"
    t.index ["action_type", "created_at"], name: "index_user_actions_on_action_type_and_created_at"
    t.index ["action_type", "user_id", "target_topic_id", "target_post_id", "acting_user_id"], name: "idx_unique_rows", unique: true
    t.index ["target_post_id"], name: "index_user_actions_on_target_post_id"
    t.index ["target_user_id"], name: "index_user_actions_on_target_user_id", where: "(target_user_id IS NOT NULL)"
    t.index ["user_id", "action_type"], name: "index_user_actions_on_user_id_and_action_type"
    t.index ["user_id", "created_at", "action_type"], name: "idx_user_actions_speed_up_user_all"
  end

  create_table "user_api_key_scopes", force: :cascade do |t|
    t.integer "user_api_key_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "allowed_parameters"
    t.index ["user_api_key_id"], name: "index_user_api_key_scopes_on_user_api_key_id"
  end

  create_table "user_api_keys", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "client_id", null: false
    t.string "application_name", null: false
    t.string "push_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "revoked_at"
    t.text "scopes", array: true
    t.datetime "last_used_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "key_hash", null: false
    t.index ["client_id"], name: "index_user_api_keys_on_client_id", unique: true
    t.index ["key_hash"], name: "index_user_api_keys_on_key_hash", unique: true
    t.index ["user_id"], name: "index_user_api_keys_on_user_id"
  end

  create_table "user_archived_messages", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "topic_id"], name: "index_user_archived_messages_on_user_id_and_topic_id", unique: true
  end

  create_table "user_associated_accounts", force: :cascade do |t|
    t.string "provider_name", null: false
    t.string "provider_uid", null: false
    t.integer "user_id"
    t.datetime "last_used", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "info", default: {}, null: false
    t.jsonb "credentials", default: {}, null: false
    t.jsonb "extra", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_name", "provider_uid"], name: "associated_accounts_provider_uid", unique: true
    t.index ["provider_name", "user_id"], name: "associated_accounts_provider_user", unique: true
  end

  create_table "user_auth_token_logs", id: :serial, force: :cascade do |t|
    t.string "action", null: false
    t.integer "user_auth_token_id"
    t.integer "user_id"
    t.inet "client_ip"
    t.string "user_agent"
    t.string "auth_token"
    t.datetime "created_at"
    t.string "path"
    t.index ["user_id"], name: "index_user_auth_token_logs_on_user_id"
  end

  create_table "user_auth_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "auth_token", null: false
    t.string "prev_auth_token", null: false
    t.string "user_agent"
    t.boolean "auth_token_seen", default: false, null: false
    t.inet "client_ip"
    t.datetime "rotated_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "seen_at"
    t.index ["auth_token"], name: "index_user_auth_tokens_on_auth_token", unique: true
    t.index ["prev_auth_token"], name: "index_user_auth_tokens_on_prev_auth_token", unique: true
    t.index ["user_id"], name: "index_user_auth_tokens_on_user_id"
  end

  create_table "user_avatars", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "custom_upload_id"
    t.integer "gravatar_upload_id"
    t.datetime "last_gravatar_download_attempt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_upload_id"], name: "index_user_avatars_on_custom_upload_id"
    t.index ["gravatar_upload_id"], name: "index_user_avatars_on_gravatar_upload_id"
    t.index ["user_id"], name: "index_user_avatars_on_user_id"
  end

  create_table "user_badges", id: :serial, force: :cascade do |t|
    t.integer "badge_id", null: false
    t.integer "user_id", null: false
    t.datetime "granted_at", null: false
    t.integer "granted_by_id", null: false
    t.integer "post_id"
    t.integer "notification_id"
    t.integer "seq", default: 0, null: false
    t.integer "featured_rank"
    t.datetime "created_at", null: false
    t.boolean "is_favorite"
    t.index ["badge_id", "user_id", "post_id"], name: "index_user_badges_on_badge_id_and_user_id_and_post_id", unique: true, where: "(post_id IS NOT NULL)"
    t.index ["badge_id", "user_id", "seq"], name: "index_user_badges_on_badge_id_and_user_id_and_seq", unique: true, where: "(post_id IS NULL)"
    t.index ["badge_id", "user_id"], name: "index_user_badges_on_badge_id_and_user_id"
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "user_custom_fields", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", limit: 256, null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_user_custom_fields_on_user_id_and_name"
  end

  create_table "user_emails", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "email", limit: 513, null: false
    t.boolean "primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_user_emails_on_email", unique: true
    t.index ["user_id", "primary"], name: "index_user_emails_on_user_id_and_primary", unique: true, where: "\"primary\""
    t.index ["user_id"], name: "index_user_emails_on_user_id"
  end

  create_table "user_exports", id: :serial, force: :cascade do |t|
    t.string "file_name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "upload_id"
    t.integer "topic_id"
  end

  create_table "user_field_options", id: :serial, force: :cascade do |t|
    t.integer "user_field_id", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_fields", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "field_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "editable", default: false, null: false
    t.string "description", null: false
    t.boolean "required", default: true, null: false
    t.boolean "show_on_profile", default: false, null: false
    t.integer "position", default: 0
    t.boolean "show_on_user_card", default: false, null: false
    t.string "external_name"
    t.string "external_type"
    t.boolean "searchable", default: false, null: false
  end

  create_table "user_histories", id: :serial, force: :cascade do |t|
    t.integer "action", null: false
    t.integer "acting_user_id"
    t.integer "target_user_id"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "context"
    t.string "ip_address"
    t.string "email"
    t.text "subject"
    t.text "previous_value"
    t.text "new_value"
    t.integer "topic_id"
    t.boolean "admin_only", default: false
    t.integer "post_id"
    t.string "custom_type"
    t.integer "category_id"
    t.index ["acting_user_id", "action", "id"], name: "index_user_histories_on_acting_user_id_and_action_and_id"
    t.index ["action", "id"], name: "index_user_histories_on_action_and_id"
    t.index ["category_id"], name: "index_user_histories_on_category_id"
    t.index ["subject", "id"], name: "index_user_histories_on_subject_and_id"
    t.index ["target_user_id", "id"], name: "index_user_histories_on_target_user_id_and_id"
    t.index ["topic_id", "target_user_id", "action"], name: "index_user_histories_on_topic_id_and_target_user_id_and_action"
  end

  create_table "user_ip_address_histories", force: :cascade do |t|
    t.integer "user_id", null: false
    t.inet "ip_address", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "ip_address"], name: "index_user_ip_address_histories_on_user_id_and_ip_address", unique: true
  end

  create_table "user_notification_schedules", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "enabled", default: false, null: false
    t.integer "day_0_start_time", null: false
    t.integer "day_0_end_time", null: false
    t.integer "day_1_start_time", null: false
    t.integer "day_1_end_time", null: false
    t.integer "day_2_start_time", null: false
    t.integer "day_2_end_time", null: false
    t.integer "day_3_start_time", null: false
    t.integer "day_3_end_time", null: false
    t.integer "day_4_start_time", null: false
    t.integer "day_4_end_time", null: false
    t.integer "day_5_start_time", null: false
    t.integer "day_5_end_time", null: false
    t.integer "day_6_start_time", null: false
    t.integer "day_6_end_time", null: false
    t.index ["enabled"], name: "index_user_notification_schedules_on_enabled"
    t.index ["user_id"], name: "index_user_notification_schedules_on_user_id"
  end

  create_table "user_open_ids", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "email", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", null: false
    t.index ["url"], name: "index_user_open_ids_on_url"
  end

  create_table "user_options", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "mailing_list_mode", default: false, null: false
    t.boolean "email_digests"
    t.boolean "external_links_in_new_tab", default: false, null: false
    t.boolean "enable_quoting", default: true, null: false
    t.boolean "dynamic_favicon", default: false, null: false
    t.boolean "automatically_unpin_topics", default: true, null: false
    t.integer "digest_after_minutes"
    t.integer "auto_track_topics_after_msecs"
    t.integer "new_topic_duration_minutes"
    t.datetime "last_redirected_to_top_at"
    t.integer "email_previous_replies", default: 2, null: false
    t.boolean "email_in_reply_to", default: true, null: false
    t.integer "like_notification_frequency", default: 1, null: false
    t.integer "mailing_list_mode_frequency", default: 1, null: false
    t.boolean "include_tl0_in_digests", default: false
    t.integer "notification_level_when_replying"
    t.integer "theme_key_seq", default: 0, null: false
    t.boolean "allow_private_messages", default: true, null: false
    t.integer "homepage_id"
    t.integer "theme_ids", default: [], null: false, array: true
    t.boolean "hide_profile_and_presence", default: false, null: false
    t.integer "text_size_key", default: 0, null: false
    t.integer "text_size_seq", default: 0, null: false
    t.integer "email_level", default: 1, null: false
    t.integer "email_messages_level", default: 0, null: false
    t.integer "title_count_mode_key", default: 0, null: false
    t.boolean "enable_defer", default: false, null: false
    t.string "timezone"
    t.boolean "enable_allowed_pm_users", default: false, null: false
    t.integer "dark_scheme_id"
    t.boolean "skip_new_user_tips", default: false, null: false
    t.integer "color_scheme_id"
    t.index ["user_id"], name: "index_user_options_on_user_id", unique: true
  end

  create_table "user_profile_views", id: :serial, force: :cascade do |t|
    t.integer "user_profile_id", null: false
    t.datetime "viewed_at", null: false
    t.inet "ip_address"
    t.integer "user_id"
    t.index ["user_id"], name: "index_user_profile_views_on_user_id"
    t.index ["user_profile_id"], name: "index_user_profile_views_on_user_profile_id"
    t.index ["viewed_at", "user_id", "ip_address", "user_profile_id"], name: "unique_profile_view_user_or_ip", unique: true
  end

  create_table "user_profiles", primary_key: "user_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "location"
    t.string "website"
    t.text "bio_raw"
    t.text "bio_cooked"
    t.integer "dismissed_banner_key"
    t.integer "bio_cooked_version"
    t.boolean "badge_granted_title", default: false
    t.integer "views", default: 0, null: false
    t.integer "profile_background_upload_id"
    t.integer "card_background_upload_id"
    t.bigint "granted_title_badge_id"
    t.integer "featured_topic_id"
    t.index ["bio_cooked_version"], name: "index_user_profiles_on_bio_cooked_version"
    t.index ["card_background_upload_id"], name: "index_user_profiles_on_card_background_upload_id"
    t.index ["granted_title_badge_id"], name: "index_user_profiles_on_granted_title_badge_id"
    t.index ["profile_background_upload_id"], name: "index_user_profiles_on_profile_background_upload_id"
  end

  create_table "user_search_data", primary_key: "user_id", id: :integer, default: nil, force: :cascade do |t|
    t.tsvector "search_data"
    t.text "raw_data"
    t.text "locale"
    t.integer "version", default: 0
    t.index ["search_data"], name: "idx_search_user", using: :gin
  end

  create_table "user_second_factors", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "method", null: false
    t.string "data", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "last_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["method", "enabled"], name: "index_user_second_factors_on_method_and_enabled"
    t.index ["user_id"], name: "index_user_second_factors_on_user_id"
  end

  create_table "user_security_keys", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "credential_id", null: false
    t.string "public_key", null: false
    t.integer "factor_type", default: 0, null: false
    t.boolean "enabled", default: true, null: false
    t.string "name", null: false
    t.datetime "last_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credential_id"], name: "index_user_security_keys_on_credential_id", unique: true
    t.index ["factor_type", "enabled"], name: "index_user_security_keys_on_factor_type_and_enabled"
    t.index ["factor_type"], name: "index_user_security_keys_on_factor_type"
    t.index ["last_used"], name: "index_user_security_keys_on_last_used"
    t.index ["public_key"], name: "index_user_security_keys_on_public_key"
    t.index ["user_id"], name: "index_user_security_keys_on_user_id"
  end

  create_table "user_stats", primary_key: "user_id", id: :integer, default: nil, force: :cascade do |t|
    t.integer "topics_entered", default: 0, null: false
    t.integer "time_read", default: 0, null: false
    t.integer "days_visited", default: 0, null: false
    t.integer "posts_read_count", default: 0, null: false
    t.integer "likes_given", default: 0, null: false
    t.integer "likes_received", default: 0, null: false
    t.datetime "new_since", null: false
    t.datetime "read_faq"
    t.datetime "first_post_created_at"
    t.integer "post_count", default: 0, null: false
    t.integer "topic_count", default: 0, null: false
    t.float "bounce_score", default: 0.0, null: false
    t.datetime "reset_bounce_score_after"
    t.integer "flags_agreed", default: 0, null: false
    t.integer "flags_disagreed", default: 0, null: false
    t.integer "flags_ignored", default: 0, null: false
    t.datetime "first_unread_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "distinct_badge_count", default: 0, null: false
    t.datetime "first_unread_pm_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "digest_attempted_at"
    t.integer "post_edits_count"
    t.integer "draft_count", default: 0, null: false
  end

  create_table "user_uploads", force: :cascade do |t|
    t.integer "upload_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.index ["upload_id", "user_id"], name: "index_user_uploads_on_upload_id_and_user_id", unique: true
    t.index ["user_id", "upload_id"], name: "index_user_uploads_on_user_id_and_upload_id"
  end

  create_table "user_visits", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "visited_at", null: false
    t.integer "posts_read", default: 0
    t.boolean "mobile", default: false
    t.integer "time_read", default: 0, null: false
    t.index ["user_id", "visited_at", "time_read"], name: "index_user_visits_on_user_id_and_visited_at_and_time_read"
    t.index ["user_id", "visited_at"], name: "index_user_visits_on_user_id_and_visited_at", unique: true
    t.index ["visited_at", "mobile"], name: "index_user_visits_on_visited_at_and_mobile"
  end

  create_table "user_warnings", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "user_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_user_warnings_on_topic_id", unique: true
    t.index ["user_id"], name: "index_user_warnings_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", limit: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "seen_notification_id", default: 0, null: false
    t.datetime "last_posted_at"
    t.string "password_hash", limit: 64
    t.string "salt", limit: 32
    t.boolean "active", default: false, null: false
    t.string "username_lower", limit: 60, null: false
    t.datetime "last_seen_at"
    t.boolean "admin", default: false, null: false
    t.datetime "last_emailed_at"
    t.integer "trust_level", null: false
    t.boolean "approved", default: false, null: false
    t.integer "approved_by_id"
    t.datetime "approved_at"
    t.datetime "previous_visit_at"
    t.datetime "suspended_at"
    t.datetime "suspended_till"
    t.date "date_of_birth"
    t.integer "views", default: 0, null: false
    t.integer "flag_level", default: 0, null: false
    t.inet "ip_address"
    t.boolean "moderator", default: false
    t.string "title"
    t.integer "uploaded_avatar_id"
    t.string "locale", limit: 10
    t.integer "primary_group_id"
    t.inet "registration_ip_address"
    t.boolean "staged", default: false, null: false
    t.datetime "first_seen_at"
    t.datetime "silenced_till"
    t.integer "group_locked_trust_level"
    t.integer "manual_locked_trust_level"
    t.string "secure_identifier"
    t.integer "flair_group_id"
    t.index ["id"], name: "idx_users_admin", where: "admin"
    t.index ["id"], name: "idx_users_moderator", where: "moderator"
    t.index ["last_posted_at"], name: "index_users_on_last_posted_at"
    t.index ["last_seen_at"], name: "index_users_on_last_seen_at"
    t.index ["secure_identifier"], name: "index_users_on_secure_identifier", unique: true
    t.index ["uploaded_avatar_id"], name: "index_users_on_uploaded_avatar_id"
    t.index ["username"], name: "index_users_on_username", unique: true
    t.index ["username_lower"], name: "index_users_on_username_lower", unique: true
  end

  create_table "watched_words", id: :serial, force: :cascade do |t|
    t.string "word", null: false
    t.integer "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "replacement"
    t.index ["action", "word"], name: "index_watched_words_on_action_and_word", unique: true
  end

  create_table "web_crawler_requests", force: :cascade do |t|
    t.date "date", null: false
    t.string "user_agent", null: false
    t.integer "count", default: 0, null: false
    t.index ["date", "user_agent"], name: "index_web_crawler_requests_on_date_and_user_agent", unique: true
  end

  create_table "web_hook_event_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "web_hook_event_types_hooks", id: false, force: :cascade do |t|
    t.integer "web_hook_id", null: false
    t.integer "web_hook_event_type_id", null: false
    t.index ["web_hook_event_type_id", "web_hook_id"], name: "idx_web_hook_event_types_hooks_on_ids", unique: true
  end

  create_table "web_hook_events", id: :serial, force: :cascade do |t|
    t.integer "web_hook_id", null: false
    t.string "headers"
    t.text "payload"
    t.integer "status", default: 0
    t.string "response_headers"
    t.text "response_body"
    t.integer "duration", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["web_hook_id"], name: "index_web_hook_events_on_web_hook_id"
  end

  create_table "web_hooks", id: :serial, force: :cascade do |t|
    t.string "payload_url", null: false
    t.integer "content_type", default: 1, null: false
    t.integer "last_delivery_status", default: 1, null: false
    t.integer "status", default: 1, null: false
    t.string "secret", default: ""
    t.boolean "wildcard_web_hook", default: false, null: false
    t.boolean "verify_certificate", default: true, null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "javascript_caches", "theme_fields", on_delete: :cascade
  add_foreign_key "javascript_caches", "themes", on_delete: :cascade
  add_foreign_key "poll_options", "polls"
  add_foreign_key "poll_votes", "poll_options"
  add_foreign_key "poll_votes", "polls"
  add_foreign_key "poll_votes", "users"
  add_foreign_key "polls", "posts"
  add_foreign_key "user_profiles", "badges", column: "granted_title_badge_id"
  add_foreign_key "user_profiles", "uploads", column: "card_background_upload_id"
  add_foreign_key "user_profiles", "uploads", column: "profile_background_upload_id"
  add_foreign_key "user_security_keys", "users"
end
