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

ActiveRecord::Schema.define(version: 2022_12_06_012013) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "abuse_reports", id: :serial, force: :cascade do |t|
    t.integer "reporter_id"
    t.integer "user_id"
    t.text "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "message_html"
    t.integer "cached_markdown_version"
    t.index ["user_id"], name: "index_abuse_reports_on_user_id"
  end

  create_table "agent_activity_events", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.bigint "user_id"
    t.bigint "project_id"
    t.bigint "merge_request_id"
    t.bigint "agent_token_id"
    t.datetime_with_timezone "recorded_at", null: false
    t.integer "kind", limit: 2, null: false
    t.integer "level", limit: 2, null: false
    t.binary "sha"
    t.text "detail"
    t.index ["agent_id", "recorded_at", "id"], name: "index_agent_activity_events_on_agent_id_and_recorded_at_and_id"
    t.index ["agent_token_id"], name: "index_agent_activity_events_on_agent_token_id", where: "(agent_token_id IS NOT NULL)"
    t.index ["merge_request_id"], name: "index_agent_activity_events_on_merge_request_id", where: "(merge_request_id IS NOT NULL)"
    t.index ["project_id"], name: "index_agent_activity_events_on_project_id", where: "(project_id IS NOT NULL)"
    t.index ["user_id"], name: "index_agent_activity_events_on_user_id", where: "(user_id IS NOT NULL)"
    t.check_constraint "char_length(detail) <= 255", name: "check_068205e735"
  end

  create_table "agent_group_authorizations", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "agent_id", null: false
    t.jsonb "config", null: false
    t.index ["agent_id", "group_id"], name: "index_agent_group_authorizations_on_agent_id_and_group_id", unique: true
    t.index ["group_id"], name: "index_agent_group_authorizations_on_group_id"
  end

  create_table "agent_project_authorizations", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "agent_id", null: false
    t.jsonb "config", null: false
    t.index ["agent_id", "project_id"], name: "index_agent_project_authorizations_on_agent_id_and_project_id", unique: true
    t.index ["project_id"], name: "index_agent_project_authorizations_on_project_id"
  end

  create_table "alert_management_alert_assignees", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "alert_id", null: false
    t.index ["alert_id"], name: "index_alert_assignees_on_alert_id"
    t.index ["user_id", "alert_id"], name: "index_alert_assignees_on_user_id_and_alert_id", unique: true
  end

  create_table "alert_management_alert_metric_images", force: :cascade do |t|
    t.bigint "alert_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "file_store", limit: 2
    t.text "file", null: false
    t.text "url"
    t.text "url_text"
    t.index ["alert_id"], name: "index_alert_management_alert_metric_images_on_alert_id"
    t.check_constraint "char_length(file) <= 255", name: "check_70fafae519"
    t.check_constraint "char_length(url) <= 255", name: "check_4d811d9007"
    t.check_constraint "char_length(url_text) <= 128", name: "check_2587666252"
  end

  create_table "alert_management_alert_user_mentions", force: :cascade do |t|
    t.bigint "alert_management_alert_id", null: false
    t.bigint "note_id"
    t.integer "mentioned_users_ids", array: true
    t.integer "mentioned_projects_ids", array: true
    t.integer "mentioned_groups_ids", array: true
    t.index ["alert_management_alert_id", "note_id"], name: "index_alert_user_mentions_on_alert_id_and_note_id", unique: true
    t.index ["alert_management_alert_id"], name: "index_alert_user_mentions_on_alert_id", unique: true, where: "(note_id IS NULL)"
    t.index ["note_id"], name: "index_alert_user_mentions_on_note_id", unique: true, where: "(note_id IS NOT NULL)"
  end

  create_table "alert_management_alerts", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "started_at", null: false
    t.datetime_with_timezone "ended_at"
    t.integer "events", default: 1, null: false
    t.integer "iid", null: false
    t.integer "severity", limit: 2, default: 0, null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.binary "fingerprint"
    t.bigint "issue_id"
    t.bigint "project_id", null: false
    t.text "title", null: false
    t.text "description"
    t.text "service"
    t.text "monitoring_tool"
    t.text "hosts", default: [], null: false, array: true
    t.jsonb "payload", default: {}, null: false
    t.integer "prometheus_alert_id"
    t.integer "environment_id"
    t.integer "domain", limit: 2, default: 0
    t.index ["domain"], name: "index_alert_management_alerts_on_domain"
    t.index ["environment_id"], name: "index_alert_management_alerts_on_environment_id", where: "(environment_id IS NOT NULL)"
    t.index ["issue_id"], name: "index_alert_management_alerts_on_issue_id"
    t.index ["project_id", "fingerprint"], name: "index_unresolved_alerts_on_project_id_and_fingerprint", unique: true, where: "((fingerprint IS NOT NULL) AND (status <> 2))"
    t.index ["project_id", "iid"], name: "index_alert_management_alerts_on_project_id_and_iid", unique: true
    t.index ["prometheus_alert_id"], name: "index_alert_management_alerts_on_prometheus_alert_id", where: "(prometheus_alert_id IS NOT NULL)"
    t.check_constraint "char_length(description) <= 1000", name: "check_5e9e57cadb"
    t.check_constraint "char_length(monitoring_tool) <= 100", name: "check_2df3e2fdc1"
    t.check_constraint "char_length(service) <= 100", name: "check_bac14dddde"
    t.check_constraint "char_length(title) <= 200", name: "check_d1d1c2d14c"
  end

  create_table "alert_management_http_integrations", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.boolean "active", default: false, null: false
    t.text "encrypted_token", null: false
    t.text "encrypted_token_iv", null: false
    t.text "endpoint_identifier", null: false
    t.text "name", null: false
    t.jsonb "payload_example", default: {}, null: false
    t.jsonb "payload_attribute_mapping", default: {}, null: false
    t.index ["active", "project_id", "endpoint_identifier"], name: "index_http_integrations_on_active_and_project_and_endpoint", unique: true, where: "active"
    t.index ["project_id"], name: "index_alert_management_http_integrations_on_project_id"
    t.check_constraint "char_length(encrypted_token) <= 255", name: "check_f68577c4af"
    t.check_constraint "char_length(encrypted_token_iv) <= 255", name: "check_286943b636"
    t.check_constraint "char_length(endpoint_identifier) <= 255", name: "check_e270820180"
    t.check_constraint "char_length(name) <= 255", name: "check_392143ccf4"
  end

  create_table "allowed_email_domains", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "group_id", null: false
    t.string "domain", limit: 255, null: false
    t.index ["group_id"], name: "index_allowed_email_domains_on_group_id"
  end

  create_table "analytics_cycle_analytics_aggregations", primary_key: "group_id", id: :bigint, default: nil, force: :cascade do |t|
    t.integer "incremental_runtimes_in_seconds", default: [], null: false, array: true
    t.integer "incremental_processed_records", default: [], null: false, array: true
    t.integer "last_incremental_issues_id"
    t.integer "last_incremental_merge_requests_id"
    t.datetime_with_timezone "last_incremental_run_at"
    t.datetime_with_timezone "last_incremental_issues_updated_at"
    t.datetime_with_timezone "last_incremental_merge_requests_updated_at"
    t.datetime_with_timezone "last_full_run_at"
    t.datetime_with_timezone "last_consistency_check_updated_at"
    t.boolean "enabled", default: true, null: false
    t.integer "full_runtimes_in_seconds", default: [], null: false, array: true
    t.integer "full_processed_records", default: [], null: false, array: true
    t.datetime_with_timezone "last_full_merge_requests_updated_at"
    t.datetime_with_timezone "last_full_issues_updated_at"
    t.integer "last_full_issues_id"
    t.integer "last_full_merge_requests_id"
    t.bigint "last_consistency_check_issues_stage_event_hash_id"
    t.datetime_with_timezone "last_consistency_check_issues_start_event_timestamp"
    t.datetime_with_timezone "last_consistency_check_issues_end_event_timestamp"
    t.bigint "last_consistency_check_issues_issuable_id"
    t.bigint "last_consistency_check_merge_requests_stage_event_hash_id"
    t.datetime_with_timezone "last_consistency_check_merge_requests_start_event_timestamp"
    t.datetime_with_timezone "last_consistency_check_merge_requests_end_event_timestamp"
    t.bigint "last_consistency_check_merge_requests_issuable_id"
    t.index ["last_consistency_check_updated_at"], name: "ca_aggregations_last_consistency_check_updated_at", order: "NULLS FIRST", where: "(enabled IS TRUE)"
    t.index ["last_full_run_at"], name: "ca_aggregations_last_full_run_at", order: "NULLS FIRST", where: "(enabled IS TRUE)"
    t.index ["last_incremental_run_at"], name: "ca_aggregations_last_incremental_run_at", order: "NULLS FIRST", where: "(enabled IS TRUE)"
    t.check_constraint "cardinality(full_processed_records) <= 10", name: "full_processed_records_size"
    t.check_constraint "cardinality(full_runtimes_in_seconds) <= 10", name: "full_runtimes_in_seconds_size"
    t.check_constraint "cardinality(incremental_processed_records) <= 10"
    t.check_constraint "cardinality(incremental_runtimes_in_seconds) <= 10"
  end

  create_table "analytics_cycle_analytics_group_stages", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "relative_position"
    t.integer "start_event_identifier", null: false
    t.integer "end_event_identifier", null: false
    t.bigint "group_id", null: false
    t.bigint "start_event_label_id"
    t.bigint "end_event_label_id"
    t.boolean "hidden", default: false, null: false
    t.boolean "custom", default: true, null: false
    t.string "name", limit: 255, null: false
    t.bigint "group_value_stream_id", null: false
    t.bigint "stage_event_hash_id"
    t.index ["end_event_label_id"], name: "index_analytics_ca_group_stages_on_end_event_label_id"
    t.index ["group_id", "group_value_stream_id", "name"], name: "index_group_stages_on_group_id_group_value_stream_id_and_name", unique: true
    t.index ["group_id"], name: "index_analytics_ca_group_stages_on_group_id"
    t.index ["group_value_stream_id"], name: "index_analytics_ca_group_stages_on_value_stream_id"
    t.index ["id"], name: "index_analytics_cycle_analytics_group_stages_custom_only", where: "(custom = true)"
    t.index ["relative_position"], name: "index_analytics_ca_group_stages_on_relative_position"
    t.index ["stage_event_hash_id"], name: "index_group_stages_on_stage_event_hash_id"
    t.index ["start_event_label_id"], name: "index_analytics_ca_group_stages_on_start_event_label_id"
    t.check_constraint "stage_event_hash_id IS NOT NULL", name: "check_e6bd4271b5"
  end

  create_table "analytics_cycle_analytics_group_value_streams", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "group_id", null: false
    t.text "name", null: false
    t.index ["group_id", "name"], name: "index_analytics_ca_group_value_streams_on_group_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 100", name: "check_bc1ed5f1f7"
  end

  create_table "analytics_cycle_analytics_issue_stage_events", primary_key: ["stage_event_hash_id", "issue_id"], force: :cascade do |t|
    t.bigint "stage_event_hash_id", null: false
    t.bigint "issue_id", null: false
    t.bigint "group_id", null: false
    t.bigint "project_id", null: false
    t.bigint "milestone_id"
    t.bigint "author_id"
    t.datetime_with_timezone "start_event_timestamp", null: false
    t.datetime_with_timezone "end_event_timestamp"
    t.integer "state_id", limit: 2, default: 1, null: false
    t.index ["stage_event_hash_id", "group_id", "end_event_timestamp", "issue_id", "start_event_timestamp"], name: "index_issue_stage_events_group_duration", where: "(end_event_timestamp IS NOT NULL)"
    t.index ["stage_event_hash_id", "group_id", "start_event_timestamp", "issue_id"], name: "index_issue_stage_events_group_in_progress_duration", where: "((end_event_timestamp IS NULL) AND (state_id = 1))"
    t.index ["stage_event_hash_id", "project_id", "end_event_timestamp", "issue_id", "start_event_timestamp"], name: "index_issue_stage_events_project_duration", where: "(end_event_timestamp IS NOT NULL)"
    t.index ["stage_event_hash_id", "project_id", "start_event_timestamp", "issue_id"], name: "index_issue_stage_events_project_in_progress_duration", where: "((end_event_timestamp IS NULL) AND (state_id = 1))"
  end

  create_table "analytics_cycle_analytics_merge_request_stage_events", primary_key: ["stage_event_hash_id", "merge_request_id"], force: :cascade do |t|
    t.bigint "stage_event_hash_id", null: false
    t.bigint "merge_request_id", null: false
    t.bigint "group_id", null: false
    t.bigint "project_id", null: false
    t.bigint "milestone_id"
    t.bigint "author_id"
    t.datetime_with_timezone "start_event_timestamp", null: false
    t.datetime_with_timezone "end_event_timestamp"
    t.integer "state_id", limit: 2, default: 1, null: false
    t.index ["stage_event_hash_id", "group_id", "end_event_timestamp", "merge_request_id", "start_event_timestamp"], name: "index_merge_request_stage_events_group_duration", where: "(end_event_timestamp IS NOT NULL)"
    t.index ["stage_event_hash_id", "group_id", "start_event_timestamp", "merge_request_id"], name: "index_merge_request_stage_events_group_in_progress_duration", where: "((end_event_timestamp IS NULL) AND (state_id = 1))"
    t.index ["stage_event_hash_id", "project_id", "end_event_timestamp", "merge_request_id", "start_event_timestamp"], name: "index_merge_request_stage_events_project_duration", where: "(end_event_timestamp IS NOT NULL)"
    t.index ["stage_event_hash_id", "project_id", "start_event_timestamp", "merge_request_id"], name: "index_merge_request_stage_events_project_in_progress_duration", where: "((end_event_timestamp IS NULL) AND (state_id = 1))"
  end

  create_table "analytics_cycle_analytics_project_stages", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "relative_position"
    t.integer "start_event_identifier", null: false
    t.integer "end_event_identifier", null: false
    t.bigint "project_id", null: false
    t.bigint "start_event_label_id"
    t.bigint "end_event_label_id"
    t.boolean "hidden", default: false, null: false
    t.boolean "custom", default: true, null: false
    t.string "name", limit: 255, null: false
    t.bigint "project_value_stream_id", null: false
    t.bigint "stage_event_hash_id"
    t.index ["end_event_label_id"], name: "index_analytics_ca_project_stages_on_end_event_label_id"
    t.index ["project_id", "name"], name: "index_analytics_ca_project_stages_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_analytics_ca_project_stages_on_project_id"
    t.index ["project_value_stream_id"], name: "index_analytics_ca_project_stages_on_value_stream_id"
    t.index ["relative_position"], name: "index_analytics_ca_project_stages_on_relative_position"
    t.index ["stage_event_hash_id"], name: "index_project_stages_on_stage_event_hash_id"
    t.index ["start_event_label_id"], name: "index_analytics_ca_project_stages_on_start_event_label_id"
    t.check_constraint "stage_event_hash_id IS NOT NULL", name: "check_8f6019de1e"
  end

  create_table "analytics_cycle_analytics_project_value_streams", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.text "name", null: false
    t.index ["project_id", "name"], name: "index_analytics_ca_project_value_streams_on_project_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 100", name: "check_9b1970a898"
  end

  create_table "analytics_cycle_analytics_stage_event_hashes", force: :cascade do |t|
    t.binary "hash_sha256"
    t.index ["hash_sha256"], name: "index_cycle_analytics_stage_event_hashes_on_hash_sha_256", unique: true
  end

  create_table "analytics_devops_adoption_segments", force: :cascade do |t|
    t.datetime_with_timezone "last_recorded_at"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "namespace_id"
    t.integer "display_namespace_id"
    t.index ["display_namespace_id", "namespace_id"], name: "idx_devops_adoption_segments_namespaces_pair", unique: true
    t.index ["namespace_id"], name: "idx_analytics_devops_adoption_segments_on_namespace_id"
  end

  create_table "analytics_devops_adoption_snapshots", force: :cascade do |t|
    t.datetime_with_timezone "recorded_at", null: false
    t.boolean "issue_opened", null: false
    t.boolean "merge_request_opened", null: false
    t.boolean "merge_request_approved", null: false
    t.boolean "runner_configured", null: false
    t.boolean "pipeline_succeeded", null: false
    t.boolean "deploy_succeeded", null: false
    t.datetime_with_timezone "end_time", null: false
    t.integer "total_projects_count"
    t.integer "code_owners_used_count"
    t.integer "namespace_id"
    t.integer "sast_enabled_count"
    t.integer "dast_enabled_count"
    t.integer "dependency_scanning_enabled_count"
    t.integer "coverage_fuzzing_enabled_count"
    t.integer "vulnerability_management_used_count"
    t.index ["namespace_id", "end_time"], name: "idx_analytics_devops_adoption_snapshots_finalized", where: "(recorded_at >= end_time)"
    t.index ["namespace_id", "end_time"], name: "idx_devops_adoption_segments_namespace_end_time"
    t.index ["namespace_id", "recorded_at"], name: "idx_devops_adoption_segments_namespace_recorded_at"
    t.check_constraint "namespace_id IS NOT NULL", name: "check_3f472de131"
  end

  create_table "analytics_language_trend_repository_languages", primary_key: ["programming_language_id", "project_id", "snapshot_date"], force: :cascade do |t|
    t.integer "file_count", default: 0, null: false
    t.bigint "programming_language_id", null: false
    t.bigint "project_id", null: false
    t.integer "loc", default: 0, null: false
    t.integer "bytes", default: 0, null: false
    t.integer "percentage", limit: 2, default: 0, null: false
    t.date "snapshot_date", null: false
    t.index ["project_id"], name: "analytics_repository_languages_on_project_id"
  end

  create_table "analytics_usage_trends_measurements", force: :cascade do |t|
    t.bigint "count", null: false
    t.datetime_with_timezone "recorded_at", null: false
    t.integer "identifier", limit: 2, null: false
    t.index ["identifier", "recorded_at"], name: "index_on_instance_statistics_recorded_at_and_identifier", unique: true
  end

  create_table "appearances", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "logo"
    t.integer "updated_by"
    t.string "header_logo"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "description_html"
    t.integer "cached_markdown_version"
    t.text "new_project_guidelines"
    t.text "new_project_guidelines_html"
    t.text "header_message"
    t.text "header_message_html"
    t.text "footer_message"
    t.text "footer_message_html"
    t.text "message_background_color"
    t.text "message_font_color"
    t.string "favicon"
    t.boolean "email_header_and_footer_enabled", default: false, null: false
    t.text "profile_image_guidelines"
    t.text "profile_image_guidelines_html"
    t.check_constraint "char_length(profile_image_guidelines) <= 4096", name: "appearances_profile_image_guidelines"
  end

  create_table "application_setting_terms", id: :serial, force: :cascade do |t|
    t.integer "cached_markdown_version"
    t.text "terms", null: false
    t.text "terms_html"
  end

  create_table "application_settings", id: :serial, force: :cascade do |t|
    t.integer "default_projects_limit"
    t.boolean "signup_enabled"
    t.boolean "gravatar_enabled"
    t.text "sign_in_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "home_page_url"
    t.integer "default_branch_protection", default: 2
    t.text "help_text"
    t.text "restricted_visibility_levels"
    t.boolean "version_check_enabled", default: true
    t.integer "max_attachment_size", default: 10, null: false
    t.integer "default_project_visibility", default: 0, null: false
    t.integer "default_snippet_visibility", default: 0, null: false
    t.boolean "user_oauth_applications", default: true
    t.string "after_sign_out_path"
    t.integer "session_expire_delay", default: 10080, null: false
    t.text "import_sources"
    t.text "help_page_text"
    t.boolean "shared_runners_enabled", default: true, null: false
    t.integer "max_artifacts_size", default: 100, null: false
    t.string "runners_registration_token"
    t.integer "max_pages_size", default: 100, null: false
    t.boolean "require_two_factor_authentication", default: false
    t.integer "two_factor_grace_period", default: 48
    t.boolean "metrics_enabled", default: false
    t.string "metrics_host", default: "localhost"
    t.integer "metrics_pool_size", default: 16
    t.integer "metrics_timeout", default: 10
    t.integer "metrics_method_call_threshold", default: 10
    t.boolean "recaptcha_enabled", default: false
    t.integer "metrics_port", default: 8089
    t.boolean "akismet_enabled", default: false
    t.integer "metrics_sample_interval", default: 15
    t.boolean "email_author_in_body", default: false
    t.integer "default_group_visibility"
    t.boolean "repository_checks_enabled", default: false
    t.text "shared_runners_text"
    t.integer "metrics_packet_size", default: 1
    t.text "disabled_oauth_sign_in_sources"
    t.string "health_check_access_token"
    t.boolean "send_user_confirmation_email", default: false
    t.integer "container_registry_token_expire_delay", default: 5
    t.text "after_sign_up_text"
    t.boolean "user_default_external", default: false, null: false
    t.boolean "elasticsearch_indexing", default: false, null: false
    t.boolean "elasticsearch_search", default: false, null: false
    t.string "repository_storages", default: "default"
    t.string "enabled_git_access_protocol"
    t.boolean "usage_ping_enabled", default: true, null: false
    t.text "sign_in_text_html"
    t.text "help_page_text_html"
    t.text "shared_runners_text_html"
    t.text "after_sign_up_text_html"
    t.integer "rsa_key_restriction", default: 0, null: false
    t.integer "dsa_key_restriction", default: -1, null: false
    t.integer "ecdsa_key_restriction", default: 0, null: false
    t.integer "ed25519_key_restriction", default: 0, null: false
    t.boolean "housekeeping_enabled", default: true, null: false
    t.boolean "housekeeping_bitmaps_enabled", default: true, null: false
    t.integer "housekeeping_incremental_repack_period", default: 10, null: false
    t.integer "housekeeping_full_repack_period", default: 50, null: false
    t.integer "housekeeping_gc_period", default: 200, null: false
    t.boolean "html_emails_enabled", default: true
    t.string "plantuml_url"
    t.boolean "plantuml_enabled"
    t.integer "shared_runners_minutes", default: 0, null: false
    t.bigint "repository_size_limit", default: 0
    t.integer "terminal_max_session_time", default: 0, null: false
    t.integer "unique_ips_limit_per_user"
    t.integer "unique_ips_limit_time_window"
    t.boolean "unique_ips_limit_enabled", default: false, null: false
    t.string "default_artifacts_expire_in", default: "0", null: false
    t.string "elasticsearch_url", default: "http://localhost:9200"
    t.boolean "elasticsearch_aws", default: false, null: false
    t.string "elasticsearch_aws_region", default: "us-east-1"
    t.string "elasticsearch_aws_access_key"
    t.integer "geo_status_timeout", default: 10
    t.string "uuid"
    t.decimal "polling_interval_multiplier", default: "1.0", null: false
    t.integer "cached_markdown_version"
    t.boolean "check_namespace_plan", default: false, null: false
    t.integer "mirror_max_delay", default: 300, null: false
    t.integer "mirror_max_capacity", default: 100, null: false
    t.integer "mirror_capacity_threshold", default: 50, null: false
    t.boolean "prometheus_metrics_enabled", default: true, null: false
    t.boolean "authorized_keys_enabled", default: true, null: false
    t.boolean "help_page_hide_commercial_content", default: false
    t.string "help_page_support_url"
    t.boolean "slack_app_enabled", default: false
    t.string "slack_app_id"
    t.integer "performance_bar_allowed_group_id"
    t.boolean "allow_group_owners_to_manage_ldap", default: true, null: false
    t.boolean "hashed_storage_enabled", default: true, null: false
    t.boolean "project_export_enabled", default: true, null: false
    t.boolean "auto_devops_enabled", default: true, null: false
    t.boolean "throttle_unauthenticated_enabled", default: false, null: false
    t.integer "throttle_unauthenticated_requests_per_period", default: 3600, null: false
    t.integer "throttle_unauthenticated_period_in_seconds", default: 3600, null: false
    t.boolean "throttle_authenticated_api_enabled", default: false, null: false
    t.integer "throttle_authenticated_api_requests_per_period", default: 7200, null: false
    t.integer "throttle_authenticated_api_period_in_seconds", default: 3600, null: false
    t.boolean "throttle_authenticated_web_enabled", default: false, null: false
    t.integer "throttle_authenticated_web_requests_per_period", default: 7200, null: false
    t.integer "throttle_authenticated_web_period_in_seconds", default: 3600, null: false
    t.integer "gitaly_timeout_default", default: 55, null: false
    t.integer "gitaly_timeout_medium", default: 30, null: false
    t.integer "gitaly_timeout_fast", default: 10, null: false
    t.boolean "mirror_available", default: true, null: false
    t.boolean "password_authentication_enabled_for_web"
    t.boolean "password_authentication_enabled_for_git", default: true, null: false
    t.string "auto_devops_domain"
    t.boolean "external_authorization_service_enabled", default: false, null: false
    t.string "external_authorization_service_url"
    t.string "external_authorization_service_default_label"
    t.boolean "pages_domain_verification_enabled", default: true, null: false
    t.string "user_default_internal_regex"
    t.float "external_authorization_service_timeout", default: 0.5
    t.text "external_auth_client_cert"
    t.text "encrypted_external_auth_client_key"
    t.string "encrypted_external_auth_client_key_iv"
    t.string "encrypted_external_auth_client_key_pass"
    t.string "encrypted_external_auth_client_key_pass_iv"
    t.string "email_additional_text"
    t.boolean "enforce_terms", default: false
    t.integer "file_template_project_id"
    t.boolean "pseudonymizer_enabled", default: false, null: false
    t.boolean "hide_third_party_offers", default: false, null: false
    t.boolean "snowplow_enabled", default: false, null: false
    t.string "snowplow_collector_hostname"
    t.string "snowplow_cookie_domain"
    t.boolean "web_ide_clientside_preview_enabled", default: false, null: false
    t.boolean "user_show_add_ssh_key_message", default: true, null: false
    t.integer "custom_project_templates_group_id"
    t.integer "usage_stats_set_by_user_id"
    t.integer "receive_max_input_size"
    t.integer "diff_max_patch_bytes", default: 204800, null: false
    t.integer "archive_builds_in_seconds"
    t.string "commit_email_hostname"
    t.boolean "protected_ci_variables", default: true, null: false
    t.string "runners_registration_token_encrypted"
    t.integer "local_markdown_version", default: 0, null: false
    t.integer "first_day_of_week", default: 0, null: false
    t.boolean "elasticsearch_limit_indexing", default: false, null: false
    t.integer "default_project_creation", default: 2, null: false
    t.string "lets_encrypt_notification_email"
    t.boolean "lets_encrypt_terms_of_service_accepted", default: false, null: false
    t.string "geo_node_allowed_ips", default: "0.0.0.0/0, ::/0"
    t.integer "elasticsearch_shards", default: 5, null: false
    t.integer "elasticsearch_replicas", default: 1, null: false
    t.text "encrypted_lets_encrypt_private_key"
    t.text "encrypted_lets_encrypt_private_key_iv"
    t.string "required_instance_ci_template"
    t.boolean "dns_rebinding_protection_enabled", default: true, null: false
    t.boolean "default_project_deletion_protection", default: false, null: false
    t.boolean "grafana_enabled", default: false, null: false
    t.boolean "lock_memberships_to_ldap", default: false, null: false
    t.boolean "time_tracking_limit_to_hours", default: false, null: false
    t.string "grafana_url", default: "/-/grafana", null: false
    t.boolean "login_recaptcha_protection_enabled", default: false, null: false
    t.string "outbound_local_requests_whitelist", limit: 255, default: [], null: false, array: true
    t.integer "raw_blob_request_limit", default: 300, null: false
    t.boolean "allow_local_requests_from_web_hooks_and_services", default: false, null: false
    t.boolean "allow_local_requests_from_system_hooks", default: true, null: false
    t.bigint "instance_administration_project_id"
    t.boolean "asset_proxy_enabled", default: false, null: false
    t.string "asset_proxy_url"
    t.text "encrypted_asset_proxy_secret_key"
    t.string "encrypted_asset_proxy_secret_key_iv"
    t.string "static_objects_external_storage_url", limit: 255
    t.string "static_objects_external_storage_auth_token", limit: 255
    t.integer "max_personal_access_token_lifetime"
    t.boolean "throttle_protected_paths_enabled", default: false, null: false
    t.integer "throttle_protected_paths_requests_per_period", default: 10, null: false
    t.integer "throttle_protected_paths_period_in_seconds", default: 60, null: false
    t.string "protected_paths", limit: 255, default: ["/users/password", "/users/sign_in", "/api/v3/session.json", "/api/v3/session", "/api/v4/session.json", "/api/v4/session", "/users", "/users/confirmation", "/unsubscribes/", "/import/github/personal_access_token", "/admin/session"], array: true
    t.boolean "throttle_incident_management_notification_enabled", default: false, null: false
    t.integer "throttle_incident_management_notification_period_in_seconds", default: 3600
    t.integer "throttle_incident_management_notification_per_period", default: 3600
    t.integer "push_event_hooks_limit", default: 3, null: false
    t.integer "push_event_activities_limit", default: 3, null: false
    t.string "custom_http_clone_url_root", limit: 511
    t.integer "deletion_adjourned_period", default: 7, null: false
    t.date "license_trial_ends_on"
    t.boolean "eks_integration_enabled", default: false, null: false
    t.string "eks_account_id", limit: 128
    t.string "eks_access_key_id", limit: 128
    t.string "encrypted_eks_secret_access_key_iv", limit: 255
    t.text "encrypted_eks_secret_access_key"
    t.string "snowplow_app_id"
    t.datetime_with_timezone "productivity_analytics_start_date"
    t.string "default_ci_config_path", limit: 255
    t.boolean "sourcegraph_enabled", default: false, null: false
    t.string "sourcegraph_url", limit: 255
    t.boolean "sourcegraph_public_only", default: true, null: false
    t.bigint "snippet_size_limit", default: 52428800, null: false
    t.integer "minimum_password_length", default: 8, null: false
    t.text "encrypted_akismet_api_key"
    t.string "encrypted_akismet_api_key_iv", limit: 255
    t.text "encrypted_elasticsearch_aws_secret_access_key"
    t.string "encrypted_elasticsearch_aws_secret_access_key_iv", limit: 255
    t.text "encrypted_recaptcha_private_key"
    t.string "encrypted_recaptcha_private_key_iv", limit: 255
    t.text "encrypted_recaptcha_site_key"
    t.string "encrypted_recaptcha_site_key_iv", limit: 255
    t.text "encrypted_slack_app_secret"
    t.string "encrypted_slack_app_secret_iv", limit: 255
    t.text "encrypted_slack_app_verification_token"
    t.string "encrypted_slack_app_verification_token_iv", limit: 255
    t.boolean "force_pages_access_control", default: false, null: false
    t.boolean "updating_name_disabled_for_users", default: false, null: false
    t.integer "instance_administrators_group_id"
    t.integer "elasticsearch_indexed_field_length_limit", default: 0, null: false
    t.integer "elasticsearch_max_bulk_size_mb", limit: 2, default: 10, null: false
    t.integer "elasticsearch_max_bulk_concurrency", limit: 2, default: 10, null: false
    t.boolean "disable_overriding_approvers_per_merge_request", default: false, null: false
    t.boolean "prevent_merge_requests_author_approval", default: false, null: false
    t.boolean "prevent_merge_requests_committers_approval", default: false, null: false
    t.boolean "email_restrictions_enabled", default: false, null: false
    t.text "email_restrictions"
    t.boolean "npm_package_requests_forwarding", default: true, null: false
    t.boolean "container_expiration_policies_enable_historic_entries", default: false, null: false
    t.integer "issues_create_limit", default: 0, null: false
    t.bigint "push_rule_id"
    t.boolean "group_owners_can_manage_default_branch_protection", default: true, null: false
    t.text "container_registry_vendor", default: "", null: false
    t.text "container_registry_version", default: "", null: false
    t.text "container_registry_features", default: [], null: false, array: true
    t.text "spam_check_endpoint_url"
    t.boolean "spam_check_endpoint_enabled", default: false, null: false
    t.boolean "elasticsearch_pause_indexing", default: false, null: false
    t.jsonb "repository_storages_weighted", default: {}, null: false
    t.integer "max_import_size", default: 0, null: false
    t.integer "compliance_frameworks", limit: 2, default: [], null: false, array: true
    t.boolean "notify_on_unknown_sign_in", default: true, null: false
    t.text "default_branch_name"
    t.integer "project_import_limit", default: 6, null: false
    t.integer "project_export_limit", default: 6, null: false
    t.integer "project_download_export_limit", default: 1, null: false
    t.integer "group_import_limit", default: 6, null: false
    t.integer "group_export_limit", default: 6, null: false
    t.integer "group_download_export_limit", default: 1, null: false
    t.boolean "maintenance_mode", default: false, null: false
    t.text "maintenance_mode_message"
    t.bigint "wiki_page_max_content_bytes", default: 52428800, null: false
    t.integer "elasticsearch_indexed_file_size_limit_kb", default: 1024, null: false
    t.boolean "enforce_namespace_storage_limit", default: false, null: false
    t.integer "container_registry_delete_tags_service_timeout", default: 250, null: false
    t.string "kroki_url"
    t.boolean "kroki_enabled"
    t.integer "elasticsearch_client_request_timeout", default: 0, null: false
    t.boolean "gitpod_enabled", default: false, null: false
    t.text "gitpod_url", default: "https://gitpod.io/"
    t.string "abuse_notification_email"
    t.boolean "require_admin_approval_after_user_signup", default: true, null: false
    t.text "help_page_documentation_base_url"
    t.boolean "automatic_purchased_storage_allocation", default: false, null: false
    t.text "encrypted_ci_jwt_signing_key"
    t.text "encrypted_ci_jwt_signing_key_iv"
    t.integer "container_registry_expiration_policies_worker_capacity", default: 4, null: false
    t.boolean "elasticsearch_analyzers_smartcn_enabled", default: false, null: false
    t.boolean "elasticsearch_analyzers_smartcn_search", default: false, null: false
    t.boolean "elasticsearch_analyzers_kuromoji_enabled", default: false, null: false
    t.boolean "elasticsearch_analyzers_kuromoji_search", default: false, null: false
    t.boolean "secret_detection_token_revocation_enabled", default: false, null: false
    t.text "secret_detection_token_revocation_url"
    t.text "encrypted_secret_detection_token_revocation_token"
    t.text "encrypted_secret_detection_token_revocation_token_iv"
    t.boolean "domain_denylist_enabled", default: false
    t.text "domain_denylist"
    t.text "domain_allowlist"
    t.integer "new_user_signups_cap"
    t.text "encrypted_cloud_license_auth_token"
    t.text "encrypted_cloud_license_auth_token_iv"
    t.text "secret_detection_revocation_token_types_url"
    t.boolean "disable_feed_token", default: false, null: false
    t.text "personal_access_token_prefix", default: "glpat-"
    t.text "rate_limiting_response_text"
    t.boolean "invisible_captcha_enabled", default: false, null: false
    t.integer "container_registry_cleanup_tags_service_max_list_size", default: 200, null: false
    t.integer "git_two_factor_session_expiry", default: 15, null: false
    t.boolean "keep_latest_artifact", default: true, null: false
    t.integer "notes_create_limit", default: 300, null: false
    t.text "notes_create_limit_allowlist", default: [], null: false, array: true
    t.jsonb "kroki_formats", default: {}, null: false
    t.boolean "in_product_marketing_emails_enabled", default: true, null: false
    t.text "asset_proxy_whitelist"
    t.boolean "admin_mode", default: false, null: false
    t.boolean "delayed_project_removal", default: false, null: false
    t.boolean "lock_delayed_project_removal", default: false, null: false
    t.integer "external_pipeline_validation_service_timeout"
    t.text "encrypted_external_pipeline_validation_service_token"
    t.text "encrypted_external_pipeline_validation_service_token_iv"
    t.text "external_pipeline_validation_service_url"
    t.integer "throttle_unauthenticated_packages_api_requests_per_period", default: 800, null: false
    t.integer "throttle_unauthenticated_packages_api_period_in_seconds", default: 15, null: false
    t.integer "throttle_authenticated_packages_api_requests_per_period", default: 1000, null: false
    t.integer "throttle_authenticated_packages_api_period_in_seconds", default: 15, null: false
    t.boolean "throttle_unauthenticated_packages_api_enabled", default: false, null: false
    t.boolean "throttle_authenticated_packages_api_enabled", default: false, null: false
    t.boolean "deactivate_dormant_users", default: false, null: false
    t.integer "whats_new_variant", limit: 2, default: 0
    t.binary "encrypted_spam_check_api_key"
    t.binary "encrypted_spam_check_api_key_iv"
    t.boolean "floc_enabled", default: false, null: false
    t.text "elasticsearch_username"
    t.binary "encrypted_elasticsearch_password"
    t.binary "encrypted_elasticsearch_password_iv"
    t.integer "diff_max_lines", default: 50000, null: false
    t.integer "diff_max_files", default: 1000, null: false
    t.string "valid_runner_registrars", default: ["project", "group"], array: true
    t.binary "encrypted_mailgun_signing_key"
    t.binary "encrypted_mailgun_signing_key_iv"
    t.boolean "mailgun_events_enabled", default: false, null: false
    t.boolean "usage_ping_features_enabled", default: false, null: false
    t.binary "encrypted_customers_dot_jwt_signing_key"
    t.binary "encrypted_customers_dot_jwt_signing_key_iv"
    t.boolean "pypi_package_requests_forwarding", default: true, null: false
    t.integer "throttle_unauthenticated_files_api_requests_per_period", default: 125, null: false
    t.integer "throttle_unauthenticated_files_api_period_in_seconds", default: 15, null: false
    t.integer "throttle_authenticated_files_api_requests_per_period", default: 500, null: false
    t.integer "throttle_authenticated_files_api_period_in_seconds", default: 15, null: false
    t.boolean "throttle_unauthenticated_files_api_enabled", default: false, null: false
    t.boolean "throttle_authenticated_files_api_enabled", default: false, null: false
    t.bigint "max_yaml_size_bytes", default: 1048576, null: false
    t.integer "max_yaml_depth", default: 100, null: false
    t.integer "throttle_authenticated_git_lfs_requests_per_period", default: 1000, null: false
    t.integer "throttle_authenticated_git_lfs_period_in_seconds", default: 60, null: false
    t.boolean "throttle_authenticated_git_lfs_enabled", default: false, null: false
    t.boolean "user_deactivation_emails_enabled", default: true, null: false
    t.boolean "throttle_unauthenticated_api_enabled", default: false, null: false
    t.integer "throttle_unauthenticated_api_requests_per_period", default: 3600, null: false
    t.integer "throttle_unauthenticated_api_period_in_seconds", default: 3600, null: false
    t.integer "jobs_per_stage_page_size", default: 200, null: false
    t.integer "sidekiq_job_limiter_mode", limit: 2, default: 1, null: false
    t.integer "sidekiq_job_limiter_compression_threshold_bytes", default: 100000, null: false
    t.integer "sidekiq_job_limiter_limit_bytes", default: 0, null: false
    t.boolean "suggest_pipeline_enabled", default: true, null: false
    t.integer "throttle_unauthenticated_deprecated_api_requests_per_period", default: 1800, null: false
    t.integer "throttle_unauthenticated_deprecated_api_period_in_seconds", default: 3600, null: false
    t.boolean "throttle_unauthenticated_deprecated_api_enabled", default: false, null: false
    t.integer "throttle_authenticated_deprecated_api_requests_per_period", default: 3600, null: false
    t.integer "throttle_authenticated_deprecated_api_period_in_seconds", default: 3600, null: false
    t.boolean "throttle_authenticated_deprecated_api_enabled", default: false, null: false
    t.integer "dependency_proxy_ttl_group_policy_worker_capacity", limit: 2, default: 2, null: false
    t.text "content_validation_endpoint_url", comment: "JiHu-specific column"
    t.binary "encrypted_content_validation_api_key", comment: "JiHu-specific column"
    t.binary "encrypted_content_validation_api_key_iv", comment: "JiHu-specific column"
    t.boolean "content_validation_endpoint_enabled", default: false, null: false, comment: "JiHu-specific column"
    t.boolean "sentry_enabled", default: false, null: false
    t.text "sentry_dsn"
    t.text "sentry_clientside_dsn"
    t.text "sentry_environment"
    t.integer "max_ssh_key_lifetime"
    t.text "static_objects_external_storage_auth_token_encrypted"
    t.jsonb "future_subscriptions", default: [], null: false
    t.integer "packages_cleanup_package_file_worker_capacity", limit: 2, default: 2, null: false
    t.integer "container_registry_import_max_tags_count", default: 100, null: false
    t.integer "container_registry_import_max_retries", default: 3, null: false
    t.integer "container_registry_import_start_max_retries", default: 50, null: false
    t.integer "container_registry_import_max_step_duration", default: 300, null: false
    t.text "container_registry_import_target_plan", default: "free", null: false
    t.datetime_with_timezone "container_registry_import_created_before", default: "2022-01-23 00:00:00", null: false
    t.integer "runner_token_expiration_interval"
    t.integer "group_runner_token_expiration_interval"
    t.integer "project_runner_token_expiration_interval"
    t.integer "ecdsa_sk_key_restriction", default: 0, null: false
    t.integer "ed25519_sk_key_restriction", default: 0, null: false
    t.integer "users_get_by_id_limit", default: 300, null: false
    t.text "users_get_by_id_limit_allowlist", default: [], null: false, array: true
    t.boolean "container_registry_expiration_policies_caching", default: true, null: false
    t.integer "search_rate_limit", default: 300, null: false
    t.integer "search_rate_limit_unauthenticated", default: 100, null: false
    t.binary "encrypted_database_grafana_api_key"
    t.binary "encrypted_database_grafana_api_key_iv"
    t.text "database_grafana_api_url"
    t.text "database_grafana_tag"
    t.text "public_runner_releases_url", default: "https://gitlab.com/api/v4/projects/gitlab-org%2Fgitlab-runner/releases", null: false
    t.boolean "password_uppercase_required", default: false, null: false
    t.boolean "password_lowercase_required", default: false, null: false
    t.boolean "password_number_required", default: false, null: false
    t.boolean "password_symbol_required", default: false, null: false
    t.binary "encrypted_arkose_labs_public_api_key"
    t.binary "encrypted_arkose_labs_public_api_key_iv"
    t.binary "encrypted_arkose_labs_private_api_key"
    t.binary "encrypted_arkose_labs_private_api_key_iv"
    t.text "arkose_labs_verify_api_url"
    t.boolean "delete_inactive_projects", default: false, null: false
    t.integer "inactive_projects_delete_after_months", default: 2, null: false
    t.integer "inactive_projects_min_size_mb", default: 0, null: false
    t.integer "inactive_projects_send_warning_email_after_months", default: 1, null: false
    t.boolean "delayed_group_deletion", default: true, null: false
    t.boolean "maven_package_requests_forwarding", default: true, null: false
    t.text "arkose_labs_namespace", default: "client", null: false
    t.integer "max_export_size", default: 0
    t.binary "encrypted_slack_app_signing_secret"
    t.binary "encrypted_slack_app_signing_secret_iv"
    t.integer "container_registry_pre_import_timeout", default: 1800, null: false
    t.integer "container_registry_import_timeout", default: 600, null: false
    t.integer "pipeline_limit_per_project_user_sha", default: 0, null: false
    t.boolean "dingtalk_integration_enabled", default: false, null: false, comment: "JiHu-specific column"
    t.binary "encrypted_dingtalk_corpid", comment: "JiHu-specific column"
    t.binary "encrypted_dingtalk_corpid_iv", comment: "JiHu-specific column"
    t.binary "encrypted_dingtalk_app_key", comment: "JiHu-specific column"
    t.binary "encrypted_dingtalk_app_key_iv", comment: "JiHu-specific column"
    t.binary "encrypted_dingtalk_app_secret", comment: "JiHu-specific column"
    t.binary "encrypted_dingtalk_app_secret_iv", comment: "JiHu-specific column"
    t.text "jira_connect_application_key"
    t.text "globally_allowed_ips", default: "", null: false
    t.decimal "container_registry_pre_import_tags_rate", precision: 6, scale: 2, default: "0.5", null: false
    t.boolean "license_usage_data_exported", default: false, null: false
    t.boolean "phone_verification_code_enabled", default: false, null: false, comment: "JiHu-specific column"
    t.integer "max_number_of_repository_downloads", limit: 2, default: 0, null: false
    t.integer "max_number_of_repository_downloads_within_time_period", default: 0, null: false
    t.boolean "feishu_integration_enabled", default: false, null: false, comment: "JiHu-specific column"
    t.binary "encrypted_feishu_app_key", comment: "JiHu-specific column"
    t.binary "encrypted_feishu_app_key_iv", comment: "JiHu-specific column"
    t.binary "encrypted_feishu_app_secret", comment: "JiHu-specific column"
    t.binary "encrypted_feishu_app_secret_iv", comment: "JiHu-specific column"
    t.boolean "error_tracking_enabled", default: false, null: false
    t.text "error_tracking_api_url"
    t.text "git_rate_limit_users_allowlist", default: [], null: false, array: true
    t.text "error_tracking_access_token_encrypted"
    t.boolean "invitation_flow_enforcement", default: false, null: false
    t.integer "package_registry_cleanup_policies_worker_capacity", default: 2, null: false
    t.integer "deactivate_dormant_users_period", default: 90, null: false
    t.boolean "auto_ban_user_on_excessive_projects_download", default: false, null: false
    t.integer "max_pages_custom_domains_per_project", default: 0, null: false
    t.text "cube_api_base_url"
    t.binary "encrypted_cube_api_key"
    t.binary "encrypted_cube_api_key_iv"
    t.text "jitsu_host"
    t.text "jitsu_project_xid"
    t.text "clickhouse_connection_string"
    t.text "jitsu_administrator_email"
    t.binary "encrypted_jitsu_administrator_password"
    t.binary "encrypted_jitsu_administrator_password_iv"
    t.boolean "dashboard_limit_enabled", default: false, null: false
    t.integer "dashboard_limit", default: 0, null: false
    t.integer "dashboard_notification_limit", default: 0, null: false
    t.integer "dashboard_enforcement_limit", default: 0, null: false
    t.date "dashboard_limit_new_namespace_creation_enforcement_date"
    t.boolean "can_create_group", default: true, null: false
    t.boolean "lock_maven_package_requests_forwarding", default: false, null: false
    t.boolean "lock_pypi_package_requests_forwarding", default: false, null: false
    t.boolean "lock_npm_package_requests_forwarding", default: false, null: false
    t.text "jira_connect_proxy_url"
    t.boolean "password_expiration_enabled", default: false, null: false, comment: "JiHu-specific column"
    t.integer "password_expires_in_days", default: 90, null: false, comment: "JiHu-specific column"
    t.integer "password_expires_notice_before_days", default: 7, null: false, comment: "JiHu-specific column"
    t.boolean "product_analytics_enabled", default: false, null: false
    t.integer "email_confirmation_setting", limit: 2, default: 0
    t.boolean "disable_admin_oauth_scopes", default: false, null: false
    t.text "default_preferred_language", default: "en", null: false
    t.boolean "disable_download_button", default: false, null: false, comment: "JiHu-specific column"
    t.binary "encrypted_telesign_customer_xid"
    t.binary "encrypted_telesign_customer_xid_iv"
    t.binary "encrypted_telesign_api_key"
    t.binary "encrypted_telesign_api_key_iv"
    t.index ["custom_project_templates_group_id"], name: "index_application_settings_on_custom_project_templates_group_id"
    t.index ["file_template_project_id"], name: "index_application_settings_on_file_template_project_id"
    t.index ["instance_administration_project_id"], name: "index_applicationsettings_on_instance_administration_project_id"
    t.index ["instance_administrators_group_id"], name: "index_application_settings_on_instance_administrators_group_id"
    t.index ["push_rule_id"], name: "index_application_settings_on_push_rule_id", unique: true
    t.index ["usage_stats_set_by_user_id"], name: "index_application_settings_on_usage_stats_set_by_user_id"
    t.check_constraint "cardinality(git_rate_limit_users_allowlist) <= 100", name: "app_settings_git_rate_limit_users_allowlist_max_usernames"
    t.check_constraint "char_length((kroki_url)::text) <= 1024", name: "check_17d9558205"
    t.check_constraint "char_length(arkose_labs_namespace) <= 255", name: "check_7ccfe2764a"
    t.check_constraint "char_length(arkose_labs_verify_api_url) <= 255", name: "check_f6563bc000"
    t.check_constraint "char_length(clickhouse_connection_string) <= 1024", name: "check_d4865d70f3"
    t.check_constraint "char_length(container_registry_import_target_plan) <= 255", name: "check_3559645ae5"
    t.check_constraint "char_length(container_registry_vendor) <= 255", name: "check_d03919528d"
    t.check_constraint "char_length(container_registry_version) <= 255", name: "check_e5aba18f02"
    t.check_constraint "char_length(content_validation_endpoint_url) <= 255", name: "check_5a84c3ffdc"
    t.check_constraint "char_length(cube_api_base_url) <= 512", name: "check_8e7df605a1"
    t.check_constraint "char_length(database_grafana_api_url) <= 255", name: "check_3455368420"
    t.check_constraint "char_length(database_grafana_tag) <= 255", name: "check_2b820eaac3"
    t.check_constraint "char_length(default_branch_name) <= 255", name: "check_51700b31b5"
    t.check_constraint "char_length(default_preferred_language) <= 32", name: "check_e2692d7523"
    t.check_constraint "char_length(elasticsearch_username) <= 255", name: "check_e5024c8801"
    t.check_constraint "char_length(encrypted_ci_jwt_signing_key_iv) <= 255", name: "check_85a39b68ff"
    t.check_constraint "char_length(encrypted_cloud_license_auth_token_iv) <= 255", name: "check_ef6176834f"
    t.check_constraint "char_length(error_tracking_access_token_encrypted) <= 255", name: "check_5688c70478"
    t.check_constraint "char_length(error_tracking_api_url) <= 255", name: "check_492cc1354d"
    t.check_constraint "char_length(external_pipeline_validation_service_url) <= 255", name: "app_settings_ext_pipeline_validation_service_url_text_limit"
    t.check_constraint "char_length(gitpod_url) <= 255", name: "check_2dba05b802"
    t.check_constraint "char_length(globally_allowed_ips) <= 255", name: "check_734cc9407a"
    t.check_constraint "char_length(help_page_documentation_base_url) <= 255", name: "check_57123c9593"
    t.check_constraint "char_length(jira_connect_application_key) <= 255", name: "check_e2dd6e290a"
    t.check_constraint "char_length(jira_connect_proxy_url) <= 255", name: "check_4847426287"
    t.check_constraint "char_length(jitsu_administrator_email) <= 255", name: "check_ec3ca9aa8d"
    t.check_constraint "char_length(jitsu_host) <= 255", name: "check_dea8792229"
    t.check_constraint "char_length(jitsu_project_xid) <= 255", name: "check_fc732c181e"
    t.check_constraint "char_length(maintenance_mode_message) <= 255", name: "check_9c6c447a13"
    t.check_constraint "char_length(personal_access_token_prefix) <= 20", name: "check_718b4458ae"
    t.check_constraint "char_length(public_runner_releases_url) <= 255", name: "check_8dca35398a"
    t.check_constraint "char_length(rate_limiting_response_text) <= 255", name: "check_7227fad848"
    t.check_constraint "char_length(secret_detection_revocation_token_types_url) <= 255", name: "check_a5704163cc"
    t.check_constraint "char_length(secret_detection_token_revocation_url) <= 255", name: "check_9a719834eb"
    t.check_constraint "char_length(sentry_clientside_dsn) <= 255", name: "check_3def0f1829"
    t.check_constraint "char_length(sentry_dsn) <= 255", name: "check_4f8b811780"
    t.check_constraint "char_length(sentry_environment) <= 255", name: "check_5bcba483c4"
    t.check_constraint "char_length(spam_check_endpoint_url) <= 255", name: "check_d820146492"
    t.check_constraint "char_length(static_objects_external_storage_auth_token_encrypted) <= 255", name: "check_32710817e9"
    t.check_constraint "container_registry_cleanup_tags_service_max_list_size >= 0", name: "app_settings_container_reg_cleanup_tags_max_list_size_positive"
    t.check_constraint "container_registry_expiration_policies_worker_capacity >= 0", name: "app_settings_registry_exp_policies_worker_capacity_positive"
    t.check_constraint "container_registry_pre_import_tags_rate >= (0)::numeric", name: "app_settings_container_registry_pre_import_tags_rate_positive"
    t.check_constraint "dependency_proxy_ttl_group_policy_worker_capacity >= 0", name: "app_settings_dep_proxy_ttl_policies_worker_capacity_positive"
    t.check_constraint "max_pages_custom_domains_per_project >= 0", name: "app_settings_max_pages_custom_domains_per_project_check"
    t.check_constraint "max_yaml_depth > 0", name: "app_settings_yaml_max_depth_positive"
    t.check_constraint "max_yaml_size_bytes > 0", name: "app_settings_yaml_max_size_positive"
    t.check_constraint "package_registry_cleanup_policies_worker_capacity >= 0", name: "app_settings_pkg_registry_cleanup_pol_worker_capacity_gte_zero"
    t.check_constraint "packages_cleanup_package_file_worker_capacity >= 0", name: "app_settings_p_cleanup_package_file_worker_capacity_positive"
  end

  create_table "approval_merge_request_rule_sources", force: :cascade do |t|
    t.bigint "approval_merge_request_rule_id", null: false
    t.bigint "approval_project_rule_id", null: false
    t.index ["approval_merge_request_rule_id"], name: "index_approval_merge_request_rule_sources_1", unique: true
    t.index ["approval_project_rule_id"], name: "index_approval_merge_request_rule_sources_2"
  end

  create_table "approval_merge_request_rules", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "merge_request_id", null: false
    t.integer "approvals_required", limit: 2, default: 0, null: false
    t.string "name", null: false
    t.integer "rule_type", limit: 2, default: 1, null: false
    t.integer "report_type", limit: 2
    t.text "section"
    t.boolean "modified_from_project_rule", default: false, null: false
    t.integer "orchestration_policy_idx", limit: 2
    t.integer "vulnerabilities_allowed", limit: 2, default: 0, null: false
    t.text "scanners", default: [], null: false, array: true
    t.text "severity_levels", default: [], null: false, array: true
    t.text "vulnerability_states", default: ["newly_detected"], null: false, array: true
    t.bigint "security_orchestration_policy_configuration_id"
    t.index ["created_at"], name: "index_created_at_on_codeowner_approval_merge_request_rules", where: "((rule_type = 2) AND (section <> 'codeowners'::text))"
    t.index ["id"], name: "scan_finding_approval_mr_rule_index_id", where: "(report_type = 4)"
    t.index ["merge_request_id", "created_at"], name: "scan_finding_approval_mr_rule_index_mr_id_and_created_at", where: "(report_type = 4)"
    t.index ["merge_request_id", "name", "section"], name: "index_approval_rule_name_for_sectional_code_owners_rule_type", unique: true, where: "(rule_type = 2)"
    t.index ["merge_request_id", "name"], name: "index_approval_rule_name_for_code_owners_rule_type", unique: true, where: "((rule_type = 2) AND (section IS NULL))"
    t.index ["merge_request_id", "rule_type"], name: "any_approver_merge_request_rule_type_unique_index", unique: true, where: "(rule_type = 4)"
    t.index ["merge_request_id"], name: "approval_mr_rule_index_merge_request_id"
    t.index ["merge_request_id"], name: "index_approval_rules_code_owners_rule_type", where: "(rule_type = 2)"
    t.index ["merge_request_id"], name: "scan_finding_approval_mr_rule_index_merge_request_id", where: "(report_type = 4)"
    t.index ["security_orchestration_policy_configuration_id"], name: "idx_approval_merge_request_rules_on_sec_orchestration_config_id"
    t.check_constraint "char_length(section) <= 255", name: "check_6fca5928b2"
  end

  create_table "approval_merge_request_rules_approved_approvers", force: :cascade do |t|
    t.bigint "approval_merge_request_rule_id", null: false
    t.integer "user_id", null: false
    t.index ["approval_merge_request_rule_id", "user_id"], name: "index_approval_merge_request_rules_approved_approvers_1", unique: true
    t.index ["user_id"], name: "index_approval_merge_request_rules_approved_approvers_2"
  end

  create_table "approval_merge_request_rules_groups", force: :cascade do |t|
    t.bigint "approval_merge_request_rule_id", null: false
    t.integer "group_id", null: false
    t.index ["approval_merge_request_rule_id", "group_id"], name: "index_approval_merge_request_rules_groups_1", unique: true
    t.index ["group_id"], name: "index_approval_merge_request_rules_groups_2"
  end

  create_table "approval_merge_request_rules_users", force: :cascade do |t|
    t.bigint "approval_merge_request_rule_id", null: false
    t.integer "user_id", null: false
    t.index ["approval_merge_request_rule_id", "user_id"], name: "index_approval_merge_request_rules_users_1", unique: true
    t.index ["user_id"], name: "index_approval_merge_request_rules_users_2"
  end

  create_table "approval_project_rules", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "project_id", null: false
    t.integer "approvals_required", limit: 2, default: 0, null: false
    t.string "name", null: false
    t.integer "rule_type", limit: 2, default: 0, null: false
    t.text "scanners", default: [], array: true
    t.integer "vulnerabilities_allowed", limit: 2, default: 0, null: false
    t.text "severity_levels", default: [], null: false, array: true
    t.integer "report_type", limit: 2
    t.text "vulnerability_states", default: ["newly_detected"], null: false, array: true
    t.integer "orchestration_policy_idx", limit: 2
    t.boolean "applies_to_all_protected_branches", default: false, null: false
    t.bigint "security_orchestration_policy_configuration_id"
    t.index ["created_at", "project_id"], name: "scan_finding_approval_project_rule_index_created_at_project_id", where: "(report_type = 4)"
    t.index ["id"], name: "index_approval_project_rules_on_id_with_regular_type", where: "(rule_type = 0)"
    t.index ["project_id"], name: "any_approver_project_rule_type_unique_index", unique: true, where: "(rule_type = 3)"
    t.index ["project_id"], name: "index_approval_project_rules_on_project_id"
    t.index ["project_id"], name: "scan_finding_approval_project_rule_index_project_id", where: "(report_type = 4)"
    t.index ["report_type"], name: "index_approval_project_rules_report_type"
    t.index ["rule_type"], name: "index_approval_project_rules_on_rule_type"
    t.index ["security_orchestration_policy_configuration_id"], name: "idx_approval_project_rules_on_sec_orchestration_config_id"
  end

  create_table "approval_project_rules_groups", force: :cascade do |t|
    t.bigint "approval_project_rule_id", null: false
    t.integer "group_id", null: false
    t.index ["approval_project_rule_id", "group_id"], name: "index_approval_project_rules_groups_1", unique: true
    t.index ["group_id"], name: "index_approval_project_rules_groups_2"
  end

  create_table "approval_project_rules_protected_branches", primary_key: ["approval_project_rule_id", "protected_branch_id"], force: :cascade do |t|
    t.bigint "approval_project_rule_id", null: false
    t.bigint "protected_branch_id", null: false
    t.index ["protected_branch_id"], name: "index_approval_project_rules_protected_branches_pb_id"
  end

  create_table "approval_project_rules_users", force: :cascade do |t|
    t.bigint "approval_project_rule_id", null: false
    t.integer "user_id", null: false
    t.index ["approval_project_rule_id", "user_id"], name: "index_approval_project_rules_users_1", unique: true
    t.index ["approval_project_rule_id"], name: "index_approval_project_rules_users_on_approval_project_rule_id"
    t.index ["user_id"], name: "index_approval_project_rules_users_2"
  end

  create_table "approvals", id: :serial, force: :cascade do |t|
    t.integer "merge_request_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["merge_request_id", "created_at"], name: "index_approvals_on_merge_request_id_and_created_at"
    t.index ["merge_request_id"], name: "index_approvals_on_merge_request_id"
    t.index ["user_id", "merge_request_id"], name: "index_approvals_on_user_id_and_merge_request_id", unique: true
  end

  create_table "approver_groups", id: :serial, force: :cascade do |t|
    t.integer "target_id", null: false
    t.string "target_type", null: false
    t.integer "group_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "index_approver_groups_on_group_id"
    t.index ["target_id", "target_type"], name: "index_approver_groups_on_target_id_and_target_type"
  end

  create_table "approvers", id: :serial, force: :cascade do |t|
    t.integer "target_id", null: false
    t.string "target_type"
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["target_id", "target_type"], name: "index_approvers_on_target_id_and_target_type"
    t.index ["user_id"], name: "index_approvers_on_user_id"
  end

  create_table "atlassian_identities", primary_key: "user_id", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "expires_at"
    t.text "extern_uid", null: false
    t.binary "encrypted_token"
    t.binary "encrypted_token_iv"
    t.binary "encrypted_refresh_token"
    t.binary "encrypted_refresh_token_iv"
    t.index ["extern_uid"], name: "index_atlassian_identities_on_extern_uid", unique: true
    t.check_constraint "char_length(extern_uid) <= 255", name: "check_32f5779763"
    t.check_constraint "octet_length(encrypted_refresh_token) <= 512", name: "atlassian_identities_refresh_token_length_constraint"
    t.check_constraint "octet_length(encrypted_refresh_token_iv) <= 12", name: "atlassian_identities_refresh_token_iv_length_constraint"
    t.check_constraint "octet_length(encrypted_token) <= 2048", name: "atlassian_identities_token_length_constraint"
    t.check_constraint "octet_length(encrypted_token_iv) <= 12", name: "atlassian_identities_token_iv_length_constraint"
  end

  create_table "audit_events", primary_key: ["id", "created_at"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.integer "author_id", null: false
    t.integer "entity_id", null: false
    t.string "entity_type", null: false
    t.text "details"
    t.inet "ip_address"
    t.text "author_name"
    t.text "entity_path"
    t.text "target_details"
    t.datetime "created_at", null: false
    t.text "target_type"
    t.bigint "target_id"
    t.index ["created_at", "author_id"], name: "analytics_index_audit_events_part_on_created_at_and_author_id"
    t.index ["entity_id", "entity_type", "id", "author_id", "created_at"], name: "idx_audit_events_part_on_entity_id_desc_author_id_created_at", order: { id: :desc }
    t.check_constraint "char_length(author_name) <= 255", name: "check_83ff8406e2"
    t.check_constraint "char_length(entity_path) <= 5500", name: "check_492aaa021d"
    t.check_constraint "char_length(target_details) <= 5500", name: "check_d493ec90b5"
    t.check_constraint "char_length(target_type) <= 255", name: "check_97a8c868e7"
  end

  create_table "audit_events_external_audit_event_destinations", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.text "destination_url", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "verification_token"
    t.index ["namespace_id", "destination_url"], name: "index_external_audit_event_destinations_on_namespace_id", unique: true
    t.index ["verification_token"], name: "index_audit_events_external_audit_on_verification_token", unique: true
    t.check_constraint "char_length(destination_url) <= 255", name: "check_2feafb9daf"
    t.check_constraint "char_length(verification_token) <= 24", name: "check_8ec80a7d06"
  end

  create_table "audit_events_streaming_event_type_filters", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "external_audit_event_destination_id", null: false
    t.text "audit_event_type", null: false
    t.index ["external_audit_event_destination_id", "audit_event_type"], name: "unique_streaming_event_type_filters_destination_id", unique: true
    t.check_constraint "char_length(audit_event_type) <= 255", name: "check_d20c8e5a51"
  end

  create_table "audit_events_streaming_headers", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "external_audit_event_destination_id", null: false
    t.text "key", null: false
    t.text "value", null: false
    t.index ["external_audit_event_destination_id"], name: "idx_streaming_headers_on_external_audit_event_destination_id"
    t.index ["key", "external_audit_event_destination_id"], name: "idx_external_audit_event_destination_id_key_uniq", unique: true
    t.check_constraint "char_length(key) <= 255", name: "check_53c3152034"
    t.check_constraint "char_length(value) <= 255", name: "check_ac213cca22"
  end

  create_table "authentication_events", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.bigint "user_id"
    t.integer "result", limit: 2, null: false
    t.inet "ip_address"
    t.text "provider", null: false
    t.text "user_name", null: false
    t.index ["provider"], name: "index_authentication_events_on_provider"
    t.index ["user_id", "ip_address", "result"], name: "index_authentication_events_on_user_and_ip_address_and_result"
    t.index ["user_id", "provider", "created_at"], name: "index_successful_authentication_events_for_metrics", where: "(result = 1)"
    t.check_constraint "char_length(provider) <= 64", name: "check_c64f424630"
    t.check_constraint "char_length(user_name) <= 255", name: "check_45a6cc4e80"
  end

  create_table "award_emoji", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "awardable_id"
    t.string "awardable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["awardable_type", "awardable_id"], name: "index_award_emoji_on_awardable_type_and_awardable_id"
    t.index ["user_id", "name", "awardable_type", "awardable_id"], name: "idx_award_emoji_on_user_emoji_name_awardable_type_awardable_id"
  end

  create_table "aws_roles", primary_key: "user_id", id: :integer, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "role_arn", limit: 2048
    t.string "role_external_id", limit: 64, null: false
    t.text "region"
    t.index ["role_external_id"], name: "index_aws_roles_on_role_external_id", unique: true
    t.index ["user_id"], name: "index_aws_roles_on_user_id", unique: true
    t.check_constraint "char_length(region) <= 255", name: "check_57adedab55"
  end

  create_table "background_migration_jobs", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.text "class_name", null: false
    t.jsonb "arguments", null: false
    t.index "((arguments ->> 2))", name: "index_background_migration_jobs_for_partitioning_migrations", where: "(class_name = 'Gitlab::Database::PartitioningMigrationHelpers::BackfillPartitionedTable'::text)"
    t.index ["class_name", "arguments"], name: "index_background_migration_jobs_on_class_name_and_arguments"
    t.index ["class_name", "status", "id"], name: "index_background_migration_jobs_on_class_name_and_status_and_id"
    t.check_constraint "char_length(class_name) <= 200", name: "check_b0de0a5852"
  end

  create_table "badges", id: :serial, force: :cascade do |t|
    t.string "link_url", null: false
    t.string "image_url", null: false
    t.integer "project_id"
    t.integer "group_id"
    t.string "type", null: false
    t.string "name", limit: 255
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["group_id"], name: "index_badges_on_group_id"
    t.index ["project_id"], name: "index_badges_on_project_id"
  end

  create_table "banned_users", primary_key: "user_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
  end

  create_table "batched_background_migration_job_transition_logs", primary_key: ["id", "created_at"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "batched_background_migration_job_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "previous_status", limit: 2, null: false
    t.integer "next_status", limit: 2, null: false
    t.text "exception_class"
    t.text "exception_message"
    t.index ["batched_background_migration_job_id"], name: "i_batched_background_migration_job_transition_logs_on_job_id"
    t.check_constraint "char_length(exception_class) <= 100", name: "check_76e202c37a"
    t.check_constraint "char_length(exception_message) <= 1000", name: "check_50e580811a"
  end

  create_table "batched_background_migration_jobs", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "started_at"
    t.datetime_with_timezone "finished_at"
    t.bigint "batched_background_migration_id", null: false
    t.bigint "min_value", null: false
    t.bigint "max_value", null: false
    t.integer "batch_size", null: false
    t.integer "sub_batch_size", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.integer "attempts", limit: 2, default: 0, null: false
    t.jsonb "metrics", default: {}, null: false
    t.integer "pause_ms", default: 100, null: false
    t.index ["batched_background_migration_id", "finished_at"], name: "index_migration_jobs_on_migration_id_and_finished_at"
    t.index ["batched_background_migration_id", "id"], name: "index_batched_jobs_by_batched_migration_id_and_id"
    t.index ["batched_background_migration_id", "max_value"], name: "index_migration_jobs_on_migration_id_and_max_value"
    t.index ["batched_background_migration_id", "status"], name: "index_batched_jobs_on_batched_migration_id_and_status"
  end

  create_table "batched_background_migrations", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "min_value", default: 1, null: false
    t.bigint "max_value", null: false
    t.integer "batch_size", null: false
    t.integer "sub_batch_size", null: false
    t.integer "interval", limit: 2, null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.text "job_class_name", null: false
    t.text "batch_class_name", default: "PrimaryKeyBatchingStrategy", null: false
    t.text "table_name", null: false
    t.text "column_name", null: false
    t.jsonb "job_arguments", default: [], null: false
    t.bigint "total_tuple_count"
    t.integer "pause_ms", default: 100, null: false
    t.integer "max_batch_size"
    t.datetime_with_timezone "started_at"
    t.datetime_with_timezone "on_hold_until", comment: "execution of this migration is on hold until this time"
    t.text "gitlab_schema", null: false
    t.index ["gitlab_schema", "job_class_name", "table_name", "column_name", "job_arguments"], name: "index_batched_migrations_on_gl_schema_and_unique_configuration", unique: true
    t.index ["job_class_name", "table_name", "column_name", "job_arguments"], name: "index_batched_background_migrations_on_unique_configuration", unique: true
    t.index ["status"], name: "index_batched_background_migrations_on_status"
    t.check_constraint "batch_size >= sub_batch_size", name: "check_batch_size_in_range"
    t.check_constraint "char_length(batch_class_name) <= 100", name: "check_fe10674721"
    t.check_constraint "char_length(column_name) <= 63", name: "check_5bb0382d6f"
    t.check_constraint "char_length(gitlab_schema) <= 255", name: "check_0406d9776f"
    t.check_constraint "char_length(job_class_name) <= 100", name: "check_e6c75b1e29"
    t.check_constraint "char_length(table_name) <= 63", name: "check_6b6a06254a"
    t.check_constraint "max_value >= min_value", name: "check_max_value_in_range"
    t.check_constraint "min_value > 0", name: "check_positive_min_value"
    t.check_constraint "sub_batch_size > 0", name: "check_positive_sub_batch_size"
  end

  create_table "board_assignees", id: :serial, force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "assignee_id", null: false
    t.index ["assignee_id"], name: "index_board_assignees_on_assignee_id"
    t.index ["board_id", "assignee_id"], name: "index_board_assignees_on_board_id_and_assignee_id", unique: true
  end

  create_table "board_group_recent_visits", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "user_id"
    t.integer "board_id"
    t.integer "group_id"
    t.index ["board_id"], name: "index_board_group_recent_visits_on_board_id"
    t.index ["group_id"], name: "index_board_group_recent_visits_on_group_id"
    t.index ["user_id", "group_id", "board_id"], name: "index_board_group_recent_visits_on_user_group_and_board", unique: true
    t.index ["user_id"], name: "index_board_group_recent_visits_on_user_id"
    t.check_constraint "board_id IS NOT NULL", name: "check_fa7711a898"
    t.check_constraint "group_id IS NOT NULL", name: "check_ddc74243ef"
    t.check_constraint "user_id IS NOT NULL", name: "check_409f6caea4"
  end

  create_table "board_labels", id: :serial, force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "label_id", null: false
    t.index ["board_id", "label_id"], name: "index_board_labels_on_board_id_and_label_id", unique: true
    t.index ["label_id"], name: "index_board_labels_on_label_id"
  end

  create_table "board_project_recent_visits", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "user_id"
    t.integer "project_id"
    t.integer "board_id"
    t.index ["board_id"], name: "index_board_project_recent_visits_on_board_id"
    t.index ["project_id"], name: "index_board_project_recent_visits_on_project_id"
    t.index ["user_id", "project_id", "board_id"], name: "index_board_project_recent_visits_on_user_project_and_board", unique: true
    t.index ["user_id"], name: "index_board_project_recent_visits_on_user_id"
    t.check_constraint "board_id IS NOT NULL", name: "check_0386e26981"
    t.check_constraint "project_id IS NOT NULL", name: "check_d9cc9b79da"
    t.check_constraint "user_id IS NOT NULL", name: "check_df7762a99a"
  end

  create_table "board_user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "board_id", null: false
    t.boolean "hide_labels"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["board_id"], name: "index_board_user_preferences_on_board_id"
    t.index ["user_id", "board_id"], name: "index_board_user_preferences_on_user_id_and_board_id", unique: true
    t.index ["user_id"], name: "index_board_user_preferences_on_user_id"
  end

  create_table "boards", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "Development", null: false
    t.integer "milestone_id"
    t.integer "group_id"
    t.integer "weight"
    t.boolean "hide_backlog_list", default: false, null: false
    t.boolean "hide_closed_list", default: false, null: false
    t.bigint "iteration_id"
    t.bigint "iteration_cadence_id"
    t.index ["group_id"], name: "index_boards_on_group_id"
    t.index ["iteration_cadence_id"], name: "index_boards_on_iteration_cadence_id"
    t.index ["iteration_id"], name: "index_boards_on_iteration_id"
    t.index ["milestone_id"], name: "index_boards_on_milestone_id"
    t.index ["project_id"], name: "index_boards_on_project_id"
  end

  create_table "boards_epic_board_labels", force: :cascade do |t|
    t.bigint "epic_board_id", null: false
    t.bigint "label_id", null: false
    t.index ["epic_board_id"], name: "index_boards_epic_board_labels_on_epic_board_id"
    t.index ["label_id"], name: "index_boards_epic_board_labels_on_label_id"
  end

  create_table "boards_epic_board_positions", force: :cascade do |t|
    t.bigint "epic_board_id", null: false
    t.bigint "epic_id", null: false
    t.integer "relative_position"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["epic_board_id", "epic_id", "relative_position"], name: "index_boards_epic_board_positions_on_scoped_relative_position"
    t.index ["epic_board_id", "epic_id"], name: "index_boards_epic_board_positions_on_epic_board_id_and_epic_id", unique: true
    t.index ["epic_id"], name: "index_boards_epic_board_positions_on_epic_id"
  end

  create_table "boards_epic_board_recent_visits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "epic_board_id", null: false
    t.bigint "group_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["epic_board_id"], name: "index_boards_epic_board_recent_visits_on_epic_board_id"
    t.index ["group_id"], name: "index_boards_epic_board_recent_visits_on_group_id"
    t.index ["user_id", "group_id", "epic_board_id"], name: "index_epic_board_recent_visits_on_user_group_and_board", unique: true
    t.index ["user_id"], name: "index_boards_epic_board_recent_visits_on_user_id"
  end

  create_table "boards_epic_boards", force: :cascade do |t|
    t.boolean "hide_backlog_list", default: false, null: false
    t.boolean "hide_closed_list", default: false, null: false
    t.bigint "group_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "name", default: "Development", null: false
    t.index ["group_id"], name: "index_boards_epic_boards_on_group_id"
    t.check_constraint "char_length(name) <= 255", name: "check_bcbbffe601"
  end

  create_table "boards_epic_list_user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "epic_list_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "collapsed", default: false, null: false
    t.index ["epic_list_id"], name: "index_boards_epic_list_user_preferences_on_epic_list_id"
    t.index ["user_id", "epic_list_id"], name: "index_epic_board_list_preferences_on_user_and_list", unique: true
  end

  create_table "boards_epic_lists", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "epic_board_id", null: false
    t.bigint "label_id"
    t.integer "position"
    t.integer "list_type", limit: 2, default: 1, null: false
    t.index ["epic_board_id", "label_id"], name: "index_boards_epic_lists_on_epic_board_id_and_label_id", unique: true, where: "(list_type = 1)"
    t.index ["epic_board_id"], name: "index_boards_epic_lists_on_epic_board_id"
    t.index ["label_id"], name: "index_boards_epic_lists_on_label_id"
    t.check_constraint "(list_type <> 1) OR ((\"position\" IS NOT NULL) AND (\"position\" >= 0))", name: "boards_epic_lists_position_constraint"
  end

  create_table "boards_epic_user_preferences", force: :cascade do |t|
    t.bigint "board_id", null: false
    t.bigint "user_id", null: false
    t.bigint "epic_id", null: false
    t.boolean "collapsed", default: false, null: false
    t.index ["board_id", "user_id", "epic_id"], name: "index_boards_epic_user_preferences_on_board_user_epic_unique", unique: true
    t.index ["board_id"], name: "index_boards_epic_user_preferences_on_board_id"
    t.index ["epic_id"], name: "index_boards_epic_user_preferences_on_epic_id"
    t.index ["user_id"], name: "index_boards_epic_user_preferences_on_user_id"
  end

  create_table "broadcast_messages", id: :serial, force: :cascade do |t|
    t.text "message", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
    t.string "font"
    t.text "message_html", null: false
    t.integer "cached_markdown_version"
    t.string "target_path", limit: 255
    t.integer "broadcast_type", limit: 2, default: 1, null: false
    t.boolean "dismissable"
    t.integer "target_access_levels", default: [], null: false, array: true
    t.integer "theme", limit: 2, default: 0, null: false
    t.bigint "namespace_id"
    t.index ["ends_at", "broadcast_type", "id"], name: "index_broadcast_message_on_ends_at_and_broadcast_type_and_id"
    t.index ["namespace_id"], name: "index_broadcast_messages_on_namespace_id"
  end

  create_table "bulk_import_configurations", force: :cascade do |t|
    t.integer "bulk_import_id", null: false
    t.text "encrypted_url"
    t.text "encrypted_url_iv"
    t.text "encrypted_access_token"
    t.text "encrypted_access_token_iv"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["bulk_import_id"], name: "index_bulk_import_configurations_on_bulk_import_id"
  end

  create_table "bulk_import_entities", force: :cascade do |t|
    t.bigint "bulk_import_id", null: false
    t.bigint "parent_id"
    t.bigint "namespace_id"
    t.bigint "project_id"
    t.integer "source_type", limit: 2, null: false
    t.text "source_full_path", null: false
    t.text "destination_name", null: false
    t.text "destination_namespace", null: false
    t.integer "status", limit: 2, null: false
    t.text "jid"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "source_xid"
    t.index ["bulk_import_id", "status"], name: "index_bulk_import_entities_on_bulk_import_id_and_status"
    t.index ["namespace_id"], name: "index_bulk_import_entities_on_namespace_id"
    t.index ["parent_id"], name: "index_bulk_import_entities_on_parent_id"
    t.index ["project_id"], name: "index_bulk_import_entities_on_project_id"
    t.check_constraint "char_length(destination_name) <= 255", name: "check_715d725ea2"
    t.check_constraint "char_length(destination_namespace) <= 255", name: "check_b834fff4d9"
    t.check_constraint "char_length(jid) <= 255", name: "check_796a4d9cc6"
    t.check_constraint "char_length(source_full_path) <= 255", name: "check_13f279f7da"
  end

  create_table "bulk_import_export_uploads", force: :cascade do |t|
    t.bigint "export_id", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "export_file"
    t.index ["export_id"], name: "index_bulk_import_export_uploads_on_export_id"
    t.check_constraint "char_length(export_file) <= 255", name: "check_5add76239d"
  end

  create_table "bulk_import_exports", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "project_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.text "relation", null: false
    t.text "jid"
    t.text "error"
    t.index ["group_id", "relation"], name: "partial_index_bulk_import_exports_on_group_id_and_relation", unique: true, where: "(group_id IS NOT NULL)"
    t.index ["project_id", "relation"], name: "partial_index_bulk_import_exports_on_project_id_and_relation", unique: true, where: "(project_id IS NOT NULL)"
    t.check_constraint "char_length(error) <= 255", name: "check_8f0f357334"
    t.check_constraint "char_length(jid) <= 255", name: "check_9ee6d14d33"
    t.check_constraint "char_length(relation) <= 255", name: "check_24cb010672"
  end

  create_table "bulk_import_failures", force: :cascade do |t|
    t.bigint "bulk_import_entity_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.text "pipeline_class", null: false
    t.text "exception_class", null: false
    t.text "exception_message", null: false
    t.text "correlation_id_value"
    t.text "pipeline_step"
    t.index ["bulk_import_entity_id"], name: "index_bulk_import_failures_on_bulk_import_entity_id"
    t.index ["correlation_id_value"], name: "index_bulk_import_failures_on_correlation_id_value"
    t.check_constraint "char_length(correlation_id_value) <= 255", name: "check_e787285882"
    t.check_constraint "char_length(exception_class) <= 255", name: "check_c7dba8398e"
    t.check_constraint "char_length(exception_message) <= 255", name: "check_6eca8f972e"
    t.check_constraint "char_length(pipeline_class) <= 255", name: "check_053d65c7a4"
    t.check_constraint "char_length(pipeline_step) <= 255", name: "check_721a422375"
  end

  create_table "bulk_import_trackers", force: :cascade do |t|
    t.bigint "bulk_import_entity_id", null: false
    t.text "relation", null: false
    t.text "next_page"
    t.boolean "has_next_page", default: false, null: false
    t.text "jid"
    t.integer "stage", limit: 2, default: 0, null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["bulk_import_entity_id", "relation"], name: "bulk_import_trackers_uniq_relation_by_entity", unique: true
    t.check_constraint "(has_next_page IS FALSE) OR (next_page IS NOT NULL)", name: "check_next_page_requirement"
    t.check_constraint "char_length(jid) <= 255", name: "check_603f91cb06"
    t.check_constraint "char_length(next_page) <= 255", name: "check_40aeaa600b"
    t.check_constraint "char_length(relation) <= 255", name: "check_2d45cae629"
  end

  create_table "bulk_imports", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "source_type", limit: 2, null: false
    t.integer "status", limit: 2, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "source_version"
    t.boolean "source_enterprise", default: true, null: false
    t.index ["user_id"], name: "index_bulk_imports_on_user_id"
    t.check_constraint "char_length(source_version) <= 63", name: "check_ea4e58775a"
  end

  create_table "chat_names", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "team_id", null: false
    t.string "team_domain"
    t.string "chat_id", null: false
    t.string "chat_name"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "integration_id"
    t.index ["integration_id", "team_id", "chat_id"], name: "index_chat_names_on_integration_id_and_team_id_and_chat_id", unique: true
    t.index ["team_id", "chat_id"], name: "index_chat_names_on_team_id_and_chat_id"
    t.index ["user_id", "integration_id"], name: "index_chat_names_on_user_id_and_integration_id", unique: true
    t.check_constraint "integration_id IS NOT NULL", name: "check_2b0a0d0f0f"
  end

  create_table "chat_teams", id: :serial, force: :cascade do |t|
    t.integer "namespace_id", null: false
    t.string "team_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["namespace_id"], name: "index_chat_teams_on_namespace_id", unique: true
  end

  create_table "ci_build_needs", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.boolean "artifacts", default: true, null: false
    t.boolean "optional", default: false, null: false
    t.bigint "build_id", null: false
    t.bigint "partition_id", default: 100, null: false
    t.index ["build_id", "name"], name: "index_ci_build_needs_on_build_id_and_name", unique: true
  end

  create_table "ci_build_pending_states", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "build_id", null: false
    t.integer "state", limit: 2
    t.integer "failure_reason", limit: 2
    t.binary "trace_checksum"
    t.bigint "trace_bytesize"
    t.bigint "partition_id", default: 100, null: false
    t.index ["build_id"], name: "index_ci_build_pending_states_on_build_id", unique: true
  end

  create_table "ci_build_report_results", primary_key: "build_id", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "partition_id", default: 100, null: false
    t.index ["project_id"], name: "index_ci_build_report_results_on_project_id"
  end

  create_table "ci_build_trace_chunks", force: :cascade do |t|
    t.integer "chunk_index", null: false
    t.integer "data_store", null: false
    t.binary "raw_data"
    t.binary "checksum"
    t.integer "lock_version", default: 0, null: false
    t.bigint "build_id", null: false
    t.bigint "partition_id", default: 100, null: false
    t.index ["build_id", "chunk_index"], name: "index_ci_build_trace_chunks_on_build_id_and_chunk_index", unique: true
  end

  create_table "ci_build_trace_metadata", primary_key: "build_id", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "trace_artifact_id"
    t.integer "archival_attempts", limit: 2, default: 0, null: false
    t.binary "checksum"
    t.binary "remote_checksum"
    t.datetime_with_timezone "last_archival_attempt_at"
    t.datetime_with_timezone "archived_at"
    t.bigint "partition_id", default: 100, null: false
    t.index ["trace_artifact_id"], name: "index_ci_build_trace_metadata_on_trace_artifact_id"
  end

  create_table "ci_builds", force: :cascade do |t|
    t.string "status"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.integer "runner_id"
    t.float "coverage"
    t.integer "commit_id"
    t.string "name"
    t.text "options"
    t.boolean "allow_failure", default: false, null: false
    t.string "stage"
    t.integer "trigger_request_id"
    t.integer "stage_idx"
    t.boolean "tag"
    t.string "ref"
    t.integer "user_id"
    t.string "type"
    t.string "target_url"
    t.string "description"
    t.integer "project_id"
    t.integer "erased_by_id"
    t.datetime "erased_at"
    t.datetime "artifacts_expire_at"
    t.string "environment"
    t.string "when"
    t.text "yaml_variables"
    t.datetime "queued_at"
    t.integer "lock_version", default: 0
    t.string "coverage_regex"
    t.integer "auto_canceled_by_id"
    t.boolean "retried"
    t.boolean "protected"
    t.integer "failure_reason"
    t.datetime_with_timezone "scheduled_at"
    t.string "token_encrypted"
    t.integer "upstream_pipeline_id"
    t.bigint "resource_group_id"
    t.datetime_with_timezone "waiting_for_resource_at"
    t.boolean "processed"
    t.integer "scheduling_type", limit: 2
    t.bigint "stage_id"
    t.bigint "partition_id", default: 100, null: false
    t.index ["auto_canceled_by_id"], name: "index_ci_builds_on_auto_canceled_by_id"
    t.index ["commit_id", "artifacts_expire_at", "id"], name: "index_ci_builds_on_commit_id_artifacts_expired_at_and_id", where: "(((type)::text = 'Ci::Build'::text) AND ((retried = false) OR (retried IS NULL)) AND ((name)::text = ANY (ARRAY[('sast'::character varying)::text, ('secret_detection'::character varying)::text, ('dependency_scanning'::character varying)::text, ('container_scanning'::character varying)::text, ('dast'::character varying)::text])))"
    t.index ["commit_id", "stage_idx", "created_at"], name: "index_ci_builds_on_commit_id_and_stage_idx_and_created_at"
    t.index ["commit_id", "status", "type"], name: "index_ci_builds_on_commit_id_and_status_and_type"
    t.index ["commit_id", "type", "name", "ref"], name: "index_ci_builds_on_commit_id_and_type_and_name_and_ref"
    t.index ["commit_id", "type", "ref"], name: "index_ci_builds_on_commit_id_and_type_and_ref"
    t.index ["name", "id"], name: "index_security_ci_builds_on_name_and_id_parser_features", where: "(((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('sast'::character varying)::text, ('secret_detection'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('license_scanning'::character varying)::text, ('apifuzzer_fuzz'::character varying)::text, ('apifuzzer_fuzz_dnd'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text))"
    t.index ["project_id", "id"], name: "index_ci_builds_on_project_id_and_id"
    t.index ["project_id", "name", "ref"], name: "index_ci_builds_on_project_id_and_name_and_ref", where: "(((type)::text = 'Ci::Build'::text) AND ((status)::text = 'success'::text) AND ((retried = false) OR (retried IS NULL)))"
    t.index ["project_id", "status"], name: "index_ci_builds_project_id_and_status_for_live_jobs_partial2", where: "(((type)::text = 'Ci::Build'::text) AND ((status)::text = ANY (ARRAY[('running'::character varying)::text, ('pending'::character varying)::text, ('created'::character varying)::text])))"
    t.index ["resource_group_id", "status", "commit_id"], name: "index_ci_builds_on_resource_group_and_status_and_commit_id", where: "(resource_group_id IS NOT NULL)"
    t.index ["runner_id", "id"], name: "index_ci_builds_on_runner_id_and_id_desc", order: { id: :desc }
    t.index ["runner_id"], name: "index_ci_builds_runner_id_running", where: "(((status)::text = 'running'::text) AND ((type)::text = 'Ci::Build'::text))"
    t.index ["scheduled_at"], name: "partial_index_ci_builds_on_scheduled_at_with_scheduled_jobs", where: "((scheduled_at IS NOT NULL) AND ((type)::text = 'Ci::Build'::text) AND ((status)::text = 'scheduled'::text))"
    t.index ["stage_id"], name: "index_ci_builds_on_stage_id"
    t.index ["status", "created_at", "project_id"], name: "ci_builds_gitlab_monitor_metrics", where: "((type)::text = 'Ci::Build'::text)"
    t.index ["status", "type", "runner_id"], name: "index_ci_builds_on_status_and_type_and_runner_id"
    t.index ["token_encrypted"], name: "index_ci_builds_on_token_encrypted", unique: true, where: "(token_encrypted IS NOT NULL)"
    t.index ["updated_at"], name: "index_ci_builds_on_updated_at"
    t.index ["upstream_pipeline_id"], name: "index_ci_builds_on_upstream_pipeline_id", where: "(upstream_pipeline_id IS NOT NULL)"
    t.index ["user_id", "created_at"], name: "index_ci_builds_on_user_id_and_created_at_and_type_eq_ci_build", where: "((type)::text = 'Ci::Build'::text)"
    t.index ["user_id", "name", "created_at"], name: "index_secure_ci_builds_on_user_id_name_created_at", where: "(((type)::text = 'Ci::Build'::text) AND ((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('license_scanning'::character varying)::text, ('sast'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('apifuzzer_fuzz'::character varying)::text, ('apifuzzer_fuzz_dnd'::character varying)::text, ('secret_detection'::character varying)::text])))"
    t.index ["user_id", "name"], name: "index_partial_ci_builds_on_user_id_name_parser_features", where: "(((type)::text = 'Ci::Build'::text) AND ((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('license_scanning'::character varying)::text, ('sast'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('secret_detection'::character varying)::text])))"
    t.index ["user_id"], name: "index_ci_builds_on_user_id"
    t.check_constraint "lock_version IS NOT NULL", name: "check_1e2fbd1b39"
  end

  create_table "ci_builds_metadata", primary_key: ["id", "partition_id"], force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "timeout"
    t.integer "timeout_source", default: 1, null: false
    t.boolean "interruptible"
    t.jsonb "config_options"
    t.jsonb "config_variables"
    t.boolean "has_exposed_artifacts"
    t.string "environment_auto_stop_in", limit: 255
    t.string "expanded_environment_name", limit: 255
    t.jsonb "secrets", default: {}, null: false
    t.bigint "build_id", null: false
    t.bigserial "id", null: false
    t.jsonb "runtime_runner_features", default: {}, null: false
    t.jsonb "id_tokens", default: {}, null: false
    t.bigint "partition_id", default: 100, null: false
    t.boolean "debug_trace_enabled", default: false, null: false
    t.index ["build_id", "id"], name: "index_ci_builds_metadata_on_build_id_and_id_and_interruptible", where: "(interruptible = true)"
    t.index ["build_id", "partition_id"], name: "index_ci_builds_metadata_on_build_id_partition_id_unique", unique: true
    t.index ["build_id"], name: "index_ci_builds_metadata_on_build_id_and_has_exposed_artifacts", where: "(has_exposed_artifacts IS TRUE)"
    t.index ["id", "partition_id"], name: "index_ci_builds_metadata_on_id_partition_id_unique", unique: true
    t.index ["project_id"], name: "index_ci_builds_metadata_on_project_id"
  end

  create_table "ci_builds_runner_session", force: :cascade do |t|
    t.string "url", null: false
    t.string "certificate"
    t.string "authorization"
    t.bigint "build_id", null: false
    t.bigint "partition_id", default: 100, null: false
    t.index ["build_id"], name: "index_ci_builds_runner_session_on_build_id", unique: true
  end

  create_table "ci_daily_build_group_report_results", force: :cascade do |t|
    t.date "date", null: false
    t.bigint "project_id", null: false
    t.bigint "last_pipeline_id", null: false
    t.text "ref_path", null: false
    t.text "group_name", null: false
    t.jsonb "data", null: false
    t.boolean "default_branch", default: false, null: false
    t.bigint "group_id"
    t.index ["group_id"], name: "index_ci_daily_build_group_report_results_on_group_id"
    t.index ["last_pipeline_id"], name: "index_ci_daily_build_group_report_results_on_last_pipeline_id"
    t.index ["project_id", "date"], name: "index_ci_daily_build_group_report_results_on_project_and_date", order: { date: :desc }, where: "((default_branch = true) AND ((data -> 'coverage'::text) IS NOT NULL))"
    t.index ["project_id", "ref_path", "date", "group_name"], name: "index_daily_build_group_report_results_unique_columns", unique: true
  end

  create_table "ci_deleted_objects", force: :cascade do |t|
    t.integer "file_store", limit: 2, default: 1, null: false
    t.datetime_with_timezone "pick_up_at", default: -> { "now()" }, null: false
    t.text "store_dir", null: false
    t.text "file", null: false
    t.index ["pick_up_at"], name: "index_ci_deleted_objects_on_pick_up_at"
    t.check_constraint "char_length(store_dir) <= 1024", name: "check_5e151d6912"
  end

  create_table "ci_freeze_periods", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "freeze_start", limit: 998, null: false
    t.string "freeze_end", limit: 998, null: false
    t.string "cron_timezone", limit: 255, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["project_id"], name: "index_ci_freeze_periods_on_project_id"
  end

  create_table "ci_group_variables", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.text "encrypted_value"
    t.string "encrypted_value_salt"
    t.string "encrypted_value_iv"
    t.integer "group_id", null: false
    t.boolean "protected", default: false, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "masked", default: false, null: false
    t.integer "variable_type", limit: 2, default: 1, null: false
    t.text "environment_scope", default: "*", null: false
    t.boolean "raw", default: false, null: false
    t.index ["group_id", "key", "environment_scope"], name: "index_ci_group_variables_on_group_id_and_key_and_environment", unique: true
    t.check_constraint "char_length(environment_scope) <= 255", name: "check_dfe009485a"
  end

  create_table "ci_instance_variables", force: :cascade do |t|
    t.integer "variable_type", limit: 2, default: 1, null: false
    t.boolean "masked", default: false
    t.boolean "protected", default: false
    t.text "key", null: false
    t.text "encrypted_value"
    t.text "encrypted_value_iv"
    t.boolean "raw", default: false, null: false
    t.index ["key"], name: "index_ci_instance_variables_on_key", unique: true
    t.check_constraint "char_length(encrypted_value) <= 13579", name: "check_956afd70f1"
    t.check_constraint "char_length(encrypted_value_iv) <= 255", name: "check_07a45a5bcb"
    t.check_constraint "char_length(key) <= 255", name: "check_5aede12208"
  end

  create_table "ci_job_artifact_states", primary_key: "job_artifact_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.integer "verification_retry_count", limit: 2
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.index ["job_artifact_id"], name: "index_ci_job_artifact_states_on_job_artifact_id"
    t.index ["verification_retry_at"], name: "index_job_artifact_states_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_job_artifact_states_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_job_artifact_states_on_verification_state"
    t.index ["verified_at"], name: "index_job_artifact_states_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_df832b66ea"
  end

  create_table "ci_job_artifacts", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "file_type", null: false
    t.bigint "size"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "expire_at"
    t.string "file"
    t.integer "file_store", default: 1
    t.binary "file_sha256"
    t.integer "file_format", limit: 2
    t.integer "file_location", limit: 2
    t.bigint "job_id", null: false
    t.integer "locked", limit: 2, default: 2
    t.text "original_filename"
    t.bigint "partition_id", default: 100, null: false
    t.index ["expire_at", "job_id"], name: "index_ci_job_artifacts_on_expire_at_and_job_id"
    t.index ["expire_at", "job_id"], name: "tmp_index_ci_job_artifacts_on_expire_at_where_locked_unknown", where: "((locked = 2) AND (expire_at IS NOT NULL))"
    t.index ["expire_at"], name: "index_ci_job_artifacts_on_expire_at_for_removal", where: "((locked = 0) AND (expire_at IS NOT NULL))"
    t.index ["file_store"], name: "index_ci_job_artifacts_on_file_store"
    t.index ["file_type", "project_id", "created_at"], name: "index_ci_job_artifacts_on_file_type_for_devops_adoption", where: "(file_type = ANY (ARRAY[5, 6, 8, 23]))"
    t.index ["id"], name: "index_ci_job_artifacts_id_for_terraform_reports", where: "(file_type = 18)"
    t.index ["id"], name: "tmp_index_ci_job_artifacts_on_id_expire_at_file_type_trace", where: "(((date_part('day'::text, timezone('UTC'::text, expire_at)) = ANY (ARRAY[(21)::double precision, (22)::double precision, (23)::double precision])) AND (date_part('minute'::text, timezone('UTC'::text, expire_at)) = ANY (ARRAY[(0)::double precision, (30)::double precision, (45)::double precision])) AND (date_part('second'::text, timezone('UTC'::text, expire_at)) = (0)::double precision)) OR (file_type = 3))"
    t.index ["job_id", "file_type"], name: "index_ci_job_artifacts_on_job_id_and_file_type", unique: true
    t.index ["project_id", "created_at", "id"], name: "index_ci_job_artifacts_on_id_project_id_and_created_at"
    t.index ["project_id", "file_type", "id"], name: "index_ci_job_artifacts_on_id_project_id_and_file_type"
    t.index ["project_id", "id"], name: "index_ci_job_artifacts_for_terraform_reports", where: "(file_type = 18)"
    t.index ["project_id", "id"], name: "index_ci_job_artifacts_on_project_id_and_id"
    t.index ["project_id"], name: "index_ci_job_artifacts_on_project_id"
    t.index ["project_id"], name: "index_ci_job_artifacts_on_project_id_for_security_reports", where: "(file_type = ANY (ARRAY[5, 6, 7, 8]))"
    t.check_constraint "char_length(original_filename) <= 512", name: "check_85573000db"
    t.check_constraint "file_store IS NOT NULL", name: "check_27f0f6dbab"
  end

  create_table "ci_job_token_project_scope_links", force: :cascade do |t|
    t.bigint "source_project_id", null: false
    t.bigint "target_project_id", null: false
    t.bigint "added_by_id"
    t.datetime_with_timezone "created_at", null: false
    t.integer "direction", limit: 2, default: 0, null: false
    t.index ["added_by_id"], name: "index_ci_job_token_project_scope_links_on_added_by_id"
    t.index ["source_project_id", "target_project_id"], name: "i_ci_job_token_project_scope_links_on_source_and_target_project", unique: true
    t.index ["target_project_id"], name: "index_ci_job_token_project_scope_links_on_target_project_id"
  end

  create_table "ci_job_variables", force: :cascade do |t|
    t.string "key", null: false
    t.text "encrypted_value"
    t.string "encrypted_value_iv"
    t.bigint "job_id", null: false
    t.integer "variable_type", limit: 2, default: 1, null: false
    t.integer "source", limit: 2, default: 0, null: false
    t.boolean "raw", default: false, null: false
    t.bigint "partition_id", default: 100, null: false
    t.index ["job_id"], name: "index_ci_job_variables_on_job_id"
    t.index ["key", "job_id"], name: "index_ci_job_variables_on_key_and_job_id", unique: true
  end

  create_table "ci_minutes_additional_packs", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "namespace_id", null: false
    t.date "expires_at"
    t.integer "number_of_minutes", null: false
    t.text "purchase_xid"
    t.index ["namespace_id", "purchase_xid"], name: "index_ci_minutes_additional_packs_on_namespace_id_purchase_xid"
    t.check_constraint "char_length(purchase_xid) <= 50", name: "check_d7ef254af0"
  end

  create_table "ci_namespace_mirrors", force: :cascade do |t|
    t.integer "namespace_id", null: false
    t.integer "traversal_ids", default: [], null: false, array: true
    t.index "(traversal_ids[1]), (traversal_ids[2]), (traversal_ids[3]), (traversal_ids[4])) INCLUDE (traversal_ids, namespace_id", name: "index_ci_namespace_mirrors_on_traversal_ids_unnest"
    t.index ["namespace_id"], name: "index_ci_namespace_mirrors_on_namespace_id", unique: true
    t.index ["traversal_ids"], name: "index_gin_ci_namespace_mirrors_on_traversal_ids", using: :gin
  end

  create_table "ci_namespace_monthly_usages", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.date "date", null: false
    t.decimal "amount_used", precision: 18, scale: 2, default: "0.0", null: false
    t.integer "notification_level", limit: 2, default: 100, null: false
    t.integer "shared_runners_duration", default: 0, null: false
    t.datetime_with_timezone "created_at"
    t.decimal "new_amount_used", precision: 18, scale: 4, default: "0.0", null: false
    t.index ["namespace_id", "date"], name: "index_ci_namespace_monthly_usages_on_namespace_id_and_date", unique: true
    t.check_constraint "date = date_trunc('month'::text, (date)::timestamp with time zone)", name: "ci_namespace_monthly_usages_year_month_constraint"
  end

  create_table "ci_partitions", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
  end

  create_table "ci_pending_builds", force: :cascade do |t|
    t.bigint "build_id", null: false
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", default: -> { "now()" }, null: false
    t.boolean "protected", default: false, null: false
    t.boolean "instance_runners_enabled", default: false, null: false
    t.bigint "namespace_id"
    t.boolean "minutes_exceeded", default: false, null: false
    t.integer "tag_ids", default: [], array: true
    t.integer "namespace_traversal_ids", default: [], array: true
    t.bigint "partition_id", default: 100, null: false
    t.index ["build_id"], name: "index_ci_pending_builds_on_build_id", unique: true
    t.index ["id"], name: "index_ci_pending_builds_id_on_protected_partial", where: "(protected = true)"
    t.index ["namespace_id"], name: "index_ci_pending_builds_on_namespace_id"
    t.index ["namespace_traversal_ids"], name: "index_gin_ci_pending_builds_on_namespace_traversal_ids", using: :gin
    t.index ["project_id"], name: "index_ci_pending_builds_on_project_id"
    t.index ["tag_ids"], name: "index_ci_pending_builds_on_tag_ids", where: "(cardinality(tag_ids) > 0)"
  end

  create_table "ci_pipeline_artifacts", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "pipeline_id", null: false
    t.bigint "project_id", null: false
    t.integer "size", null: false
    t.integer "file_store", limit: 2, default: 1, null: false
    t.integer "file_type", limit: 2, null: false
    t.integer "file_format", limit: 2, null: false
    t.text "file"
    t.datetime_with_timezone "expire_at"
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.integer "verification_retry_count", limit: 2
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.integer "locked", limit: 2, default: 2
    t.index ["expire_at"], name: "ci_pipeline_artifacts_on_expire_at_for_removal", where: "((locked = 0) AND (expire_at IS NOT NULL))"
    t.index ["expire_at"], name: "index_ci_pipeline_artifacts_on_expire_at"
    t.index ["pipeline_id", "file_type"], name: "index_ci_pipeline_artifacts_on_pipeline_id_and_file_type", unique: true
    t.index ["pipeline_id"], name: "index_ci_pipeline_artifacts_on_pipeline_id"
    t.index ["project_id"], name: "index_ci_pipeline_artifacts_on_project_id"
    t.index ["verification_retry_at"], name: "index_ci_pipeline_artifacts_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_ci_pipeline_artifacts_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_ci_pipeline_artifacts_verification_state"
    t.index ["verified_at"], name: "index_ci_pipeline_artifacts_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(file) <= 255", name: "check_191b5850ec"
    t.check_constraint "char_length(verification_failure) <= 255", name: "ci_pipeline_artifacts_verification_failure_text_limit"
    t.check_constraint "file IS NOT NULL", name: "check_abeeb71caf"
  end

  create_table "ci_pipeline_chat_data", force: :cascade do |t|
    t.integer "pipeline_id", null: false
    t.integer "chat_name_id", null: false
    t.text "response_url", null: false
    t.index ["chat_name_id"], name: "index_ci_pipeline_chat_data_on_chat_name_id"
    t.index ["pipeline_id"], name: "index_ci_pipeline_chat_data_on_pipeline_id", unique: true
  end

  create_table "ci_pipeline_messages", force: :cascade do |t|
    t.integer "severity", limit: 2, default: 0, null: false
    t.integer "pipeline_id", null: false
    t.text "content", null: false
    t.index ["pipeline_id"], name: "index_ci_pipeline_messages_on_pipeline_id"
    t.check_constraint "char_length(content) <= 10000", name: "check_58ca2981b2"
  end

  create_table "ci_pipeline_metadata", primary_key: "pipeline_id", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.text "name"
    t.index ["pipeline_id", "name"], name: "index_ci_pipeline_metadata_on_pipeline_id_name"
    t.index ["project_id"], name: "index_ci_pipeline_metadata_on_project_id"
    t.check_constraint "char_length(name) <= 255", name: "check_9d3665463c"
    t.check_constraint "name IS NOT NULL", name: "check_25d23931f1"
  end

  create_table "ci_pipeline_schedule_variables", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.text "encrypted_value"
    t.string "encrypted_value_salt"
    t.string "encrypted_value_iv"
    t.integer "pipeline_schedule_id", null: false
    t.datetime_with_timezone "created_at"
    t.datetime_with_timezone "updated_at"
    t.integer "variable_type", limit: 2, default: 1, null: false
    t.boolean "raw", default: false, null: false
    t.index ["pipeline_schedule_id", "key"], name: "index_ci_pipeline_schedule_variables_on_schedule_id_and_key", unique: true
  end

  create_table "ci_pipeline_schedules", id: :serial, force: :cascade do |t|
    t.string "description"
    t.string "ref"
    t.string "cron"
    t.string "cron_timezone"
    t.datetime "next_run_at"
    t.integer "project_id"
    t.integer "owner_id"
    t.boolean "active", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["next_run_at", "active"], name: "index_ci_pipeline_schedules_on_next_run_at_and_active"
    t.index ["owner_id", "id"], name: "index_ci_pipeline_schedules_on_owner_id_and_id_and_active", where: "(active = true)"
    t.index ["owner_id"], name: "index_ci_pipeline_schedules_on_owner_id"
    t.index ["project_id"], name: "index_ci_pipeline_schedules_on_project_id"
  end

  create_table "ci_pipeline_variables", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.text "encrypted_value"
    t.string "encrypted_value_salt"
    t.string "encrypted_value_iv"
    t.integer "pipeline_id", null: false
    t.integer "variable_type", limit: 2, default: 1, null: false
    t.bigint "partition_id", default: 100, null: false
    t.boolean "raw", default: false, null: false
    t.index ["pipeline_id", "key"], name: "index_ci_pipeline_variables_on_pipeline_id_and_key", unique: true
  end

  create_table "ci_pipelines", id: :serial, force: :cascade do |t|
    t.string "ref"
    t.string "sha"
    t.string "before_sha"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "tag", default: false
    t.text "yaml_errors"
    t.datetime "committed_at"
    t.integer "project_id"
    t.string "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "duration"
    t.integer "user_id"
    t.integer "lock_version", default: 0
    t.integer "auto_canceled_by_id"
    t.integer "pipeline_schedule_id"
    t.integer "source"
    t.integer "config_source"
    t.boolean "protected"
    t.integer "failure_reason"
    t.integer "iid"
    t.integer "merge_request_id"
    t.binary "source_sha"
    t.binary "target_sha"
    t.bigint "external_pull_request_id"
    t.bigint "ci_ref_id"
    t.integer "locked", limit: 2, default: 1, null: false
    t.bigint "partition_id", default: 100, null: false
    t.index ["auto_canceled_by_id"], name: "index_ci_pipelines_on_auto_canceled_by_id"
    t.index ["ci_ref_id", "id", "source", "status"], name: "index_ci_pipelines_on_ci_ref_id_and_more", order: { id: :desc }, where: "(ci_ref_id IS NOT NULL)"
    t.index ["ci_ref_id", "id"], name: "idx_ci_pipelines_artifacts_locked", where: "(locked = 1)"
    t.index ["external_pull_request_id"], name: "index_ci_pipelines_on_external_pull_request_id", where: "(external_pull_request_id IS NOT NULL)"
    t.index ["id"], name: "index_ci_pipelines_for_ondemand_dast_scans", where: "(source = 13)"
    t.index ["merge_request_id"], name: "index_ci_pipelines_on_merge_request_id", where: "(merge_request_id IS NOT NULL)"
    t.index ["pipeline_schedule_id", "id"], name: "index_ci_pipelines_on_pipeline_schedule_id_and_id"
    t.index ["project_id", "id"], name: "index_ci_pipelines_on_project_id_and_id_desc", order: { id: :desc }
    t.index ["project_id", "iid"], name: "index_ci_pipelines_on_project_id_and_iid", unique: true, where: "(iid IS NOT NULL)"
    t.index ["project_id", "ref", "id"], name: "index_ci_pipelines_on_project_idandrefandiddesc", order: { id: :desc }
    t.index ["project_id", "ref", "status", "id"], name: "index_ci_pipelines_on_project_id_and_ref_and_status_and_id"
    t.index ["project_id", "sha"], name: "index_ci_pipelines_on_project_id_and_sha"
    t.index ["project_id", "source"], name: "index_ci_pipelines_on_project_id_and_source"
    t.index ["project_id", "status", "config_source"], name: "index_ci_pipelines_on_project_id_and_status_and_config_source"
    t.index ["project_id", "status", "created_at"], name: "index_ci_pipelines_on_project_id_and_status_and_created_at"
    t.index ["project_id", "status", "updated_at"], name: "index_ci_pipelines_on_project_id_and_status_and_updated_at"
    t.index ["project_id", "user_id", "status", "ref"], name: "index_ci_pipelines_on_project_id_and_user_id_and_status_and_ref", where: "(source <> 12)"
    t.index ["status", "id"], name: "index_ci_pipelines_on_status_and_id"
    t.index ["user_id", "created_at", "config_source"], name: "index_ci_pipelines_on_user_id_and_created_at_and_config_source"
    t.index ["user_id", "created_at", "source"], name: "index_ci_pipelines_on_user_id_and_created_at_and_source"
    t.index ["user_id", "id"], name: "index_ci_pipelines_on_user_id_and_id_and_cancelable_status", where: "((status)::text = ANY (ARRAY[('running'::character varying)::text, ('waiting_for_resource'::character varying)::text, ('preparing'::character varying)::text, ('pending'::character varying)::text, ('created'::character varying)::text, ('scheduled'::character varying)::text]))"
    t.index ["user_id", "id"], name: "index_ci_pipelines_on_user_id_and_id_desc_and_user_not_verified", order: { id: :desc }, where: "(failure_reason = 3)"
    t.check_constraint "lock_version IS NOT NULL", name: "check_d7e99a025e"
  end

  create_table "ci_pipelines_config", primary_key: "pipeline_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "content", null: false
    t.index ["pipeline_id"], name: "index_ci_pipelines_config_on_pipeline_id"
  end

  create_table "ci_platform_metrics", force: :cascade do |t|
    t.datetime_with_timezone "recorded_at", null: false
    t.text "platform_target", null: false
    t.integer "count", null: false
    t.check_constraint "char_length(platform_target) <= 255", name: "check_f922abc32b"
    t.check_constraint "count > 0", name: "ci_platform_metrics_check_count_positive"
  end

  create_table "ci_project_mirrors", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "namespace_id", null: false
    t.index ["namespace_id"], name: "index_ci_project_mirrors_on_namespace_id"
    t.index ["project_id"], name: "index_ci_project_mirrors_on_project_id", unique: true
  end

  create_table "ci_project_monthly_usages", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.date "date", null: false
    t.decimal "amount_used", precision: 18, scale: 2, default: "0.0", null: false
    t.integer "shared_runners_duration", default: 0, null: false
    t.datetime_with_timezone "created_at"
    t.decimal "new_amount_used", precision: 18, scale: 4, default: "0.0", null: false
    t.index ["project_id", "date"], name: "index_ci_project_monthly_usages_on_project_id_and_date", unique: true
    t.check_constraint "date = date_trunc('month'::text, (date)::timestamp with time zone)", name: "ci_project_monthly_usages_year_month_constraint"
  end

  create_table "ci_refs", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.text "ref_path", null: false
    t.index ["project_id", "ref_path"], name: "index_ci_refs_on_project_id_and_ref_path", unique: true
  end

  create_table "ci_resource_groups", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.string "key", limit: 255, null: false
    t.integer "process_mode", limit: 2, default: 0, null: false
    t.index ["project_id", "key"], name: "index_ci_resource_groups_on_project_id_and_key", unique: true
  end

  create_table "ci_resources", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "resource_group_id", null: false
    t.bigint "build_id"
    t.bigint "partition_id", default: 100, null: false
    t.index ["build_id"], name: "index_ci_resources_on_build_id"
    t.index ["resource_group_id", "build_id"], name: "index_ci_resources_on_resource_group_id_and_build_id", unique: true
  end

  create_table "ci_runner_namespaces", id: :serial, force: :cascade do |t|
    t.integer "runner_id"
    t.integer "namespace_id"
    t.index ["namespace_id"], name: "index_ci_runner_namespaces_on_namespace_id"
    t.index ["runner_id", "namespace_id"], name: "index_ci_runner_namespaces_on_runner_id_and_namespace_id", unique: true
  end

  create_table "ci_runner_projects", id: :serial, force: :cascade do |t|
    t.integer "runner_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "project_id"
    t.index ["project_id"], name: "index_ci_runner_projects_on_project_id"
    t.index ["runner_id", "project_id"], name: "index_unique_ci_runner_projects_on_runner_id_and_project_id", unique: true
  end

  create_table "ci_runner_versions", primary_key: "version", id: :text, force: :cascade do |t|
    t.integer "status", limit: 2
    t.index ["status", "version"], name: "index_ci_runner_versions_on_unique_status_and_version", unique: true
    t.check_constraint "char_length(version) <= 2048", name: "check_b5a3714594"
  end

  create_table "ci_runners", id: :serial, force: :cascade do |t|
    t.string "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description"
    t.datetime "contacted_at"
    t.boolean "active", default: true, null: false
    t.string "name"
    t.string "version"
    t.string "revision"
    t.string "platform"
    t.string "architecture"
    t.boolean "run_untagged", default: true, null: false
    t.boolean "locked", default: false, null: false
    t.integer "access_level", default: 0, null: false
    t.string "ip_address"
    t.integer "maximum_timeout"
    t.integer "runner_type", limit: 2, null: false
    t.string "token_encrypted"
    t.float "public_projects_minutes_cost_factor", default: 0.0, null: false
    t.float "private_projects_minutes_cost_factor", default: 1.0, null: false
    t.jsonb "config", default: {}, null: false
    t.integer "executor_type", limit: 2
    t.text "maintainer_note"
    t.datetime_with_timezone "token_expires_at"
    t.text "allowed_plans", default: [], null: false, array: true
    t.index ["active", "id"], name: "index_ci_runners_on_active"
    t.index ["contacted_at", "id"], name: "index_ci_runners_on_contacted_at_and_id_desc", order: { id: :desc }
    t.index ["contacted_at", "id"], name: "index_ci_runners_on_contacted_at_and_id_where_inactive", order: :desc, where: "(active = false)"
    t.index ["contacted_at", "id"], name: "index_ci_runners_on_contacted_at_desc_and_id_desc", order: :desc
    t.index ["created_at", "id"], name: "index_ci_runners_on_created_at_and_id_desc", order: { id: :desc }
    t.index ["created_at", "id"], name: "index_ci_runners_on_created_at_and_id_where_inactive", order: :desc, where: "(active = false)"
    t.index ["created_at", "id"], name: "index_ci_runners_on_created_at_desc_and_id_desc", order: :desc
    t.index ["description"], name: "index_ci_runners_on_description_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["locked"], name: "index_ci_runners_on_locked"
    t.index ["runner_type"], name: "index_ci_runners_on_runner_type"
    t.index ["token"], name: "index_uniq_ci_runners_on_token", unique: true
    t.index ["token_encrypted"], name: "index_uniq_ci_runners_on_token_encrypted", unique: true
    t.index ["token_expires_at", "id"], name: "index_ci_runners_on_token_expires_at_and_id_desc", order: { id: :desc }
    t.index ["token_expires_at", "id"], name: "index_ci_runners_on_token_expires_at_desc_and_id_desc", order: :desc
    t.index ["version"], name: "index_ci_runners_on_version"
    t.check_constraint "char_length(maintainer_note) <= 1024", name: "check_ce275cee06"
  end

  create_table "ci_running_builds", force: :cascade do |t|
    t.bigint "build_id", null: false
    t.bigint "project_id", null: false
    t.bigint "runner_id", null: false
    t.datetime_with_timezone "created_at", default: -> { "now()" }, null: false
    t.integer "runner_type", limit: 2, null: false
    t.bigint "partition_id", default: 100, null: false
    t.index ["build_id"], name: "index_ci_running_builds_on_build_id", unique: true
    t.index ["project_id"], name: "index_ci_running_builds_on_project_id"
    t.index ["runner_id"], name: "index_ci_running_builds_on_runner_id"
  end

  create_table "ci_secure_file_states", primary_key: "ci_secure_file_id", force: :cascade do |t|
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.integer "verification_retry_count", limit: 2
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.index ["ci_secure_file_id"], name: "index_ci_secure_file_states_on_ci_secure_file_id"
    t.index ["verification_retry_at"], name: "index_ci_secure_file_states_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_ci_secure_file_states_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_ci_secure_file_states_on_verification_state"
    t.index ["verified_at"], name: "index_ci_secure_file_states_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_a79e5a9261"
  end

  create_table "ci_secure_files", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "file_store", limit: 2, default: 1, null: false
    t.text "name", null: false
    t.text "file", null: false
    t.binary "checksum", null: false
    t.text "key_data"
    t.jsonb "metadata"
    t.datetime_with_timezone "expires_at"
    t.index ["project_id"], name: "index_ci_secure_files_on_project_id"
    t.check_constraint "char_length(file) <= 255", name: "check_320790634d"
    t.check_constraint "char_length(key_data) <= 128", name: "check_7279b4e293"
    t.check_constraint "char_length(name) <= 255", name: "check_402c7b4a56"
  end

  create_table "ci_sources_pipelines", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "pipeline_id"
    t.integer "source_project_id"
    t.integer "source_pipeline_id"
    t.bigint "source_job_id"
    t.bigint "partition_id", default: 100, null: false
    t.index ["pipeline_id"], name: "index_ci_sources_pipelines_on_pipeline_id"
    t.index ["project_id"], name: "index_ci_sources_pipelines_on_project_id"
    t.index ["source_job_id"], name: "index_ci_sources_pipelines_on_source_job_id"
    t.index ["source_pipeline_id"], name: "index_ci_sources_pipelines_on_source_pipeline_id"
    t.index ["source_project_id"], name: "index_ci_sources_pipelines_on_source_project_id"
  end

  create_table "ci_sources_projects", force: :cascade do |t|
    t.bigint "pipeline_id", null: false
    t.bigint "source_project_id", null: false
    t.index ["pipeline_id"], name: "index_ci_sources_projects_on_pipeline_id"
    t.index ["source_project_id", "pipeline_id"], name: "index_ci_sources_projects_on_source_project_id_and_pipeline_id", unique: true
  end

  create_table "ci_stages", force: :cascade do |t|
    t.integer "project_id"
    t.integer "pipeline_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.integer "status"
    t.integer "lock_version", default: 0
    t.integer "position"
    t.bigint "partition_id", default: 100, null: false
    t.index ["pipeline_id", "id"], name: "index_ci_stages_on_pipeline_id_and_id", where: "(status = ANY (ARRAY[0, 1, 2, 8, 9, 10]))"
    t.index ["pipeline_id", "name"], name: "index_ci_stages_on_pipeline_id_and_name", unique: true
    t.index ["pipeline_id", "position"], name: "index_ci_stages_on_pipeline_id_and_position"
    t.index ["pipeline_id"], name: "index_ci_stages_on_pipeline_id"
    t.index ["project_id"], name: "index_ci_stages_on_project_id"
    t.check_constraint "lock_version IS NOT NULL", name: "check_81b431e49b"
  end

  create_table "ci_subscriptions_projects", force: :cascade do |t|
    t.bigint "downstream_project_id", null: false
    t.bigint "upstream_project_id", null: false
    t.bigint "author_id"
    t.index ["author_id"], name: "index_ci_subscriptions_projects_author_id"
    t.index ["downstream_project_id", "upstream_project_id"], name: "index_ci_subscriptions_projects_unique_subscription", unique: true
    t.index ["upstream_project_id"], name: "index_ci_subscriptions_projects_on_upstream_project_id"
  end

  create_table "ci_trigger_requests", id: :serial, force: :cascade do |t|
    t.integer "trigger_id", null: false
    t.text "variables"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "commit_id"
    t.index ["commit_id"], name: "index_ci_trigger_requests_on_commit_id"
    t.index ["trigger_id", "id"], name: "index_ci_trigger_requests_on_trigger_id_and_id", order: { id: :desc }
  end

  create_table "ci_triggers", id: :serial, force: :cascade do |t|
    t.string "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "project_id"
    t.integer "owner_id", null: false
    t.string "description"
    t.string "ref"
    t.index ["owner_id"], name: "index_ci_triggers_on_owner_id"
    t.index ["project_id"], name: "index_ci_triggers_on_project_id"
  end

  create_table "ci_unit_test_failures", force: :cascade do |t|
    t.datetime_with_timezone "failed_at", null: false
    t.bigint "unit_test_id", null: false
    t.bigint "build_id", null: false
    t.bigint "partition_id", default: 100, null: false
    t.index ["build_id"], name: "index_ci_unit_test_failures_on_build_id"
    t.index ["failed_at"], name: "index_unit_test_failures_failed_at", order: :desc
    t.index ["unit_test_id", "failed_at", "build_id"], name: "index_unit_test_failures_unique_columns", unique: true, order: { failed_at: :desc }
  end

  create_table "ci_unit_tests", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.text "key_hash", null: false
    t.text "name", null: false
    t.text "suite_name", null: false
    t.index ["project_id", "key_hash"], name: "index_ci_unit_tests_on_project_id_and_key_hash", unique: true
    t.check_constraint "char_length(key_hash) <= 64", name: "check_b288215ffe"
    t.check_constraint "char_length(name) <= 255", name: "check_248fae1a3b"
    t.check_constraint "char_length(suite_name) <= 255", name: "check_c2d57b3c49"
  end

  create_table "ci_variables", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.text "encrypted_value"
    t.string "encrypted_value_salt"
    t.string "encrypted_value_iv"
    t.integer "project_id", null: false
    t.boolean "protected", default: false, null: false
    t.string "environment_scope", default: "*", null: false
    t.boolean "masked", default: false, null: false
    t.integer "variable_type", limit: 2, default: 1, null: false
    t.boolean "raw", default: false, null: false
    t.index ["key"], name: "index_ci_variables_on_key"
    t.index ["project_id", "key", "environment_scope"], name: "index_ci_variables_on_project_id_and_key_and_environment_scope", unique: true
  end

  create_table "cluster_agent_tokens", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "agent_id", null: false
    t.text "token_encrypted", null: false
    t.bigint "created_by_user_id"
    t.text "description"
    t.text "name"
    t.datetime_with_timezone "last_used_at"
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["agent_id", "status", "last_used_at"], name: "index_cluster_agent_tokens_on_agent_id_status_last_used_at", order: { last_used_at: "DESC NULLS LAST" }
    t.index ["created_by_user_id"], name: "index_cluster_agent_tokens_on_created_by_user_id"
    t.index ["token_encrypted"], name: "index_cluster_agent_tokens_on_token_encrypted", unique: true
    t.check_constraint "char_length(description) <= 1024", name: "check_4e4ec5070a"
    t.check_constraint "char_length(name) <= 255", name: "check_2b79dbb315"
    t.check_constraint "char_length(token_encrypted) <= 255", name: "check_c60daed227"
    t.check_constraint "name IS NOT NULL", name: "check_0fb634d04d"
  end

  create_table "cluster_agents", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.text "name", null: false
    t.bigint "created_by_user_id"
    t.boolean "has_vulnerabilities", default: false, null: false
    t.index ["created_by_user_id"], name: "index_cluster_agents_on_created_by_user_id"
    t.index ["project_id", "has_vulnerabilities"], name: "index_cluster_agents_on_project_id_and_has_vulnerabilities"
    t.index ["project_id", "name"], name: "index_cluster_agents_on_project_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_3498369510"
  end

  create_table "cluster_enabled_grants", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.index ["namespace_id"], name: "index_cluster_enabled_grants_on_namespace_id", unique: true
  end

  create_table "cluster_groups", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "group_id", null: false
    t.index ["cluster_id", "group_id"], name: "index_cluster_groups_on_cluster_id_and_group_id", unique: true
    t.index ["group_id"], name: "index_cluster_groups_on_group_id"
  end

  create_table "cluster_platforms_kubernetes", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "api_url"
    t.text "ca_cert"
    t.string "namespace"
    t.string "username"
    t.text "encrypted_password"
    t.string "encrypted_password_iv"
    t.text "encrypted_token"
    t.string "encrypted_token_iv"
    t.integer "authorization_type", limit: 2
    t.index ["cluster_id"], name: "index_cluster_platforms_kubernetes_on_cluster_id", unique: true
  end

  create_table "cluster_projects", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cluster_id"], name: "index_cluster_projects_on_cluster_id"
    t.index ["project_id"], name: "index_cluster_projects_on_project_id"
  end

  create_table "cluster_providers_aws", force: :cascade do |t|
    t.bigint "cluster_id", null: false
    t.integer "num_nodes", null: false
    t.integer "status", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "key_name", limit: 255, null: false
    t.string "role_arn", limit: 2048, null: false
    t.string "region", limit: 255, null: false
    t.string "vpc_id", limit: 255, null: false
    t.string "subnet_ids", limit: 255, default: [], null: false, array: true
    t.string "security_group_id", limit: 255, null: false
    t.string "instance_type", limit: 255, null: false
    t.string "access_key_id", limit: 255
    t.string "encrypted_secret_access_key_iv", limit: 255
    t.text "encrypted_secret_access_key"
    t.text "session_token"
    t.text "status_reason"
    t.text "kubernetes_version", default: "1.14", null: false
    t.index ["cluster_id", "status"], name: "index_cluster_providers_aws_on_cluster_id_and_status"
    t.index ["cluster_id"], name: "index_cluster_providers_aws_on_cluster_id", unique: true
    t.check_constraint "char_length(kubernetes_version) <= 30", name: "check_f1f42cd85e"
  end

  create_table "cluster_providers_gcp", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "status"
    t.integer "num_nodes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "status_reason"
    t.string "gcp_project_id", null: false
    t.string "zone", null: false
    t.string "machine_type"
    t.string "operation_id"
    t.string "endpoint"
    t.text "encrypted_access_token"
    t.string "encrypted_access_token_iv"
    t.boolean "legacy_abac", default: false, null: false
    t.boolean "cloud_run", default: false, null: false
    t.index ["cloud_run"], name: "index_cluster_providers_gcp_on_cloud_run"
    t.index ["cluster_id"], name: "index_cluster_providers_gcp_on_cluster_id", unique: true
  end

  create_table "clusters", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "provider_type"
    t.integer "platform_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: true
    t.string "name", null: false
    t.string "environment_scope", default: "*", null: false
    t.integer "cluster_type", limit: 2, default: 3, null: false
    t.string "domain"
    t.boolean "managed", default: true, null: false
    t.boolean "namespace_per_environment", default: true, null: false
    t.integer "management_project_id"
    t.integer "cleanup_status", limit: 2, default: 1, null: false
    t.text "cleanup_status_reason"
    t.integer "helm_major_version", default: 3, null: false
    t.index ["enabled", "cluster_type", "id", "created_at"], name: "index_clusters_on_enabled_cluster_type_id_and_created_at"
    t.index ["enabled", "provider_type", "id"], name: "index_clusters_on_enabled_and_provider_type_and_id"
    t.index ["id"], name: "index_enabled_clusters_on_id", where: "(enabled = true)"
    t.index ["management_project_id"], name: "index_clusters_on_management_project_id", where: "(management_project_id IS NOT NULL)"
    t.index ["user_id"], name: "index_clusters_on_user_id"
  end

  create_table "clusters_applications_cert_managers", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "status", null: false
    t.string "version", null: false
    t.string "email", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "status_reason"
    t.index ["cluster_id"], name: "index_clusters_applications_cert_managers_on_cluster_id", unique: true
  end

  create_table "clusters_applications_cilium", force: :cascade do |t|
    t.bigint "cluster_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", null: false
    t.text "status_reason"
    t.index ["cluster_id"], name: "index_clusters_applications_cilium_on_cluster_id", unique: true
  end

  create_table "clusters_applications_crossplane", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "cluster_id", null: false
    t.integer "status", null: false
    t.string "version", limit: 255, null: false
    t.string "stack", limit: 255, null: false
    t.text "status_reason"
    t.index ["cluster_id"], name: "index_clusters_applications_crossplane_on_cluster_id", unique: true
  end

  create_table "clusters_applications_helm", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", null: false
    t.string "version", null: false
    t.text "status_reason"
    t.text "encrypted_ca_key"
    t.text "encrypted_ca_key_iv"
    t.text "ca_cert"
    t.index ["cluster_id"], name: "index_clusters_applications_helm_on_cluster_id", unique: true
  end

  create_table "clusters_applications_ingress", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", null: false
    t.integer "ingress_type", null: false
    t.string "version", null: false
    t.string "cluster_ip"
    t.text "status_reason"
    t.string "external_ip"
    t.string "external_hostname"
    t.index ["cluster_id"], name: "index_clusters_applications_ingress_on_cluster_id", unique: true
  end

  create_table "clusters_applications_jupyter", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "oauth_application_id"
    t.integer "status", null: false
    t.string "version", null: false
    t.string "hostname"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "status_reason"
    t.index ["cluster_id"], name: "index_clusters_applications_jupyter_on_cluster_id", unique: true
    t.index ["oauth_application_id"], name: "index_clusters_applications_jupyter_on_oauth_application_id"
  end

  create_table "clusters_applications_knative", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", null: false
    t.string "version", null: false
    t.string "hostname"
    t.text "status_reason"
    t.string "external_ip"
    t.string "external_hostname"
    t.index ["cluster_id"], name: "index_clusters_applications_knative_on_cluster_id", unique: true
  end

  create_table "clusters_applications_prometheus", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "status", null: false
    t.string "version", null: false
    t.text "status_reason"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "last_update_started_at"
    t.string "encrypted_alert_manager_token"
    t.string "encrypted_alert_manager_token_iv"
    t.boolean "healthy"
    t.index ["cluster_id"], name: "index_clusters_applications_prometheus_on_cluster_id", unique: true
  end

  create_table "clusters_applications_runners", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "runner_id"
    t.integer "status", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "version", null: false
    t.text "status_reason"
    t.boolean "privileged", default: true, null: false
    t.index ["cluster_id"], name: "index_clusters_applications_runners_on_cluster_id", unique: true
    t.index ["runner_id"], name: "index_clusters_applications_runners_on_runner_id"
  end

  create_table "clusters_integration_prometheus", primary_key: "cluster_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "enabled", default: false, null: false
    t.text "encrypted_alert_manager_token"
    t.text "encrypted_alert_manager_token_iv"
    t.integer "health_status", limit: 2, default: 0, null: false
    t.index ["enabled", "created_at", "cluster_id"], name: "index_clusters_integration_prometheus_enabled"
  end

  create_table "clusters_kubernetes_namespaces", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "project_id"
    t.integer "cluster_project_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "encrypted_service_account_token"
    t.string "encrypted_service_account_token_iv"
    t.string "namespace", null: false
    t.string "service_account_name"
    t.bigint "environment_id"
    t.index ["cluster_id", "namespace"], name: "kubernetes_namespaces_cluster_and_namespace", unique: true
    t.index ["cluster_id", "project_id", "environment_id"], name: "index_kubernetes_namespaces_on_cluster_project_environment_id", unique: true
    t.index ["cluster_project_id"], name: "index_clusters_kubernetes_namespaces_on_cluster_project_id"
    t.index ["environment_id"], name: "index_clusters_kubernetes_namespaces_on_environment_id"
    t.index ["project_id"], name: "index_clusters_kubernetes_namespaces_on_project_id"
  end

  create_table "commit_user_mentions", force: :cascade do |t|
    t.integer "note_id", null: false
    t.integer "mentioned_users_ids", array: true
    t.integer "mentioned_projects_ids", array: true
    t.integer "mentioned_groups_ids", array: true
    t.string "commit_id", null: false
    t.index ["commit_id", "note_id"], name: "commit_user_mentions_on_commit_id_and_note_id_unique_index", unique: true
    t.index ["note_id"], name: "index_commit_user_mentions_on_note_id", unique: true
  end

  create_table "compliance_management_frameworks", force: :cascade do |t|
    t.text "name", null: false
    t.text "description", null: false
    t.text "color", null: false
    t.integer "namespace_id", null: false
    t.text "pipeline_configuration_full_path"
    t.datetime_with_timezone "created_at"
    t.datetime_with_timezone "updated_at"
    t.index ["id", "created_at", "pipeline_configuration_full_path"], name: "i_compliance_frameworks_on_id_and_created_at"
    t.index ["id"], name: "index_compliance_frameworks_id_where_frameworks_not_null", where: "(pipeline_configuration_full_path IS NOT NULL)"
    t.index ["namespace_id", "name"], name: "idx_on_compliance_management_frameworks_namespace_id_name", unique: true
    t.check_constraint "char_length(color) <= 10", name: "check_08cd34b2c2"
    t.check_constraint "char_length(description) <= 255", name: "check_1617e0b87e"
    t.check_constraint "char_length(name) <= 255", name: "check_ab00bc2193"
    t.check_constraint "char_length(pipeline_configuration_full_path) <= 255", name: "check_e7a9972435"
  end

  create_table "container_expiration_policies", primary_key: "project_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "next_run_at"
    t.string "name_regex", limit: 255, default: ".*"
    t.string "cadence", limit: 12, default: "1d", null: false
    t.string "older_than", limit: 12, default: "90d"
    t.integer "keep_n", default: 10
    t.boolean "enabled", default: false, null: false
    t.text "name_regex_keep"
    t.index ["next_run_at", "enabled"], name: "index_container_expiration_policies_on_next_run_at_and_enabled"
    t.index ["project_id", "next_run_at", "enabled"], name: "idx_container_exp_policies_on_project_id_next_run_at_enabled"
    t.index ["project_id", "next_run_at"], name: "idx_container_exp_policies_on_project_id_next_run_at", where: "(enabled = true)"
    t.check_constraint "char_length(name_regex_keep) <= 255", name: "container_expiration_policies_name_regex_keep"
  end

  create_table "container_repositories", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", limit: 2
    t.datetime_with_timezone "expiration_policy_started_at"
    t.integer "expiration_policy_cleanup_status", limit: 2, default: 0, null: false
    t.datetime_with_timezone "expiration_policy_completed_at"
    t.datetime_with_timezone "migration_pre_import_started_at"
    t.datetime_with_timezone "migration_pre_import_done_at"
    t.datetime_with_timezone "migration_import_started_at"
    t.datetime_with_timezone "migration_import_done_at"
    t.datetime_with_timezone "migration_aborted_at"
    t.datetime_with_timezone "migration_skipped_at"
    t.integer "migration_retries_count", default: 0, null: false
    t.integer "migration_skipped_reason", limit: 2
    t.text "migration_state", default: "default", null: false
    t.text "migration_aborted_in_state"
    t.text "migration_plan"
    t.integer "last_cleanup_deleted_tags_count"
    t.datetime_with_timezone "delete_started_at"
    t.datetime_with_timezone "status_updated_at"
    t.index "GREATEST(migration_pre_import_done_at, migration_import_done_at, migration_aborted_at, migration_skipped_at)", name: "index_container_repositories_on_greatest_completed_at", where: "(migration_state = ANY (ARRAY['import_done'::text, 'pre_import_done'::text, 'import_aborted'::text, 'import_skipped'::text]))"
    t.index ["expiration_policy_cleanup_status", "project_id", "expiration_policy_started_at"], name: "idx_container_repos_on_exp_cleanup_status_project_id_start_date"
    t.index ["id", "migration_state"], name: "tmp_index_container_repositories_on_id_migration_state"
    t.index ["migration_import_started_at"], name: "idx_container_repos_on_import_started_at_when_importing", where: "(migration_state = 'importing'::text)"
    t.index ["migration_pre_import_done_at"], name: "idx_container_repos_on_pre_import_done_at_when_pre_import_done", where: "(migration_state = 'pre_import_done'::text)"
    t.index ["migration_pre_import_started_at"], name: "idx_container_repos_on_pre_import_started_at_when_pre_importing", where: "(migration_state = 'pre_importing'::text)"
    t.index ["migration_state", "migration_import_done_at"], name: "index_container_repositories_on_migration_state_import_done_at"
    t.index ["migration_state", "migration_plan", "created_at"], name: "idx_container_repos_on_migration_state_migration_plan_created"
    t.index ["name"], name: "index_container_repository_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["project_id", "id"], name: "index_container_repositories_on_project_id_and_id"
    t.index ["project_id", "id"], name: "tmp_index_container_repos_on_non_migrated", where: "(migration_state <> 'import_done'::text)"
    t.index ["project_id", "name"], name: "index_container_repositories_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_container_repositories_on_project_id"
    t.index ["project_id"], name: "tmp_index_migrated_container_registries", where: "((migration_state = 'import_done'::text) OR (created_at >= '2022-01-23 00:00:00'::timestamp without time zone))"
    t.index ["status", "id"], name: "index_container_repositories_on_status_and_id", where: "(status IS NOT NULL)"
    t.check_constraint "char_length(migration_aborted_in_state) <= 255", name: "check_97f0249439"
    t.check_constraint "char_length(migration_plan) <= 255", name: "check_05e9012f36"
    t.check_constraint "char_length(migration_state) <= 255", name: "check_13c58fe73a"
  end

  create_table "content_blocked_states", comment: "JiHu-specific table", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.binary "commit_sha", null: false
    t.binary "blob_sha", null: false
    t.text "path", null: false
    t.text "container_identifier", null: false
    t.index ["container_identifier", "commit_sha", "path"], name: "index_content_blocked_states_on_container_id_commit_sha_path", unique: true
    t.check_constraint "char_length(container_identifier) <= 255", name: "check_023093d38f"
    t.check_constraint "char_length(path) <= 2048", name: "check_1870100678"
  end

  create_table "conversational_development_index_metrics", id: :serial, force: :cascade do |t|
    t.float "leader_issues", null: false
    t.float "instance_issues", null: false
    t.float "leader_notes", null: false
    t.float "instance_notes", null: false
    t.float "leader_milestones", null: false
    t.float "instance_milestones", null: false
    t.float "leader_boards", null: false
    t.float "instance_boards", null: false
    t.float "leader_merge_requests", null: false
    t.float "instance_merge_requests", null: false
    t.float "leader_ci_pipelines", null: false
    t.float "instance_ci_pipelines", null: false
    t.float "leader_environments", null: false
    t.float "instance_environments", null: false
    t.float "leader_deployments", null: false
    t.float "instance_deployments", null: false
    t.float "leader_projects_prometheus_active", null: false
    t.float "instance_projects_prometheus_active", null: false
    t.float "leader_service_desk_issues", null: false
    t.float "instance_service_desk_issues", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "percentage_boards", default: 0.0, null: false
    t.float "percentage_ci_pipelines", default: 0.0, null: false
    t.float "percentage_deployments", default: 0.0, null: false
    t.float "percentage_environments", default: 0.0, null: false
    t.float "percentage_issues", default: 0.0, null: false
    t.float "percentage_merge_requests", default: 0.0, null: false
    t.float "percentage_milestones", default: 0.0, null: false
    t.float "percentage_notes", default: 0.0, null: false
    t.float "percentage_projects_prometheus_active", default: 0.0, null: false
    t.float "percentage_service_desk_issues", default: 0.0, null: false
  end

  create_table "coverage_fuzzing_corpuses", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id"
    t.bigint "package_id", null: false
    t.datetime_with_timezone "file_updated_at", default: -> { "now()" }, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["package_id"], name: "index_coverage_fuzzing_corpuses_on_package_id", unique: true
    t.index ["project_id"], name: "index_coverage_fuzzing_corpuses_on_project_id"
    t.index ["user_id"], name: "index_coverage_fuzzing_corpuses_on_user_id"
  end

  create_table "csv_issue_imports", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["project_id"], name: "index_csv_issue_imports_on_project_id"
    t.index ["user_id"], name: "index_csv_issue_imports_on_user_id"
  end

  create_table "custom_emoji", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "name", null: false
    t.text "file", null: false
    t.boolean "external", default: true, null: false
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_custom_emoji_on_creator_id"
    t.index ["namespace_id", "name"], name: "index_custom_emoji_on_namespace_id_and_name", unique: true
    t.check_constraint "char_length(file) <= 255", name: "check_dd5d60f1fb"
    t.check_constraint "char_length(name) <= 36", name: "check_8c586dd507"
  end

  create_table "customer_relations_contacts", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "organization_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "state", limit: 2, default: 1, null: false
    t.text "phone"
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.text "email"
    t.text "description"
    t.index "group_id, lower(email), id", name: "index_customer_relations_contacts_on_unique_email_per_group", unique: true
    t.index ["group_id"], name: "index_customer_relations_contacts_on_group_id"
    t.index ["organization_id"], name: "index_customer_relations_contacts_on_organization_id"
    t.check_constraint "char_length(description) <= 1024", name: "check_40c70da037"
    t.check_constraint "char_length(email) <= 255", name: "check_fc0adabf60"
    t.check_constraint "char_length(first_name) <= 255", name: "check_1195f4c929"
    t.check_constraint "char_length(last_name) <= 255", name: "check_cd2d67c484"
    t.check_constraint "char_length(phone) <= 32", name: "check_f4b7f78c89"
  end

  create_table "customer_relations_organizations", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "state", limit: 2, default: 1, null: false
    t.decimal "default_rate", precision: 18, scale: 2
    t.text "name", null: false
    t.text "description"
    t.index "group_id, lower(name), id", name: "index_organizations_on_unique_name_per_group", unique: true
    t.check_constraint "char_length(description) <= 1024", name: "check_e476b6058e"
    t.check_constraint "char_length(name) <= 255", name: "check_2ba9ef1c4c"
  end

  create_table "dast_pre_scan_verifications", force: :cascade do |t|
    t.bigint "dast_profile_id", null: false
    t.bigint "ci_pipeline_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["ci_pipeline_id"], name: "index_dast_pre_scan_verifications_on_ci_pipeline_id", unique: true
    t.index ["dast_profile_id"], name: "index_dast_pre_scan_verifications_on_dast_profile_id"
  end

  create_table "dast_profile_schedules", comment: "{\"owner\":\"group::dynamic analysis\",\"description\":\"Scheduling for scans using DAST Profiles\"}", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "dast_profile_id", null: false
    t.bigint "user_id"
    t.datetime_with_timezone "next_run_at", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.text "cron", null: false
    t.jsonb "cadence", default: {}, null: false
    t.text "timezone", null: false
    t.datetime_with_timezone "starts_at", default: -> { "now()" }, null: false
    t.index ["active", "next_run_at"], name: "index_dast_profile_schedules_active_next_run_at"
    t.index ["dast_profile_id"], name: "index_dast_profile_schedules_on_dast_profile_id", unique: true
    t.index ["project_id"], name: "index_dast_profile_schedules_on_project_id"
    t.index ["user_id"], name: "index_dast_profile_schedules_on_user_id"
    t.check_constraint "char_length(cron) <= 255", name: "check_86531ea73f"
    t.check_constraint "char_length(timezone) <= 255", name: "check_be4d1c3af1"
  end

  create_table "dast_profiles", comment: "{\"owner\":\"group::dynamic analysis\",\"description\":\"Profile used to run a DAST on-demand scan\"}", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "dast_site_profile_id", null: false
    t.bigint "dast_scanner_profile_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "name", null: false
    t.text "description", null: false
    t.text "branch_name"
    t.index ["dast_scanner_profile_id"], name: "index_dast_profiles_on_dast_scanner_profile_id"
    t.index ["dast_site_profile_id"], name: "index_dast_profiles_on_dast_site_profile_id"
    t.index ["project_id", "name"], name: "index_dast_profiles_on_project_id_and_name", unique: true
    t.check_constraint "char_length(branch_name) <= 255", name: "check_6c9d775949"
    t.check_constraint "char_length(description) <= 255", name: "check_c34e505c24"
    t.check_constraint "char_length(name) <= 255", name: "check_5fcf73bf61"
  end

  create_table "dast_profiles_pipelines", primary_key: ["dast_profile_id", "ci_pipeline_id"], comment: "{\"owner\":\"group::dynamic analysis\",\"description\":\"Join table between DAST Profiles and CI Pipelines\"}", force: :cascade do |t|
    t.bigint "dast_profile_id", null: false
    t.bigint "ci_pipeline_id", null: false
    t.index ["ci_pipeline_id"], name: "index_dast_profiles_pipelines_on_ci_pipeline_id", unique: true
  end

  create_table "dast_scanner_profiles", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "project_id", null: false
    t.integer "spider_timeout", limit: 2
    t.integer "target_timeout", limit: 2
    t.text "name", null: false
    t.integer "scan_type", limit: 2, default: 1, null: false
    t.boolean "use_ajax_spider", default: false, null: false
    t.boolean "show_debug_messages", default: false, null: false
    t.index ["project_id", "name"], name: "index_dast_scanner_profiles_on_project_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_568568fabf"
  end

  create_table "dast_scanner_profiles_builds", primary_key: ["dast_scanner_profile_id", "ci_build_id"], comment: "{\"owner\":\"group::dynamic analysis\",\"description\":\"Join table between DAST Scanner Profiles and CI Builds\"}", force: :cascade do |t|
    t.bigint "dast_scanner_profile_id", null: false
    t.bigint "ci_build_id", null: false
    t.index ["ci_build_id"], name: "dast_scanner_profiles_builds_on_ci_build_id", unique: true
  end

  create_table "dast_site_profile_secret_variables", comment: "{\"owner\":\"group::dynamic analysis\",\"description\":\"Secret variables used in DAST on-demand scans\"}", force: :cascade do |t|
    t.bigint "dast_site_profile_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "variable_type", limit: 2, default: 1, null: false
    t.text "key", null: false
    t.binary "encrypted_value", null: false
    t.binary "encrypted_value_iv", null: false
    t.index ["dast_site_profile_id", "key"], name: "index_site_profile_secret_variables_on_site_profile_id_and_key", unique: true
    t.check_constraint "char_length(key) <= 255", name: "check_8cbef204b2"
    t.check_constraint "length(encrypted_value) <= 13352", name: "check_236213f179"
    t.check_constraint "length(encrypted_value_iv) <= 17", name: "check_b49080abbf"
  end

  create_table "dast_site_profiles", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "dast_site_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "name", null: false
    t.text "excluded_urls", default: [], null: false, array: true
    t.boolean "auth_enabled", default: false, null: false
    t.text "auth_url"
    t.text "auth_username_field"
    t.text "auth_password_field"
    t.text "auth_username"
    t.integer "target_type", limit: 2, default: 0, null: false
    t.integer "scan_method", limit: 2, default: 0, null: false
    t.text "auth_submit_field"
    t.text "scan_file_path"
    t.index ["dast_site_id"], name: "index_dast_site_profiles_on_dast_site_id"
    t.index ["project_id", "name"], name: "index_dast_site_profiles_on_project_id_and_name", unique: true
    t.check_constraint "char_length(auth_password_field) <= 255", name: "check_c329dffdba"
    t.check_constraint "char_length(auth_submit_field) <= 255", name: "check_af44f54c96"
    t.check_constraint "char_length(auth_url) <= 1024", name: "check_d446f7047b"
    t.check_constraint "char_length(auth_username) <= 255", name: "check_f22f18002a"
    t.check_constraint "char_length(auth_username_field) <= 255", name: "check_5203110fee"
    t.check_constraint "char_length(name) <= 255", name: "check_6cfab17b48"
    t.check_constraint "char_length(scan_file_path) <= 1024", name: "check_8d2aa0f66d"
  end

  create_table "dast_site_profiles_builds", primary_key: ["dast_site_profile_id", "ci_build_id"], comment: "{\"owner\":\"group::dynamic analysis\",\"description\":\"Join table between DAST Site Profiles and CI Builds\"}", force: :cascade do |t|
    t.bigint "dast_site_profile_id", null: false
    t.bigint "ci_build_id", null: false
    t.index ["ci_build_id"], name: "dast_site_profiles_builds_on_ci_build_id", unique: true
  end

  create_table "dast_site_profiles_pipelines", primary_key: ["dast_site_profile_id", "ci_pipeline_id"], comment: "{\"owner\":\"group::dynamic analysis\",\"description\":\"Join table between DAST Site Profiles and CI Pipelines\"}", force: :cascade do |t|
    t.bigint "dast_site_profile_id", null: false
    t.bigint "ci_pipeline_id", null: false
    t.index ["ci_pipeline_id"], name: "index_dast_site_profiles_pipelines_on_ci_pipeline_id", unique: true
  end

  create_table "dast_site_tokens", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "expired_at"
    t.text "token", null: false
    t.text "url", null: false
    t.index ["project_id", "url"], name: "index_dast_site_token_on_project_id_and_url", unique: true
    t.index ["project_id"], name: "index_dast_site_tokens_on_project_id"
    t.index ["token"], name: "index_dast_site_token_on_token", unique: true
    t.check_constraint "char_length(token) <= 255", name: "check_02a6bf20a7"
    t.check_constraint "char_length(url) <= 255", name: "check_69ab8622a6"
  end

  create_table "dast_site_validations", force: :cascade do |t|
    t.bigint "dast_site_token_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "validation_started_at"
    t.datetime_with_timezone "validation_passed_at"
    t.datetime_with_timezone "validation_failed_at"
    t.datetime_with_timezone "validation_last_retried_at"
    t.integer "validation_strategy", limit: 2, null: false
    t.text "url_base", null: false
    t.text "url_path", null: false
    t.text "state", default: "pending", null: false
    t.index ["dast_site_token_id"], name: "index_dast_site_validations_on_dast_site_token_id"
    t.index ["url_base", "state"], name: "index_dast_site_validations_on_url_base_and_state"
    t.check_constraint "char_length(state) <= 255", name: "check_283be72e9b"
    t.check_constraint "char_length(url_base) <= 255", name: "check_cd3b538210"
    t.check_constraint "char_length(url_path) <= 255", name: "check_13b34efe4b"
  end

  create_table "dast_sites", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "url", null: false
    t.bigint "dast_site_validation_id"
    t.index ["dast_site_validation_id"], name: "index_dast_sites_on_dast_site_validation_id"
    t.index ["project_id", "url"], name: "index_dast_sites_on_project_id_and_url", unique: true
    t.check_constraint "char_length(url) <= 255", name: "check_46df8b449c"
  end

  create_table "dependency_list_exports", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.bigint "user_id"
    t.integer "file_store"
    t.integer "status", limit: 2, default: 0, null: false
    t.text "file"
    t.index ["project_id"], name: "index_dependency_list_exports_on_project_id"
    t.index ["user_id"], name: "index_dependency_list_exports_on_user_id"
    t.check_constraint "char_length(file) <= 255", name: "check_fff6fc9b2f"
  end

  create_table "dependency_proxy_blob_states", primary_key: "dependency_proxy_blob_id", id: :bigint, default: nil, comment: "{\"owner\":\"group::geo\",\"description\":\"Geo-specific table to store the verification state of DependencyProxy::Blob objects\"}", force: :cascade do |t|
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.integer "verification_retry_count", limit: 2, default: 0, null: false
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.index ["dependency_proxy_blob_id"], name: "index_dependency_proxy_blob_states_on_dependency_proxy_blob_id"
    t.index ["verification_retry_at"], name: "index_dependency_proxy_blob_states_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_dependency_proxy_blob_states_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_dependency_proxy_blob_states_on_verification_state"
    t.index ["verified_at"], name: "index_dependency_proxy_blob_states_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_8e4f76fffe"
  end

  create_table "dependency_proxy_blobs", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "size"
    t.integer "file_store"
    t.string "file_name", null: false
    t.text "file", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.datetime_with_timezone "read_at", default: -> { "now()" }, null: false
    t.index ["group_id", "file_name"], name: "index_dependency_proxy_blobs_on_group_id_and_file_name"
    t.index ["group_id", "status", "read_at", "id"], name: "index_dependency_proxy_blobs_on_group_id_status_read_at_id"
    t.index ["status"], name: "index_dependency_proxy_blobs_on_status"
  end

  create_table "dependency_proxy_group_settings", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "enabled", default: false, null: false
    t.index ["group_id"], name: "index_dependency_proxy_group_settings_on_group_id"
  end

  create_table "dependency_proxy_image_ttl_group_policies", primary_key: "group_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "ttl", default: 90
    t.boolean "enabled", default: false, null: false
  end

  create_table "dependency_proxy_manifest_states", primary_key: "dependency_proxy_manifest_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.integer "verification_retry_count", limit: 2, default: 0, null: false
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.index ["dependency_proxy_manifest_id"], name: "index_manifest_states_on_dependency_proxy_manifest_id"
    t.index ["verification_retry_at"], name: "index_manifest_states_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_manifest_states_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_manifest_states_on_verification_state"
    t.index ["verified_at"], name: "index_manifest_states_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_fdd5d9791b"
  end

  create_table "dependency_proxy_manifests", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "group_id", null: false
    t.bigint "size"
    t.integer "file_store", limit: 2
    t.text "file_name", null: false
    t.text "file", null: false
    t.text "digest", null: false
    t.text "content_type"
    t.integer "status", limit: 2, default: 0, null: false
    t.datetime_with_timezone "read_at", default: -> { "now()" }, null: false
    t.index ["group_id", "file_name", "status"], name: "index_dep_prox_manifests_on_group_id_file_name_and_status", unique: true
    t.index ["group_id", "status", "read_at", "id"], name: "index_dependency_proxy_manifests_on_group_id_status_read_at_id"
    t.index ["status"], name: "index_dependency_proxy_manifests_on_status"
    t.check_constraint "char_length(content_type) <= 255", name: "check_167a9a8a91"
    t.check_constraint "char_length(digest) <= 255", name: "check_f5d9996bf1"
    t.check_constraint "char_length(file) <= 255", name: "check_079b293a7b"
    t.check_constraint "char_length(file_name) <= 255", name: "check_c579e3f586"
  end

  create_table "deploy_keys_projects", id: :serial, force: :cascade do |t|
    t.integer "deploy_key_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "can_push", default: false, null: false
    t.index ["deploy_key_id"], name: "index_deploy_keys_projects_on_deploy_key_id"
    t.index ["project_id"], name: "index_deploy_keys_projects_on_project_id"
  end

  create_table "deploy_tokens", id: :serial, force: :cascade do |t|
    t.boolean "revoked", default: false
    t.boolean "read_repository", default: false, null: false
    t.boolean "read_registry", default: false, null: false
    t.datetime_with_timezone "expires_at", null: false
    t.datetime_with_timezone "created_at", null: false
    t.string "name", null: false
    t.string "username"
    t.string "token_encrypted", limit: 255
    t.integer "deploy_token_type", limit: 2, default: 2, null: false
    t.boolean "write_registry", default: false, null: false
    t.boolean "read_package_registry", default: false, null: false
    t.boolean "write_package_registry", default: false, null: false
    t.bigint "creator_id"
    t.index ["creator_id"], name: "index_deploy_tokens_on_creator_id"
    t.index ["token_encrypted"], name: "index_deploy_tokens_on_token_encrypted", unique: true
  end

  create_table "deployment_approvals", force: :cascade do |t|
    t.bigint "deployment_id", null: false
    t.bigint "user_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", limit: 2, null: false
    t.text "comment"
    t.bigint "approval_rule_id"
    t.index ["approval_rule_id"], name: "index_deployment_approvals_on_approval_rule_id"
    t.index ["created_at", "id"], name: "index_deployment_approvals_on_created_at_and_id"
    t.index ["deployment_id", "user_id"], name: "index_deployment_approvals_on_deployment_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_deployment_approvals_on_user_id"
    t.check_constraint "char_length(comment) <= 255", name: "check_e2eb6a17d8"
  end

  create_table "deployment_clusters", primary_key: "deployment_id", id: :integer, default: nil, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.string "kubernetes_namespace", limit: 255
    t.index ["cluster_id", "deployment_id"], name: "index_deployment_clusters_on_cluster_id_and_deployment_id", unique: true
    t.index ["cluster_id", "kubernetes_namespace"], name: "idx_deployment_clusters_on_cluster_id_and_kubernetes_namespace"
  end

  create_table "deployment_merge_requests", primary_key: ["deployment_id", "merge_request_id"], force: :cascade do |t|
    t.integer "deployment_id", null: false
    t.integer "merge_request_id", null: false
    t.integer "environment_id"
    t.index ["environment_id", "merge_request_id"], name: "idx_environment_merge_requests_unique_index", unique: true
    t.index ["merge_request_id"], name: "index_deployment_merge_requests_on_merge_request_id"
  end

  create_table "deployments", id: :serial, force: :cascade do |t|
    t.integer "iid", null: false
    t.integer "project_id", null: false
    t.integer "environment_id", null: false
    t.string "ref", null: false
    t.boolean "tag", null: false
    t.string "sha", null: false
    t.integer "user_id"
    t.string "deployable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "on_stop"
    t.integer "status", limit: 2, null: false
    t.datetime_with_timezone "finished_at"
    t.integer "cluster_id"
    t.bigint "deployable_id"
    t.boolean "archived", default: false, null: false
    t.index ["archived", "project_id", "iid"], name: "index_deployments_on_archived_project_id_iid"
    t.index ["cluster_id", "environment_id"], name: "index_successful_deployments_on_cluster_id_and_environment_id", where: "(status = 2)"
    t.index ["cluster_id", "status"], name: "index_deployments_on_cluster_id_and_status"
    t.index ["created_at"], name: "index_deployments_on_created_at"
    t.index ["deployable_type", "deployable_id"], name: "index_deployments_on_deployable_type_and_deployable_id"
    t.index ["environment_id", "finished_at"], name: "index_deployments_for_visible_scope", order: { finished_at: :desc }, where: "(status = ANY (ARRAY[1, 2, 3, 4, 6]))"
    t.index ["environment_id", "id"], name: "index_deployments_on_environment_id_and_id"
    t.index ["environment_id", "iid", "project_id"], name: "index_deployments_on_environment_id_and_iid_and_project_id"
    t.index ["environment_id", "ref"], name: "index_deployments_on_environment_id_and_ref"
    t.index ["environment_id", "status", "finished_at"], name: "index_deployments_on_environment_id_status_and_finished_at"
    t.index ["environment_id", "status", "id"], name: "index_deployments_on_environment_id_status_and_id"
    t.index ["environment_id", "status", "sha"], name: "index_deployments_on_environment_status_sha"
    t.index ["id", "status", "created_at"], name: "index_deployments_on_id_and_status_and_created_at"
    t.index ["id"], name: "index_deployments_on_id_where_cluster_id_present", where: "(cluster_id IS NOT NULL)"
    t.index ["id"], name: "partial_index_deployments_for_legacy_successful_deployments", where: "((finished_at IS NULL) AND (status = 2))"
    t.index ["project_id", "environment_id", "updated_at", "id"], name: "index_deployments_on_project_and_environment_and_updated_at_id"
    t.index ["project_id", "finished_at"], name: "index_deployments_on_project_and_finished", where: "(status = 2)"
    t.index ["project_id", "id"], name: "index_deployments_on_project_id_and_id", order: { id: :desc }
    t.index ["project_id", "iid"], name: "index_deployments_on_project_id_and_iid", unique: true
    t.index ["project_id", "ref"], name: "index_deployments_on_project_id_and_ref"
    t.index ["project_id", "sha"], name: "index_deployments_on_project_id_sha"
    t.index ["project_id", "status", "created_at"], name: "index_deployments_on_project_id_and_status_and_created_at"
    t.index ["project_id", "status"], name: "index_deployments_on_project_id_and_status"
    t.index ["project_id", "updated_at", "id"], name: "index_deployments_on_project_id_and_updated_at_and_id", order: { updated_at: :desc, id: :desc }
    t.index ["project_id"], name: "partial_index_deployments_for_project_id_and_tag", where: "(tag IS TRUE)"
    t.index ["user_id", "status", "created_at"], name: "index_deployments_on_user_id_and_status_and_created_at"
  end

  create_table "description_versions", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "issue_id"
    t.integer "merge_request_id"
    t.integer "epic_id"
    t.text "description"
    t.datetime_with_timezone "deleted_at"
    t.index ["epic_id"], name: "index_description_versions_on_epic_id", where: "(epic_id IS NOT NULL)"
    t.index ["issue_id"], name: "index_description_versions_on_issue_id", where: "(issue_id IS NOT NULL)"
    t.index ["merge_request_id"], name: "index_description_versions_on_merge_request_id", where: "(merge_request_id IS NOT NULL)"
  end

  create_table "design_management_designs", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "issue_id"
    t.string "filename", null: false
    t.integer "relative_position"
    t.integer "iid"
    t.index ["issue_id", "filename"], name: "index_design_management_designs_on_issue_id_and_filename", unique: true
    t.index ["issue_id", "relative_position", "id"], name: "index_design_management_designs_issue_id_relative_position_id"
    t.index ["project_id", "iid"], name: "index_design_management_designs_on_iid_and_project_id", unique: true
    t.index ["project_id"], name: "index_design_management_designs_on_project_id"
    t.check_constraint "char_length((filename)::text) <= 255", name: "check_07155e2715"
    t.check_constraint "iid IS NOT NULL", name: "check_cfb92df01a"
  end

  create_table "design_management_designs_versions", force: :cascade do |t|
    t.bigint "design_id", null: false
    t.bigint "version_id", null: false
    t.integer "event", limit: 2, default: 0, null: false
    t.string "image_v432x230", limit: 255
    t.index ["design_id", "version_id"], name: "design_management_designs_versions_uniqueness", unique: true
    t.index ["design_id"], name: "index_design_management_designs_versions_on_design_id"
    t.index ["event"], name: "index_design_management_designs_versions_on_event"
    t.index ["version_id"], name: "index_design_management_designs_versions_on_version_id"
  end

  create_table "design_management_versions", force: :cascade do |t|
    t.binary "sha", null: false
    t.bigint "issue_id"
    t.datetime_with_timezone "created_at", null: false
    t.integer "author_id"
    t.index ["author_id"], name: "index_design_management_versions_on_author_id", where: "(author_id IS NOT NULL)"
    t.index ["issue_id"], name: "index_design_management_versions_on_issue_id"
    t.index ["sha", "issue_id"], name: "index_design_management_versions_on_sha_and_issue_id", unique: true
  end

  create_table "design_user_mentions", force: :cascade do |t|
    t.integer "design_id", null: false
    t.integer "note_id", null: false
    t.integer "mentioned_users_ids", array: true
    t.integer "mentioned_projects_ids", array: true
    t.integer "mentioned_groups_ids", array: true
    t.index ["design_id", "note_id"], name: "design_user_mentions_on_design_id_and_note_id_unique_index", unique: true
    t.index ["note_id"], name: "index_design_user_mentions_on_note_id", unique: true
  end

  create_table "detached_partitions", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "drop_after", null: false
    t.text "table_name", null: false
    t.check_constraint "char_length(table_name) <= 63", name: "check_aecee24ba3"
  end

  create_table "diff_note_positions", force: :cascade do |t|
    t.bigint "note_id", null: false
    t.integer "old_line"
    t.integer "new_line"
    t.integer "diff_content_type", limit: 2, null: false
    t.integer "diff_type", limit: 2, null: false
    t.string "line_code", limit: 255, null: false
    t.binary "base_sha", null: false
    t.binary "start_sha", null: false
    t.binary "head_sha", null: false
    t.text "old_path", null: false
    t.text "new_path", null: false
    t.index ["note_id", "diff_type"], name: "index_diff_note_positions_on_note_id_and_diff_type", unique: true
  end

  create_table "dingtalk_tracker_data", comment: "JiHu-specific table", force: :cascade do |t|
    t.bigint "integration_id", null: false, comment: "JiHu-specific column"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "corpid", comment: "JiHu-specific column"
    t.index ["corpid"], name: "index_on_dingtalk_tracker_data_corpid", where: "(corpid IS NOT NULL)", comment: "JiHu-specific index"
    t.index ["integration_id"], name: "index_dingtalk_tracker_data_on_integration_id"
    t.check_constraint "char_length(corpid) <= 255", name: "check_d3fe332e6a"
  end

  create_table "dora_configurations", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.text "branches_for_lead_time_for_changes", default: [], null: false, array: true
    t.index ["project_id"], name: "index_dora_configurations_on_project_id", unique: true
  end

  create_table "dora_daily_metrics", force: :cascade do |t|
    t.bigint "environment_id", null: false
    t.date "date", null: false
    t.integer "deployment_frequency"
    t.integer "lead_time_for_changes_in_seconds"
    t.integer "time_to_restore_service_in_seconds"
    t.integer "incidents_count"
    t.index ["environment_id", "date"], name: "index_dora_daily_metrics_on_environment_id_and_date", unique: true
    t.check_constraint "deployment_frequency >= 0", name: "dora_daily_metrics_deployment_frequency_positive"
    t.check_constraint "lead_time_for_changes_in_seconds >= 0", name: "dora_daily_metrics_lead_time_for_changes_in_seconds_positive"
  end

  create_table "draft_notes", force: :cascade do |t|
    t.integer "merge_request_id", null: false
    t.integer "author_id", null: false
    t.boolean "resolve_discussion", default: false, null: false
    t.string "discussion_id"
    t.text "note", null: false
    t.text "position"
    t.text "original_position"
    t.text "change_position"
    t.binary "commit_id"
    t.text "line_code"
    t.index ["author_id"], name: "index_draft_notes_on_author_id"
    t.index ["discussion_id"], name: "index_draft_notes_on_discussion_id"
    t.index ["merge_request_id"], name: "index_draft_notes_on_merge_request_id"
    t.check_constraint "char_length(line_code) <= 255", name: "check_c497a94a0e"
  end

  create_table "elastic_index_settings", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "number_of_replicas", limit: 2, default: 1, null: false
    t.integer "number_of_shards", limit: 2, default: 5, null: false
    t.text "alias_name", null: false
    t.index ["alias_name"], name: "index_elastic_index_settings_on_alias_name", unique: true
    t.check_constraint "char_length(alias_name) <= 255", name: "check_c30005c325"
  end

  create_table "elastic_reindexing_slices", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "elastic_reindexing_subtask_id", null: false
    t.integer "elastic_slice", limit: 2, default: 0, null: false
    t.integer "elastic_max_slice", limit: 2, default: 0, null: false
    t.integer "retry_attempt", limit: 2, default: 0, null: false
    t.text "elastic_task"
    t.index ["elastic_reindexing_subtask_id"], name: "idx_elastic_reindexing_slices_on_elastic_reindexing_subtask_id"
    t.check_constraint "char_length(elastic_task) <= 255", name: "check_ca30e1396e"
  end

  create_table "elastic_reindexing_subtasks", force: :cascade do |t|
    t.bigint "elastic_reindexing_task_id", null: false
    t.text "alias_name", null: false
    t.text "index_name_from", null: false
    t.text "index_name_to", null: false
    t.text "elastic_task"
    t.integer "documents_count_target"
    t.integer "documents_count"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["elastic_reindexing_task_id"], name: "index_elastic_reindexing_subtasks_on_elastic_reindexing_task_id"
    t.check_constraint "char_length(alias_name) <= 255", name: "check_88f56216a4"
    t.check_constraint "char_length(elastic_task) <= 255", name: "check_4910adc798"
    t.check_constraint "char_length(index_name_from) <= 255", name: "check_a1fbd9faa9"
    t.check_constraint "char_length(index_name_to) <= 255", name: "check_f456494bd8"
  end

  create_table "elastic_reindexing_tasks", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "state", limit: 2, default: 0, null: false
    t.boolean "in_progress", default: true, null: false
    t.text "error_message"
    t.datetime_with_timezone "delete_original_index_at"
    t.integer "max_slices_running", limit: 2, default: 60, null: false
    t.integer "slice_multiplier", limit: 2, default: 2, null: false
    t.text "targets", array: true
    t.index ["in_progress"], name: "index_elastic_reindexing_tasks_on_in_progress", unique: true, where: "in_progress"
    t.index ["state"], name: "index_elastic_reindexing_tasks_on_state"
    t.check_constraint "char_length(error_message) <= 255", name: "check_7f64acda8e"
  end

  create_table "elasticsearch_indexed_namespaces", primary_key: "namespace_id", id: :integer, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["created_at"], name: "index_elasticsearch_indexed_namespaces_on_created_at"
  end

  create_table "elasticsearch_indexed_projects", primary_key: "project_id", id: :integer, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
  end

  create_table "emails", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "email", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_emails_on_confirmation_token", unique: true
    t.index ["email"], name: "index_emails_on_email", unique: true
    t.index ["user_id"], name: "index_emails_on_user_id"
  end

  create_table "environments", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "external_url"
    t.string "environment_type"
    t.string "state", default: "available", null: false
    t.string "slug", null: false
    t.datetime_with_timezone "auto_stop_at"
    t.datetime_with_timezone "auto_delete_at"
    t.integer "tier", limit: 2
    t.bigint "merge_request_id"
    t.index "project_id, lower((name)::text) varchar_pattern_ops, state", name: "index_environments_on_project_name_varchar_pattern_ops_state"
    t.index "project_id, lower(ltrim((name)::text, ((environment_type)::text || '/'::text))) varchar_pattern_ops, state", name: "index_environments_for_name_search_within_folder"
    t.index ["auto_delete_at"], name: "index_environments_on_state_and_auto_delete_at", where: "((auto_delete_at IS NOT NULL) AND ((state)::text = 'stopped'::text))"
    t.index ["merge_request_id"], name: "index_environments_on_merge_request_id"
    t.index ["name"], name: "index_environments_on_name_varchar_pattern_ops", opclass: :varchar_pattern_ops
    t.index ["project_id", "name"], name: "index_environments_on_project_id_and_name", unique: true
    t.index ["project_id", "slug"], name: "index_environments_on_project_id_and_slug", unique: true
    t.index ["project_id", "state", "environment_type"], name: "index_environments_on_project_id_state_environment_type"
    t.index ["project_id", "tier"], name: "index_environments_on_project_id_and_tier", where: "(tier IS NOT NULL)"
    t.index ["state", "auto_stop_at"], name: "index_environments_on_state_and_auto_stop_at", where: "((auto_stop_at IS NOT NULL) AND ((state)::text = 'available'::text))"
  end

  create_table "epic_issues", id: :serial, force: :cascade do |t|
    t.integer "epic_id", null: false
    t.integer "issue_id", null: false
    t.integer "relative_position"
    t.index ["epic_id", "issue_id"], name: "index_epic_issues_on_epic_id_and_issue_id"
    t.index ["issue_id"], name: "index_epic_issues_on_issue_id", unique: true
  end

  create_table "epic_metrics", id: :serial, force: :cascade do |t|
    t.integer "epic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epic_id"], name: "index_epic_metrics"
  end

  create_table "epic_user_mentions", force: :cascade do |t|
    t.integer "epic_id", null: false
    t.integer "note_id"
    t.integer "mentioned_users_ids", array: true
    t.integer "mentioned_projects_ids", array: true
    t.integer "mentioned_groups_ids", array: true
    t.index ["epic_id", "note_id"], name: "epic_user_mentions_on_epic_id_and_note_id_index", unique: true
    t.index ["epic_id"], name: "epic_user_mentions_on_epic_id_index", unique: true, where: "(note_id IS NULL)"
    t.index ["note_id"], name: "index_epic_user_mentions_on_note_id", unique: true, where: "(note_id IS NOT NULL)"
  end

  create_table "epics", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "author_id", null: false
    t.integer "assignee_id"
    t.integer "iid", null: false
    t.integer "cached_markdown_version"
    t.integer "updated_by_id"
    t.integer "last_edited_by_id"
    t.integer "lock_version", default: 0
    t.date "start_date"
    t.date "end_date"
    t.datetime "last_edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", null: false
    t.string "title_html", null: false
    t.text "description"
    t.text "description_html"
    t.integer "start_date_sourcing_milestone_id"
    t.integer "due_date_sourcing_milestone_id"
    t.date "start_date_fixed"
    t.date "due_date_fixed"
    t.boolean "start_date_is_fixed"
    t.boolean "due_date_is_fixed"
    t.integer "closed_by_id"
    t.datetime "closed_at"
    t.integer "parent_id"
    t.integer "relative_position"
    t.integer "state_id", limit: 2, default: 1, null: false
    t.integer "start_date_sourcing_epic_id"
    t.integer "due_date_sourcing_epic_id"
    t.boolean "confidential", default: false, null: false
    t.string "external_key", limit: 255
    t.text "color", default: "#1068bf"
    t.integer "total_opened_issue_weight", default: 0, null: false
    t.integer "total_closed_issue_weight", default: 0, null: false
    t.integer "total_opened_issue_count", default: 0, null: false
    t.integer "total_closed_issue_count", default: 0, null: false
    t.index "group_id, ((iid)::character varying) varchar_pattern_ops", name: "index_epics_on_group_id_and_iid_varchar_pattern"
    t.index ["assignee_id"], name: "index_epics_on_assignee_id"
    t.index ["author_id"], name: "index_epics_on_author_id"
    t.index ["closed_by_id"], name: "index_epics_on_closed_by_id"
    t.index ["confidential"], name: "index_epics_on_confidential"
    t.index ["due_date_sourcing_epic_id"], name: "index_epics_on_due_date_sourcing_epic_id", where: "(due_date_sourcing_epic_id IS NOT NULL)"
    t.index ["due_date_sourcing_milestone_id"], name: "index_epics_on_due_date_sourcing_milestone_id"
    t.index ["end_date"], name: "index_epics_on_end_date"
    t.index ["group_id", "external_key"], name: "index_epics_on_group_id_and_external_key", unique: true, where: "(external_key IS NOT NULL)"
    t.index ["group_id", "iid"], name: "index_epics_on_group_id_and_iid", unique: true
    t.index ["iid"], name: "index_epics_on_iid"
    t.index ["last_edited_by_id"], name: "index_epics_on_last_edited_by_id"
    t.index ["parent_id"], name: "index_epics_on_parent_id"
    t.index ["start_date"], name: "index_epics_on_start_date"
    t.index ["start_date_sourcing_epic_id"], name: "index_epics_on_start_date_sourcing_epic_id", where: "(start_date_sourcing_epic_id IS NOT NULL)"
    t.index ["start_date_sourcing_milestone_id"], name: "index_epics_on_start_date_sourcing_milestone_id"
    t.check_constraint "char_length(color) <= 7", name: "check_ca608c40b3"
    t.check_constraint "lock_version IS NOT NULL", name: "check_fcfb4a93ff"
  end

  create_table "error_tracking_client_keys", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.boolean "active", default: true, null: false
    t.text "public_key", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["project_id", "public_key"], name: "index_error_tracking_client_for_enabled_check", where: "(active = true)"
    t.index ["project_id"], name: "index_error_tracking_client_keys_on_project_id"
    t.check_constraint "char_length(public_key) <= 255", name: "check_840b719790"
  end

  create_table "error_tracking_error_events", force: :cascade do |t|
    t.bigint "error_id", null: false
    t.text "description", null: false
    t.text "environment"
    t.text "level"
    t.datetime_with_timezone "occurred_at", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["error_id"], name: "index_error_tracking_error_events_on_error_id"
    t.check_constraint "char_length(description) <= 1024", name: "check_92ecc3077b"
    t.check_constraint "char_length(environment) <= 255", name: "check_f4b52474ad"
    t.check_constraint "char_length(level) <= 255", name: "check_c67d5b8007"
  end

  create_table "error_tracking_errors", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.text "name", null: false
    t.text "description", null: false
    t.text "actor", null: false
    t.datetime_with_timezone "first_seen_at", default: -> { "now()" }, null: false
    t.datetime_with_timezone "last_seen_at", default: -> { "now()" }, null: false
    t.text "platform"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "events_count", default: 0, null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["project_id", "status", "events_count", "id"], name: "index_et_errors_on_project_id_and_status_events_count_id_desc", order: { events_count: :desc, id: :desc }
    t.index ["project_id", "status", "first_seen_at", "id"], name: "index_et_errors_on_project_id_and_status_first_seen_at_id_desc", order: { first_seen_at: :desc, id: :desc }
    t.index ["project_id", "status", "id"], name: "index_et_errors_on_project_id_and_status_and_id"
    t.index ["project_id", "status", "last_seen_at", "id"], name: "index_et_errors_on_project_id_and_status_last_seen_at_id_desc", order: { last_seen_at: :desc, id: :desc }
    t.index ["project_id"], name: "index_error_tracking_errors_on_project_id"
    t.check_constraint "char_length(actor) <= 255", name: "check_b5cb4d3888"
    t.check_constraint "char_length(description) <= 1024", name: "check_c739788b12"
    t.check_constraint "char_length(name) <= 255", name: "check_18a758e537"
    t.check_constraint "char_length(platform) <= 255", name: "check_fe99886883"
  end

  create_table "events", force: :cascade do |t|
    t.integer "project_id"
    t.integer "author_id", null: false
    t.integer "target_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "action", limit: 2, null: false
    t.string "target_type"
    t.bigint "group_id"
    t.binary "fingerprint"
    t.index ["action"], name: "index_events_on_action"
    t.index ["author_id", "created_at"], name: "index_events_on_author_id_and_created_at"
    t.index ["author_id", "created_at"], name: "index_events_on_author_id_and_created_at_merge_requests", where: "((target_type)::text = 'MergeRequest'::text)"
    t.index ["author_id", "id"], name: "index_events_on_author_id_and_id"
    t.index ["author_id", "project_id", "action", "target_type", "created_at"], name: "index_events_author_id_project_id_action_target_type_created_at"
    t.index ["created_at", "author_id"], name: "analytics_index_events_on_created_at_and_author_id"
    t.index ["created_at", "id"], name: "index_events_on_created_at_and_id", where: "(created_at > '2021-08-27 00:00:00+00'::timestamp with time zone)"
    t.index ["group_id"], name: "index_events_on_group_id_partial", where: "(group_id IS NOT NULL)"
    t.index ["project_id", "created_at"], name: "index_events_on_project_id_and_created_at"
    t.index ["project_id", "id"], name: "index_events_on_project_id_and_id"
    t.index ["project_id", "id"], name: "index_events_on_project_id_and_id_desc_on_merged_action", order: { id: :desc }, where: "(action = 7)"
    t.index ["project_id", "target_type", "action", "created_at", "author_id", "id"], name: "index_on_events_to_improve_contribution_analytics_performance"
    t.index ["target_type", "target_id", "fingerprint"], name: "index_events_on_target_type_and_target_id_and_fingerprint", unique: true
    t.check_constraint "octet_length(fingerprint) <= 128", name: "check_97e06e05ad"
  end

  create_table "evidences", force: :cascade do |t|
    t.bigint "release_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.binary "summary_sha"
    t.jsonb "summary", default: {}, null: false
    t.index ["release_id"], name: "index_evidences_on_release_id"
  end

  create_table "external_approval_rules", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "external_url", null: false
    t.text "name", null: false
    t.index ["project_id", "external_url"], name: "idx_on_external_approval_rules_project_id_external_url", unique: true
    t.index ["project_id", "name"], name: "idx_on_external_approval_rules_project_id_name", unique: true
    t.check_constraint "char_length(external_url) <= 255", name: "check_b634ca168d"
    t.check_constraint "char_length(name) <= 255", name: "check_1c64b53ea5"
  end

  create_table "external_approval_rules_protected_branches", force: :cascade do |t|
    t.bigint "external_approval_rule_id", null: false
    t.bigint "protected_branch_id", null: false
    t.index ["external_approval_rule_id"], name: "idx_eaprpb_external_approval_rule_id"
    t.index ["protected_branch_id", "external_approval_rule_id"], name: "idx_protected_branch_id_external_approval_rule_id", unique: true
  end

  create_table "external_pull_requests", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.integer "pull_request_iid", null: false
    t.integer "status", limit: 2, null: false
    t.string "source_branch", limit: 255, null: false
    t.string "target_branch", limit: 255, null: false
    t.string "source_repository", limit: 255, null: false
    t.string "target_repository", limit: 255, null: false
    t.binary "source_sha", null: false
    t.binary "target_sha", null: false
    t.index ["project_id", "source_branch", "target_branch"], name: "index_external_pull_requests_on_project_and_branches", unique: true
  end

  create_table "external_status_checks", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "external_url", null: false
    t.text "name", null: false
    t.index ["project_id", "external_url"], name: "idx_on_external_status_checks_project_id_external_url", unique: true
    t.index ["project_id", "name"], name: "idx_on_external_status_checks_project_id_name", unique: true
    t.check_constraint "char_length(external_url) <= 255", name: "check_ae0dec3f61"
    t.check_constraint "char_length(name) <= 255", name: "check_7e3b9eb41a"
  end

  create_table "external_status_checks_protected_branches", force: :cascade do |t|
    t.bigint "external_status_check_id", null: false
    t.bigint "protected_branch_id", null: false
    t.index ["external_status_check_id"], name: "index_esc_protected_branches_on_external_status_check_id"
    t.index ["protected_branch_id"], name: "index_esc_protected_branches_on_protected_branch_id"
  end

  create_table "feature_gates", id: :serial, force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_feature_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "features", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_features_on_key", unique: true
  end

  create_table "fork_network_members", id: :serial, force: :cascade do |t|
    t.integer "fork_network_id", null: false
    t.integer "project_id", null: false
    t.integer "forked_from_project_id"
    t.index ["fork_network_id"], name: "index_fork_network_members_on_fork_network_id"
    t.index ["forked_from_project_id"], name: "index_fork_network_members_on_forked_from_project_id"
    t.index ["project_id"], name: "index_fork_network_members_on_project_id", unique: true
  end

  create_table "fork_networks", id: :serial, force: :cascade do |t|
    t.integer "root_project_id"
    t.string "deleted_root_project_name"
    t.index ["root_project_id"], name: "index_fork_networks_on_root_project_id", unique: true
  end

  create_table "geo_cache_invalidation_events", force: :cascade do |t|
    t.string "key", null: false
  end

  create_table "geo_container_repository_updated_events", force: :cascade do |t|
    t.integer "container_repository_id", null: false
    t.index ["container_repository_id"], name: "idx_geo_con_rep_updated_events_on_container_repository_id"
  end

  create_table "geo_event_log", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "repository_updated_event_id"
    t.bigint "repository_deleted_event_id"
    t.bigint "repository_renamed_event_id"
    t.bigint "repositories_changed_event_id"
    t.bigint "repository_created_event_id"
    t.bigint "hashed_storage_migrated_event_id"
    t.bigint "hashed_storage_attachments_event_id"
    t.bigint "reset_checksum_event_id"
    t.bigint "cache_invalidation_event_id"
    t.bigint "container_repository_updated_event_id"
    t.integer "geo_event_id"
    t.index ["cache_invalidation_event_id"], name: "index_geo_event_log_on_cache_invalidation_event_id", where: "(cache_invalidation_event_id IS NOT NULL)"
    t.index ["container_repository_updated_event_id"], name: "index_geo_event_log_on_container_repository_updated_event_id"
    t.index ["geo_event_id"], name: "index_geo_event_log_on_geo_event_id", where: "(geo_event_id IS NOT NULL)"
    t.index ["hashed_storage_attachments_event_id"], name: "index_geo_event_log_on_hashed_storage_attachments_event_id", where: "(hashed_storage_attachments_event_id IS NOT NULL)"
    t.index ["hashed_storage_migrated_event_id"], name: "index_geo_event_log_on_hashed_storage_migrated_event_id", where: "(hashed_storage_migrated_event_id IS NOT NULL)"
    t.index ["repositories_changed_event_id"], name: "index_geo_event_log_on_repositories_changed_event_id", where: "(repositories_changed_event_id IS NOT NULL)"
    t.index ["repository_created_event_id"], name: "index_geo_event_log_on_repository_created_event_id", where: "(repository_created_event_id IS NOT NULL)"
    t.index ["repository_deleted_event_id"], name: "index_geo_event_log_on_repository_deleted_event_id", where: "(repository_deleted_event_id IS NOT NULL)"
    t.index ["repository_renamed_event_id"], name: "index_geo_event_log_on_repository_renamed_event_id", where: "(repository_renamed_event_id IS NOT NULL)"
    t.index ["repository_updated_event_id"], name: "index_geo_event_log_on_repository_updated_event_id", where: "(repository_updated_event_id IS NOT NULL)"
    t.index ["reset_checksum_event_id"], name: "index_geo_event_log_on_reset_checksum_event_id", where: "(reset_checksum_event_id IS NOT NULL)"
  end

  create_table "geo_events", force: :cascade do |t|
    t.string "replicable_name", limit: 255, null: false
    t.string "event_name", limit: 255, null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime_with_timezone "created_at", null: false
  end

  create_table "geo_hashed_storage_attachments_events", force: :cascade do |t|
    t.integer "project_id", null: false
    t.text "old_attachments_path", null: false
    t.text "new_attachments_path", null: false
    t.index ["project_id"], name: "index_geo_hashed_storage_attachments_events_on_project_id"
  end

  create_table "geo_hashed_storage_migrated_events", force: :cascade do |t|
    t.integer "project_id", null: false
    t.text "repository_storage_name", null: false
    t.text "old_disk_path", null: false
    t.text "new_disk_path", null: false
    t.text "old_wiki_disk_path", null: false
    t.text "new_wiki_disk_path", null: false
    t.integer "old_storage_version", limit: 2
    t.integer "new_storage_version", limit: 2, null: false
    t.text "old_design_disk_path"
    t.text "new_design_disk_path"
    t.index ["project_id"], name: "index_geo_hashed_storage_migrated_events_on_project_id"
  end

  create_table "geo_node_namespace_links", id: :serial, force: :cascade do |t|
    t.integer "geo_node_id", null: false
    t.integer "namespace_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geo_node_id", "namespace_id"], name: "index_geo_node_namespace_links_on_geo_node_id_and_namespace_id", unique: true
    t.index ["geo_node_id"], name: "index_geo_node_namespace_links_on_geo_node_id"
    t.index ["namespace_id"], name: "index_geo_node_namespace_links_on_namespace_id"
  end

  create_table "geo_node_statuses", id: :serial, force: :cascade do |t|
    t.integer "geo_node_id", null: false
    t.integer "db_replication_lag_seconds"
    t.integer "repositories_synced_count"
    t.integer "repositories_failed_count"
    t.integer "lfs_objects_count"
    t.integer "lfs_objects_synced_count"
    t.integer "lfs_objects_failed_count"
    t.integer "last_event_id"
    t.datetime "last_event_date"
    t.integer "cursor_last_event_id"
    t.datetime "cursor_last_event_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_successful_status_check_at"
    t.string "status_message"
    t.integer "replication_slots_count"
    t.integer "replication_slots_used_count"
    t.bigint "replication_slots_max_retained_wal_bytes"
    t.integer "wikis_synced_count"
    t.integer "wikis_failed_count"
    t.integer "job_artifacts_count"
    t.integer "job_artifacts_synced_count"
    t.integer "job_artifacts_failed_count"
    t.string "version"
    t.string "revision"
    t.integer "repositories_verified_count"
    t.integer "repositories_verification_failed_count"
    t.integer "wikis_verified_count"
    t.integer "wikis_verification_failed_count"
    t.integer "lfs_objects_synced_missing_on_primary_count"
    t.integer "job_artifacts_synced_missing_on_primary_count"
    t.integer "repositories_checksummed_count"
    t.integer "repositories_checksum_failed_count"
    t.integer "repositories_checksum_mismatch_count"
    t.integer "wikis_checksummed_count"
    t.integer "wikis_checksum_failed_count"
    t.integer "wikis_checksum_mismatch_count"
    t.binary "storage_configuration_digest"
    t.integer "repositories_retrying_verification_count"
    t.integer "wikis_retrying_verification_count"
    t.integer "projects_count"
    t.integer "container_repositories_count"
    t.integer "container_repositories_synced_count"
    t.integer "container_repositories_failed_count"
    t.integer "container_repositories_registry_count"
    t.integer "design_repositories_count"
    t.integer "design_repositories_synced_count"
    t.integer "design_repositories_failed_count"
    t.integer "design_repositories_registry_count"
    t.jsonb "status", default: {}, null: false
    t.index ["geo_node_id"], name: "index_geo_node_statuses_on_geo_node_id", unique: true
  end

  create_table "geo_nodes", id: :serial, force: :cascade do |t|
    t.boolean "primary", default: false, null: false
    t.integer "oauth_application_id"
    t.boolean "enabled", default: true, null: false
    t.string "access_key"
    t.string "encrypted_secret_access_key"
    t.string "encrypted_secret_access_key_iv"
    t.string "clone_url_prefix"
    t.integer "files_max_capacity", default: 10, null: false
    t.integer "repos_max_capacity", default: 25, null: false
    t.string "url", null: false
    t.string "selective_sync_type"
    t.text "selective_sync_shards"
    t.integer "verification_max_capacity", default: 100, null: false
    t.integer "minimum_reverification_interval", default: 7, null: false
    t.string "internal_url"
    t.string "name", null: false
    t.integer "container_repositories_max_capacity", default: 10, null: false
    t.datetime_with_timezone "created_at"
    t.datetime_with_timezone "updated_at"
    t.boolean "sync_object_storage", default: false, null: false
    t.index ["access_key"], name: "index_geo_nodes_on_access_key"
    t.index ["name"], name: "index_geo_nodes_on_name", unique: true
    t.index ["primary"], name: "index_geo_nodes_on_primary"
  end

  create_table "geo_repositories_changed_events", force: :cascade do |t|
    t.integer "geo_node_id", null: false
    t.index ["geo_node_id"], name: "index_geo_repositories_changed_events_on_geo_node_id"
  end

  create_table "geo_repository_created_events", force: :cascade do |t|
    t.integer "project_id", null: false
    t.text "repository_storage_name", null: false
    t.text "repo_path", null: false
    t.text "wiki_path"
    t.text "project_name", null: false
    t.index ["project_id"], name: "index_geo_repository_created_events_on_project_id"
  end

  create_table "geo_repository_deleted_events", force: :cascade do |t|
    t.integer "project_id", null: false
    t.text "repository_storage_name", null: false
    t.text "deleted_path", null: false
    t.text "deleted_wiki_path"
    t.text "deleted_project_name", null: false
    t.index ["project_id"], name: "index_geo_repository_deleted_events_on_project_id"
  end

  create_table "geo_repository_renamed_events", force: :cascade do |t|
    t.integer "project_id", null: false
    t.text "repository_storage_name", null: false
    t.text "old_path_with_namespace", null: false
    t.text "new_path_with_namespace", null: false
    t.text "old_wiki_path_with_namespace", null: false
    t.text "new_wiki_path_with_namespace", null: false
    t.text "old_path", null: false
    t.text "new_path", null: false
    t.index ["project_id"], name: "index_geo_repository_renamed_events_on_project_id"
  end

  create_table "geo_repository_updated_events", force: :cascade do |t|
    t.integer "branches_affected", null: false
    t.integer "tags_affected", null: false
    t.integer "project_id", null: false
    t.integer "source", limit: 2, null: false
    t.boolean "new_branch", default: false, null: false
    t.boolean "remove_branch", default: false, null: false
    t.text "ref"
    t.index ["project_id"], name: "index_geo_repository_updated_events_on_project_id"
    t.index ["source"], name: "index_geo_repository_updated_events_on_source"
  end

  create_table "geo_reset_checksum_events", force: :cascade do |t|
    t.integer "project_id", null: false
    t.index ["project_id"], name: "index_geo_reset_checksum_events_on_project_id"
  end

  create_table "ghost_user_migrations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "initiator_user_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "hard_delete", default: false, null: false
    t.datetime_with_timezone "consume_after", default: -> { "now()" }, null: false
    t.index ["consume_after", "id"], name: "index_ghost_user_migrations_on_consume_after_id"
    t.index ["user_id"], name: "index_ghost_user_migrations_on_user_id", unique: true
  end

  create_table "gitlab_subscription_histories", force: :cascade do |t|
    t.datetime_with_timezone "gitlab_subscription_created_at"
    t.datetime_with_timezone "gitlab_subscription_updated_at"
    t.date "start_date"
    t.date "end_date"
    t.date "trial_ends_on"
    t.integer "namespace_id"
    t.integer "hosted_plan_id"
    t.integer "max_seats_used"
    t.integer "seats"
    t.boolean "trial"
    t.integer "change_type", limit: 2
    t.bigint "gitlab_subscription_id", null: false
    t.datetime_with_timezone "created_at"
    t.date "trial_starts_on"
    t.boolean "auto_renew"
    t.integer "trial_extension_type", limit: 2
    t.index ["gitlab_subscription_id"], name: "index_gitlab_subscription_histories_on_gitlab_subscription_id"
  end

  create_table "gitlab_subscriptions", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.date "start_date"
    t.date "end_date"
    t.date "trial_ends_on"
    t.integer "namespace_id"
    t.integer "hosted_plan_id"
    t.integer "max_seats_used", default: 0
    t.integer "seats", default: 0
    t.boolean "trial", default: false
    t.date "trial_starts_on"
    t.boolean "auto_renew"
    t.integer "seats_in_use", default: 0, null: false
    t.integer "seats_owed", default: 0, null: false
    t.integer "trial_extension_type", limit: 2
    t.datetime_with_timezone "max_seats_used_changed_at"
    t.datetime_with_timezone "last_seat_refresh_at"
    t.index ["end_date", "namespace_id"], name: "index_gitlab_subscriptions_on_end_date_and_namespace_id"
    t.index ["hosted_plan_id"], name: "index_gitlab_subscriptions_on_hosted_plan_id"
    t.index ["max_seats_used_changed_at", "namespace_id"], name: "index_gitlab_subscriptions_on_max_seats_used_changed_at"
    t.index ["namespace_id"], name: "index_gitlab_subscriptions_on_namespace_id", unique: true
    t.check_constraint "namespace_id IS NOT NULL", name: "check_77fea3f0e7"
  end

  create_table "gpg_key_subkeys", id: :serial, force: :cascade do |t|
    t.integer "gpg_key_id", null: false
    t.binary "keyid"
    t.binary "fingerprint"
    t.index ["fingerprint"], name: "index_gpg_key_subkeys_on_fingerprint", unique: true
    t.index ["gpg_key_id"], name: "index_gpg_key_subkeys_on_gpg_key_id"
    t.index ["keyid"], name: "index_gpg_key_subkeys_on_keyid", unique: true
  end

  create_table "gpg_keys", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "user_id"
    t.binary "primary_keyid"
    t.binary "fingerprint"
    t.text "key"
    t.index ["fingerprint"], name: "index_gpg_keys_on_fingerprint", unique: true
    t.index ["primary_keyid"], name: "index_gpg_keys_on_primary_keyid", unique: true
    t.index ["user_id"], name: "index_gpg_keys_on_user_id"
  end

  create_table "gpg_signatures", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "project_id"
    t.integer "gpg_key_id"
    t.binary "commit_sha"
    t.binary "gpg_key_primary_keyid"
    t.text "gpg_key_user_name"
    t.text "gpg_key_user_email"
    t.integer "verification_status", limit: 2, default: 0, null: false
    t.integer "gpg_key_subkey_id"
    t.index ["commit_sha"], name: "index_gpg_signatures_on_commit_sha", unique: true
    t.index ["gpg_key_id"], name: "index_gpg_signatures_on_gpg_key_id"
    t.index ["gpg_key_primary_keyid"], name: "index_gpg_signatures_on_gpg_key_primary_keyid"
    t.index ["gpg_key_subkey_id"], name: "index_gpg_signatures_on_gpg_key_subkey_id"
    t.index ["project_id"], name: "index_gpg_signatures_on_project_id"
  end

  create_table "grafana_integrations", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "encrypted_token", limit: 255, null: false
    t.string "encrypted_token_iv", limit: 255, null: false
    t.string "grafana_url", limit: 1024, null: false
    t.boolean "enabled", default: false, null: false
    t.index ["enabled"], name: "index_grafana_integrations_on_enabled", where: "(enabled IS TRUE)"
    t.index ["project_id"], name: "index_grafana_integrations_on_project_id"
  end

  create_table "group_crm_settings", primary_key: "group_id", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "enabled", default: false, null: false
    t.index ["group_id"], name: "index_group_crm_settings_on_group_id"
  end

  create_table "group_custom_attributes", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "group_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.index ["group_id", "key"], name: "index_group_custom_attributes_on_group_id_and_key", unique: true
    t.index ["key", "value"], name: "index_group_custom_attributes_on_key_and_value"
  end

  create_table "group_deletion_schedules", primary_key: "group_id", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "marked_for_deletion_on", null: false
    t.index ["marked_for_deletion_on"], name: "index_group_deletion_schedules_on_marked_for_deletion_on"
    t.index ["user_id"], name: "index_group_deletion_schedules_on_user_id"
  end

  create_table "group_deploy_keys", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "last_used_at"
    t.datetime_with_timezone "expires_at"
    t.text "key", null: false
    t.text "title"
    t.text "fingerprint"
    t.binary "fingerprint_sha256"
    t.index ["fingerprint"], name: "index_group_deploy_keys_on_fingerprint"
    t.index ["fingerprint_sha256"], name: "index_group_deploy_keys_on_fingerprint_sha256_unique", unique: true
    t.index ["user_id"], name: "index_group_deploy_keys_on_user_id"
    t.check_constraint "char_length(fingerprint) <= 255", name: "check_e4526dcf91"
    t.check_constraint "char_length(key) <= 4096", name: "check_f58fa0a0f7"
    t.check_constraint "char_length(title) <= 255", name: "check_cc0365908d"
  end

  create_table "group_deploy_keys_groups", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "group_id", null: false
    t.bigint "group_deploy_key_id", null: false
    t.boolean "can_push", default: false, null: false
    t.index ["group_deploy_key_id"], name: "index_group_deploy_keys_groups_on_group_deploy_key_id"
    t.index ["group_id", "group_deploy_key_id"], name: "index_group_deploy_keys_group_on_group_deploy_key_and_group_ids", unique: true
  end

  create_table "group_deploy_tokens", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "group_id", null: false
    t.bigint "deploy_token_id", null: false
    t.index ["deploy_token_id"], name: "index_group_deploy_tokens_on_deploy_token_id"
    t.index ["group_id", "deploy_token_id"], name: "index_group_deploy_tokens_on_group_and_deploy_token_ids", unique: true
  end

  create_table "group_features", primary_key: "group_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "wiki_access_level", limit: 2, default: 20, null: false
  end

  create_table "group_group_links", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "shared_group_id", null: false
    t.bigint "shared_with_group_id", null: false
    t.date "expires_at"
    t.integer "group_access", limit: 2, default: 30, null: false
    t.index ["shared_group_id", "shared_with_group_id"], name: "index_group_group_links_on_shared_group_and_shared_with_group", unique: true
    t.index ["shared_with_group_id", "shared_group_id"], name: "index_group_group_links_on_shared_with_group_and_shared_group"
  end

  create_table "group_import_states", primary_key: "group_id", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.text "jid"
    t.text "last_error"
    t.bigint "user_id"
    t.index ["group_id"], name: "index_group_import_states_on_group_id"
    t.index ["user_id"], name: "index_group_import_states_on_user_id", where: "(user_id IS NOT NULL)"
    t.check_constraint "char_length(jid) <= 100", name: "check_96558fff96"
    t.check_constraint "char_length(last_error) <= 255", name: "check_87b58f6b30"
    t.check_constraint "user_id IS NOT NULL", name: "check_cda75c7c3f"
  end

  create_table "group_merge_request_approval_settings", primary_key: "group_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "allow_author_approval", default: false, null: false
    t.boolean "allow_committer_approval", default: false, null: false
    t.boolean "allow_overrides_to_approver_list_per_merge_request", default: false, null: false
    t.boolean "retain_approvals_on_push", default: false, null: false
    t.boolean "require_password_to_approve", default: false, null: false
  end

  create_table "group_repository_storage_moves", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "group_id", null: false
    t.integer "state", limit: 2, default: 1, null: false
    t.text "source_storage_name", null: false
    t.text "destination_storage_name", null: false
    t.index ["group_id"], name: "index_group_repository_storage_moves_on_group_id"
    t.check_constraint "char_length(destination_storage_name) <= 255", name: "group_repository_storage_moves_destination_storage_name"
    t.check_constraint "char_length(source_storage_name) <= 255", name: "group_repository_storage_moves_source_storage_name"
  end

  create_table "group_wiki_repositories", primary_key: "group_id", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "shard_id", null: false
    t.text "disk_path", null: false
    t.index ["disk_path"], name: "index_group_wiki_repositories_on_disk_path", unique: true
    t.index ["shard_id"], name: "index_group_wiki_repositories_on_shard_id"
    t.check_constraint "char_length(disk_path) <= 80", name: "check_07f1c81806"
  end

  create_table "historical_data", id: :serial, force: :cascade do |t|
    t.date "date"
    t.integer "active_user_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime_with_timezone "recorded_at"
    t.index ["recorded_at"], name: "index_historical_data_on_recorded_at"
    t.check_constraint "recorded_at IS NOT NULL", name: "check_640e8cf66c"
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.string "extern_uid"
    t.string "provider"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "secondary_extern_uid"
    t.integer "saml_provider_id"
    t.index "lower((extern_uid)::text), provider", name: "index_on_identities_lower_extern_uid_and_provider"
    t.index ["saml_provider_id"], name: "index_identities_on_saml_provider_id", where: "(saml_provider_id IS NOT NULL)"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "import_export_uploads", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "updated_at", null: false
    t.integer "project_id"
    t.text "import_file"
    t.text "export_file"
    t.bigint "group_id"
    t.text "remote_import_url"
    t.index ["group_id"], name: "index_import_export_uploads_on_group_id", unique: true, where: "(group_id IS NOT NULL)"
    t.index ["project_id"], name: "index_import_export_uploads_on_project_id"
    t.index ["updated_at"], name: "index_import_export_uploads_on_updated_at"
    t.check_constraint "char_length(remote_import_url) <= 2048", name: "check_58f0d37481"
  end

  create_table "import_failures", force: :cascade do |t|
    t.integer "relation_index"
    t.bigint "project_id"
    t.datetime_with_timezone "created_at", null: false
    t.string "relation_key", limit: 64
    t.string "exception_class", limit: 128
    t.string "correlation_id_value", limit: 128
    t.string "exception_message", limit: 255
    t.integer "retry_count"
    t.integer "group_id"
    t.string "source", limit: 128
    t.index ["correlation_id_value"], name: "index_import_failures_on_correlation_id_value"
    t.index ["group_id"], name: "index_import_failures_on_group_id_not_null", where: "(group_id IS NOT NULL)"
    t.index ["project_id", "correlation_id_value"], name: "index_import_failures_on_project_id_and_correlation_id_value", where: "(retry_count = 0)"
    t.index ["project_id"], name: "index_import_failures_on_project_id_not_null", where: "(project_id IS NOT NULL)"
  end

  create_table "in_product_marketing_emails", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime_with_timezone "cta_clicked_at"
    t.integer "track", limit: 2
    t.integer "series", limit: 2
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "campaign"
    t.index ["track", "series", "id", "cta_clicked_at"], name: "index_in_product_marketing_emails_on_track_series_id_clicked"
    t.index ["user_id", "campaign"], name: "index_in_product_marketing_emails_on_user_campaign", unique: true
    t.index ["user_id", "track", "series"], name: "index_in_product_marketing_emails_on_user_track_series", unique: true
    t.index ["user_id"], name: "index_in_product_marketing_emails_on_user_id"
    t.check_constraint "((track IS NOT NULL) AND (series IS NOT NULL) AND (campaign IS NULL)) OR ((track IS NULL) AND (series IS NULL) AND (campaign IS NOT NULL))", name: "in_product_marketing_emails_track_and_series_or_campaign"
    t.check_constraint "char_length(campaign) <= 255", name: "check_9d8b29f74f"
  end

  create_table "incident_management_escalation_policies", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.text "name", null: false
    t.text "description"
    t.index ["project_id", "name"], name: "index_on_project_id_escalation_policy_name_unique", unique: true
    t.check_constraint "char_length(description) <= 160", name: "check_510b2a5258"
    t.check_constraint "char_length(name) <= 72", name: "check_9a26365850"
  end

  create_table "incident_management_escalation_rules", force: :cascade do |t|
    t.bigint "policy_id", null: false
    t.bigint "oncall_schedule_id"
    t.integer "status", limit: 2, null: false
    t.integer "elapsed_time_seconds", null: false
    t.boolean "is_removed", default: false, null: false
    t.bigint "user_id"
    t.index ["oncall_schedule_id"], name: "index_on_oncall_schedule_escalation_rule"
    t.index ["policy_id", "oncall_schedule_id", "status", "elapsed_time_seconds", "user_id"], name: "index_escalation_rules_on_all_attributes", unique: true
    t.index ["user_id"], name: "index_escalation_rules_on_user"
    t.check_constraint "num_nonnulls(oncall_schedule_id, user_id) = 1", name: "escalation_rules_one_of_oncall_schedule_or_user"
  end

  create_table "incident_management_issuable_escalation_statuses", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "issue_id", null: false
    t.bigint "policy_id"
    t.datetime_with_timezone "escalations_started_at"
    t.datetime_with_timezone "resolved_at"
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["issue_id"], name: "index_uniq_im_issuable_escalation_statuses_on_issue_id", unique: true
    t.index ["policy_id"], name: "index_im_issuable_escalation_statuses_on_policy_id"
  end

  create_table "incident_management_oncall_participants", force: :cascade do |t|
    t.bigint "oncall_rotation_id", null: false
    t.bigint "user_id", null: false
    t.integer "color_palette", limit: 2, null: false
    t.integer "color_weight", limit: 2, null: false
    t.boolean "is_removed", default: false, null: false
    t.index ["oncall_rotation_id", "is_removed"], name: "index_inc_mgmnt_oncall_pcpnt_on_oncall_rotation_id_is_removed"
    t.index ["user_id", "oncall_rotation_id"], name: "index_inc_mgmnt_oncall_participants_on_user_id_and_rotation_id", unique: true
    t.index ["user_id"], name: "index_inc_mgmnt_oncall_participants_on_oncall_user_id"
  end

  create_table "incident_management_oncall_rotations", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "oncall_schedule_id", null: false
    t.integer "length", null: false
    t.integer "length_unit", limit: 2, null: false
    t.datetime_with_timezone "starts_at", null: false
    t.text "name", null: false
    t.datetime_with_timezone "ends_at"
    t.time "active_period_start"
    t.time "active_period_end"
    t.index ["oncall_schedule_id", "id"], name: "index_inc_mgmnt_oncall_rotations_on_oncall_schedule_id_and_id", unique: true
    t.index ["oncall_schedule_id", "name"], name: "index_inc_mgmnt_oncall_rotations_on_oncall_schedule_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 200", name: "check_5209fb5d02"
  end

  create_table "incident_management_oncall_schedules", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.integer "iid", null: false
    t.text "name", null: false
    t.text "description"
    t.text "timezone"
    t.index ["project_id", "iid"], name: "index_im_oncall_schedules_on_project_id_and_iid", unique: true
    t.index ["project_id"], name: "index_incident_management_oncall_schedules_on_project_id"
    t.check_constraint "char_length(description) <= 1000", name: "check_7ed1fd5aa7"
    t.check_constraint "char_length(name) <= 200", name: "check_e6ef43a664"
    t.check_constraint "char_length(timezone) <= 100", name: "check_cc77cbb103"
  end

  create_table "incident_management_oncall_shifts", force: :cascade do |t|
    t.bigint "rotation_id", null: false
    t.bigint "participant_id", null: false
    t.datetime_with_timezone "starts_at", null: false
    t.datetime_with_timezone "ends_at", null: false
    t.index "rotation_id, tstzrange(starts_at, ends_at, '[)'::text)", name: "inc_mgmnt_no_overlapping_oncall_shifts", using: :gist
    t.index ["participant_id"], name: "index_incident_management_oncall_shifts_on_participant_id"
    t.index ["rotation_id", "starts_at", "ends_at"], name: "index_oncall_shifts_on_rotation_id_and_starts_at_and_ends_at"
  end

  create_table "incident_management_pending_alert_escalations", primary_key: ["id", "process_at"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "rule_id", null: false
    t.bigint "alert_id", null: false
    t.datetime_with_timezone "process_at", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["alert_id"], name: "index_incident_management_pending_alert_escalations_on_alert_id"
    t.index ["rule_id"], name: "index_incident_management_pending_alert_escalations_on_rule_id"
  end

  create_table "incident_management_pending_issue_escalations", primary_key: ["id", "process_at"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "rule_id", null: false
    t.bigint "issue_id", null: false
    t.datetime_with_timezone "process_at", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["issue_id"], name: "index_incident_management_pending_issue_escalations_on_issue_id"
    t.index ["rule_id"], name: "index_incident_management_pending_issue_escalations_on_rule_id"
  end

  create_table "incident_management_timeline_event_tag_links", force: :cascade do |t|
    t.bigint "timeline_event_id", null: false
    t.bigint "timeline_event_tag_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.index ["timeline_event_id"], name: "index_im_timeline_event_id"
    t.index ["timeline_event_tag_id", "timeline_event_id"], name: "index_im_timeline_event_tags_on_tag_id_and_event_id", unique: true
  end

  create_table "incident_management_timeline_event_tags", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.text "name", null: false
    t.index "project_id, lower(name)", name: "index_im_timeline_event_tags_on_lower_name_and_project_id", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_8717184e2c"
  end

  create_table "incident_management_timeline_events", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "occurred_at", null: false
    t.bigint "project_id", null: false
    t.bigint "author_id"
    t.bigint "issue_id", null: false
    t.bigint "updated_by_user_id"
    t.bigint "promoted_from_note_id"
    t.integer "cached_markdown_version"
    t.boolean "editable", default: false, null: false
    t.text "note", null: false
    t.text "note_html", null: false
    t.text "action", null: false
    t.index ["author_id"], name: "index_im_timeline_events_author_id"
    t.index ["issue_id"], name: "index_im_timeline_events_issue_id"
    t.index ["project_id"], name: "index_im_timeline_events_project_id"
    t.index ["promoted_from_note_id"], name: "index_im_timeline_events_promoted_from_note_id"
    t.index ["updated_by_user_id"], name: "index_im_timeline_events_updated_by_user_id"
    t.check_constraint "char_length(action) <= 128", name: "check_18fd072206"
    t.check_constraint "char_length(note) <= 10000", name: "check_3875ed0aac"
    t.check_constraint "char_length(note_html) <= 10000", name: "check_94a235d6a4"
  end

  create_table "index_statuses", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.datetime "indexed_at"
    t.text "note"
    t.string "last_commit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.binary "last_wiki_commit"
    t.datetime_with_timezone "wiki_indexed_at"
    t.index ["project_id"], name: "index_index_statuses_on_project_id", unique: true
  end

  create_table "insights", id: :serial, force: :cascade do |t|
    t.integer "namespace_id", null: false
    t.integer "project_id", null: false
    t.index ["namespace_id"], name: "index_insights_on_namespace_id"
    t.index ["project_id"], name: "index_insights_on_project_id"
  end

  create_table "integrations", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "active", default: false, null: false
    t.boolean "push_events", default: true
    t.boolean "issues_events", default: true
    t.boolean "merge_requests_events", default: true
    t.boolean "tag_push_events", default: true
    t.boolean "note_events", default: true, null: false
    t.string "category", default: "common", null: false
    t.boolean "wiki_page_events", default: true
    t.boolean "pipeline_events", default: false, null: false
    t.boolean "confidential_issues_events", default: true, null: false
    t.boolean "commit_events", default: true, null: false
    t.boolean "job_events", default: false, null: false
    t.boolean "confidential_note_events", default: true
    t.boolean "deployment_events", default: false, null: false
    t.boolean "comment_on_event_enabled", default: true, null: false
    t.boolean "instance", default: false, null: false
    t.integer "comment_detail", limit: 2
    t.bigint "inherit_from_id"
    t.boolean "alert_events"
    t.bigint "group_id"
    t.text "type_new"
    t.boolean "vulnerability_events", default: false, null: false
    t.boolean "archive_trace_events", default: false, null: false
    t.binary "encrypted_properties"
    t.binary "encrypted_properties_iv"
    t.index ["group_id", "type_new"], name: "index_integrations_on_unique_group_id_and_type_new"
    t.index ["inherit_from_id"], name: "index_integrations_on_inherit_from_id"
    t.index ["project_id", "type_new"], name: "index_integrations_on_project_and_type_new_where_inherit_null", where: "(inherit_from_id IS NULL)"
    t.index ["project_id", "type_new"], name: "index_integrations_on_project_id_and_type_new_unique", unique: true
    t.index ["type_new", "id", "inherit_from_id"], name: "index_integrations_on_type_new_id_when_active_and_has_group", where: "((active = true) AND (group_id IS NOT NULL))"
    t.index ["type_new", "id"], name: "index_integrations_on_type_new_id_when_active_and_has_project", where: "((active = true) AND (project_id IS NOT NULL))"
    t.index ["type_new", "instance"], name: "index_integrations_on_type_new_and_instance_partial", where: "(instance = true)"
    t.index ["type_new"], name: "index_integrations_on_type_new"
    t.check_constraint "char_length(type_new) <= 255", name: "check_a948a0aa7e"
  end

  create_table "internal_ids", force: :cascade do |t|
    t.integer "project_id"
    t.integer "usage", null: false
    t.integer "last_value", null: false
    t.integer "namespace_id"
    t.index ["namespace_id"], name: "index_internal_ids_on_namespace_id"
    t.index ["project_id"], name: "index_internal_ids_on_project_id"
    t.index ["usage", "namespace_id"], name: "index_internal_ids_on_usage_and_namespace_id", unique: true, where: "(namespace_id IS NOT NULL)"
    t.index ["usage", "project_id"], name: "index_internal_ids_on_usage_and_project_id", unique: true, where: "(project_id IS NOT NULL)"
  end

  create_table "ip_restrictions", force: :cascade do |t|
    t.integer "group_id", null: false
    t.string "range", null: false
    t.index ["group_id"], name: "index_ip_restrictions_on_group_id"
  end

  create_table "issuable_metric_images", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "file_store", limit: 2
    t.text "file", null: false
    t.text "url"
    t.text "url_text"
    t.index ["issue_id"], name: "index_issuable_metric_images_on_issue_id"
    t.check_constraint "char_length(file) <= 255", name: "check_7ed527062f"
    t.check_constraint "char_length(url) <= 255", name: "check_5b3011e234"
    t.check_constraint "char_length(url_text) <= 128", name: "check_3bc6d47661"
  end

  create_table "issuable_resource_links", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.text "link_text"
    t.text "link", null: false
    t.integer "link_type", limit: 2, default: 0, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["issue_id"], name: "index_issuable_resource_links_on_issue_id"
    t.check_constraint "char_length(link) <= 2200", name: "check_67be6729db"
    t.check_constraint "char_length(link_text) <= 255", name: "check_b137147e0b"
  end

  create_table "issuable_severities", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.integer "severity", limit: 2, default: 0, null: false
    t.index ["issue_id"], name: "index_issuable_severities_on_issue_id", unique: true
  end

  create_table "issuable_slas", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.datetime_with_timezone "due_at", null: false
    t.boolean "label_applied", default: false, null: false
    t.boolean "issuable_closed", default: false, null: false
    t.index ["due_at", "id"], name: "index_issuable_slas_on_due_at_id_label_applied_issuable_closed", where: "((label_applied = false) AND (issuable_closed = false))"
    t.index ["issue_id"], name: "index_issuable_slas_on_issue_id", unique: true
  end

  create_table "issue_assignees", primary_key: ["issue_id", "user_id"], force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "issue_id", null: false
    t.index ["user_id"], name: "index_issue_assignees_on_user_id"
  end

  create_table "issue_customer_relations_contacts", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.bigint "contact_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["contact_id"], name: "index_issue_customer_relations_contacts_on_contact_id"
    t.index ["issue_id", "contact_id"], name: "index_issue_crm_contacts_on_issue_id_and_contact_id", unique: true
  end

  create_table "issue_email_participants", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "email", null: false
    t.index "issue_id, lower(email)", name: "index_issue_email_participants_on_issue_id_and_lower_email", unique: true
    t.check_constraint "char_length(email) <= 255", name: "check_2c321d408d"
  end

  create_table "issue_emails", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.text "email_message_id", null: false
    t.index ["email_message_id"], name: "index_issue_emails_on_email_message_id"
    t.index ["issue_id"], name: "index_issue_emails_on_issue_id"
    t.check_constraint "char_length(email_message_id) <= 1000", name: "check_5abf3e6aea"
  end

  create_table "issue_links", id: :serial, force: :cascade do |t|
    t.integer "source_id", null: false
    t.integer "target_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "link_type", limit: 2, default: 0, null: false
    t.index ["source_id", "target_id"], name: "index_issue_links_on_source_id_and_target_id", unique: true
    t.index ["source_id"], name: "index_issue_links_on_source_id"
    t.index ["target_id"], name: "index_issue_links_on_target_id"
  end

  create_table "issue_metrics", id: :serial, force: :cascade do |t|
    t.integer "issue_id", null: false
    t.datetime "first_mentioned_in_commit_at"
    t.datetime "first_associated_with_milestone_at"
    t.datetime "first_added_to_board_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id", "first_mentioned_in_commit_at", "first_associated_with_milestone_at", "first_added_to_board_at"], name: "index_issue_metrics_on_issue_id_and_timestamps"
    t.index ["issue_id"], name: "index_unique_issue_metrics_issue_id", unique: true
  end

  create_table "issue_search_data", primary_key: ["project_id", "issue_id"], force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "issue_id", null: false
    t.datetime_with_timezone "created_at", default: -> { "now()" }, null: false
    t.datetime_with_timezone "updated_at", default: -> { "now()" }, null: false
    t.tsvector "search_vector"
    t.index ["issue_id"], name: "index_issue_search_data_on_issue_id"
    t.index ["search_vector"], name: "index_issue_search_data_on_search_vector", using: :gin
  end

  create_table "issue_tracker_data", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "encrypted_project_url"
    t.string "encrypted_project_url_iv"
    t.string "encrypted_issues_url"
    t.string "encrypted_issues_url_iv"
    t.string "encrypted_new_issue_url"
    t.string "encrypted_new_issue_url_iv"
    t.integer "integration_id"
    t.index ["integration_id"], name: "index_issue_tracker_data_on_integration_id"
    t.check_constraint "integration_id IS NOT NULL", name: "check_7ca00cd891"
  end

  create_table "issue_user_mentions", force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "note_id"
    t.integer "mentioned_users_ids", array: true
    t.integer "mentioned_projects_ids", array: true
    t.integer "mentioned_groups_ids", array: true
    t.index ["issue_id", "note_id"], name: "issue_user_mentions_on_issue_id_and_note_id_index", unique: true
    t.index ["issue_id"], name: "issue_user_mentions_on_issue_id_index", unique: true, where: "(note_id IS NULL)"
    t.index ["note_id"], name: "index_issue_user_mentions_on_note_id", unique: true, where: "(note_id IS NOT NULL)"
  end

  create_table "issues", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "author_id"
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
    t.integer "milestone_id"
    t.integer "iid"
    t.integer "updated_by_id"
    t.integer "weight"
    t.boolean "confidential", default: false, null: false
    t.date "due_date"
    t.integer "moved_to_id"
    t.integer "lock_version", default: 0
    t.text "title_html"
    t.text "description_html"
    t.integer "time_estimate"
    t.integer "relative_position"
    t.string "service_desk_reply_to"
    t.integer "cached_markdown_version"
    t.datetime "last_edited_at"
    t.integer "last_edited_by_id"
    t.boolean "discussion_locked"
    t.datetime_with_timezone "closed_at"
    t.integer "closed_by_id"
    t.integer "state_id", limit: 2, default: 1, null: false
    t.integer "duplicated_to_id"
    t.integer "promoted_to_epic_id"
    t.integer "health_status", limit: 2
    t.string "external_key", limit: 255
    t.bigint "sprint_id"
    t.integer "issue_type", limit: 2, default: 0, null: false
    t.integer "blocking_issues_count", default: 0, null: false
    t.integer "upvotes_count", default: 0, null: false
    t.bigint "work_item_type_id"
    t.bigint "namespace_id"
    t.date "start_date"
    t.index ["author_id", "id", "created_at"], name: "index_issues_on_author_id_and_id_and_created_at"
    t.index ["author_id"], name: "index_issues_on_author_id"
    t.index ["closed_by_id"], name: "index_issues_on_closed_by_id"
    t.index ["confidential"], name: "index_issues_on_confidential"
    t.index ["description"], name: "index_issues_on_description_trigram_non_latin", opclass: :gin_trgm_ops, where: "(((title)::text !~ similar_escape('[\\u0000-\\u02FF\\u1E00-\\u1EFF\\u2070-\\u218F]*'::text, NULL::text)) OR (description !~ similar_escape('[\\u0000-\\u02FF\\u1E00-\\u1EFF\\u2070-\\u218F]*'::text, NULL::text)))", using: :gin
    t.index ["duplicated_to_id"], name: "index_issues_on_duplicated_to_id", where: "(duplicated_to_id IS NOT NULL)"
    t.index ["health_status"], name: "idx_issues_on_health_status_not_null", where: "(health_status IS NOT NULL)"
    t.index ["id", "weight"], name: "index_issues_on_id_and_weight"
    t.index ["issue_type"], name: "index_issues_on_incident_issue_type", where: "(issue_type = 1)"
    t.index ["last_edited_by_id"], name: "index_issues_on_last_edited_by_id"
    t.index ["milestone_id"], name: "index_issues_on_milestone_id"
    t.index ["moved_to_id"], name: "index_issues_on_moved_to_id", where: "(moved_to_id IS NOT NULL)"
    t.index ["namespace_id"], name: "index_issues_on_namespace_id"
    t.index ["project_id", "closed_at", "state_id", "id"], name: "index_issues_on_project_id_closed_at_desc_state_id_and_id", order: { closed_at: "DESC NULLS LAST" }
    t.index ["project_id", "closed_at", "state_id", "id"], name: "index_issues_on_project_id_closed_at_state_id_and_id"
    t.index ["project_id", "closed_at"], name: "index_on_issues_closed_incidents_by_project_id_and_closed_at", where: "((issue_type = 1) AND (state_id = 2))"
    t.index ["project_id", "confidential", "author_id", "id"], name: "idx_open_issues_on_project_and_confidential_and_author_and_id", where: "(state_id = 1)"
    t.index ["project_id", "created_at", "id", "state_id"], name: "idx_issues_on_project_id_and_created_at_and_id_and_state_id"
    t.index ["project_id", "created_at"], name: "index_issues_on_project_id_and_created_at_issue_type_incident", where: "(issue_type = 1)"
    t.index ["project_id", "due_date", "id", "state_id"], name: "idx_issues_on_project_id_and_due_date_and_id_and_state_id", where: "(due_date IS NOT NULL)"
    t.index ["project_id", "external_key"], name: "index_issues_on_project_id_and_external_key", unique: true, where: "(external_key IS NOT NULL)"
    t.index ["project_id", "health_status", "created_at", "id"], name: "index_issues_on_project_id_health_status_created_at_id"
    t.index ["project_id", "iid"], name: "index_issues_on_project_id_and_iid", unique: true
    t.index ["project_id", "relative_position", "id", "state_id"], name: "idx_issues_on_project_id_and_rel_position_and_id_and_state_id"
    t.index ["project_id", "state_id", "blocking_issues_count"], name: "index_issue_on_project_id_state_id_and_blocking_issues_count"
    t.index ["project_id", "state_id", "created_at", "id"], name: "index_issues_on_project_id_and_state_id_and_created_at_and_id"
    t.index ["project_id", "updated_at", "id", "state_id"], name: "idx_issues_on_project_id_and_updated_at_and_id_and_state_id"
    t.index ["project_id", "upvotes_count"], name: "index_issues_on_project_id_and_upvotes_count"
    t.index ["promoted_to_epic_id"], name: "index_issues_on_promoted_to_epic_id", where: "(promoted_to_epic_id IS NOT NULL)"
    t.index ["sprint_id"], name: "index_issues_on_sprint_id"
    t.index ["state_id"], name: "idx_issues_on_state_id"
    t.index ["title"], name: "index_issues_on_title_trigram_non_latin", opclass: :gin_trgm_ops, where: "(((title)::text !~ similar_escape('[\\u0000-\\u02FF\\u1E00-\\u1EFF\\u2070-\\u218F]*'::text, NULL::text)) OR (description !~ similar_escape('[\\u0000-\\u02FF\\u1E00-\\u1EFF\\u2070-\\u218F]*'::text, NULL::text)))", using: :gin
    t.index ["updated_at"], name: "index_issues_on_updated_at"
    t.index ["updated_by_id"], name: "index_issues_on_updated_by_id", where: "(updated_by_id IS NOT NULL)"
    t.check_constraint "lock_version IS NOT NULL", name: "check_fba63f706d"
    t.check_constraint "namespace_id IS NOT NULL", name: "check_c33362cd43"
    t.check_constraint "work_item_type_id IS NOT NULL", name: "check_2addf801cd"
  end

  create_table "issues_prometheus_alert_events", primary_key: ["issue_id", "prometheus_alert_event_id"], force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.bigint "prometheus_alert_event_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["prometheus_alert_event_id"], name: "issue_id_issues_prometheus_alert_events_index"
  end

  create_table "issues_self_managed_prometheus_alert_events", primary_key: ["issue_id", "self_managed_prometheus_alert_event_id"], force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.bigint "self_managed_prometheus_alert_event_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["self_managed_prometheus_alert_event_id"], name: "issue_id_issues_self_managed_rometheus_alert_events_index"
  end

  create_table "iterations_cadences", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.date "start_date"
    t.integer "duration_in_weeks"
    t.integer "iterations_in_advance"
    t.boolean "active", default: true, null: false
    t.boolean "automatic", default: true, null: false
    t.text "title", null: false
    t.boolean "roll_over", default: false, null: false
    t.text "description"
    t.date "next_run_date"
    t.index ["group_id"], name: "index_iterations_cadences_on_group_id"
    t.check_constraint "char_length(description) <= 5000", name: "check_5c5d2b44bd"
    t.check_constraint "char_length(title) <= 255", name: "check_fedff82d3b"
  end

  create_table "jira_connect_installations", force: :cascade do |t|
    t.string "client_key"
    t.string "encrypted_shared_secret"
    t.string "encrypted_shared_secret_iv"
    t.string "base_url"
    t.text "instance_url"
    t.index ["client_key"], name: "index_jira_connect_installations_on_client_key", unique: true
    t.index ["instance_url"], name: "index_jira_connect_installations_on_instance_url"
    t.check_constraint "char_length(instance_url) <= 255", name: "check_4c6abed669"
  end

  create_table "jira_connect_subscriptions", force: :cascade do |t|
    t.bigint "jira_connect_installation_id", null: false
    t.integer "namespace_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["jira_connect_installation_id", "namespace_id"], name: "idx_jira_connect_subscriptions_on_installation_id_namespace_id", unique: true
    t.index ["jira_connect_installation_id"], name: "idx_jira_connect_subscriptions_on_installation_id"
    t.index ["namespace_id"], name: "index_jira_connect_subscriptions_on_namespace_id"
  end

  create_table "jira_imports", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id"
    t.bigint "label_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "finished_at"
    t.bigint "jira_project_xid", null: false
    t.integer "total_issue_count", default: 0, null: false
    t.integer "imported_issues_count", default: 0, null: false
    t.integer "failed_to_import_count", default: 0, null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.string "jid", limit: 255
    t.string "jira_project_key", limit: 255, null: false
    t.string "jira_project_name", limit: 255, null: false
    t.datetime_with_timezone "scheduled_at"
    t.text "error_message"
    t.index ["label_id"], name: "index_jira_imports_on_label_id"
    t.index ["project_id", "jira_project_key"], name: "index_jira_imports_on_project_id_and_jira_project_key"
    t.index ["user_id"], name: "index_jira_imports_on_user_id"
    t.check_constraint "char_length(error_message) <= 1000", name: "check_9ed451c5b1"
  end

  create_table "jira_tracker_data", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "encrypted_url"
    t.string "encrypted_url_iv"
    t.string "encrypted_api_url"
    t.string "encrypted_api_url_iv"
    t.string "encrypted_username"
    t.string "encrypted_username_iv"
    t.string "encrypted_password"
    t.string "encrypted_password_iv"
    t.string "jira_issue_transition_id"
    t.text "project_key"
    t.boolean "issues_enabled", default: false, null: false
    t.integer "deployment_type", limit: 2, default: 0, null: false
    t.text "vulnerabilities_issuetype"
    t.boolean "vulnerabilities_enabled", default: false, null: false
    t.boolean "jira_issue_transition_automatic", default: false, null: false
    t.integer "integration_id"
    t.index ["integration_id"], name: "index_jira_tracker_data_on_integration_id"
    t.check_constraint "char_length(project_key) <= 255", name: "check_214cf6a48b"
    t.check_constraint "char_length(vulnerabilities_issuetype) <= 255", name: "check_0bf84b76e9"
    t.check_constraint "integration_id IS NOT NULL", name: "check_0fbd71d9f2"
  end

  create_table "keys", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "key"
    t.string "title"
    t.string "type"
    t.string "fingerprint"
    t.boolean "public", default: false, null: false
    t.datetime "last_used_at"
    t.binary "fingerprint_sha256"
    t.datetime_with_timezone "expires_at"
    t.datetime_with_timezone "expiry_notification_delivered_at"
    t.datetime_with_timezone "before_expiry_notification_delivered_at"
    t.integer "usage_type", limit: 2, default: 0, null: false
    t.index "date(timezone('UTC'::text, expires_at)), before_expiry_notification_delivered_at", name: "idx_keys_expires_at_and_before_expiry_notification_undelivered", where: "(before_expiry_notification_delivered_at IS NULL)"
    t.index "date(timezone('UTC'::text, expires_at)), id", name: "index_keys_on_expires_at_and_id", where: "(expiry_notification_delivered_at IS NULL)"
    t.index ["fingerprint"], name: "index_keys_on_fingerprint"
    t.index ["fingerprint_sha256"], name: "index_keys_on_fingerprint_sha256_unique", unique: true
    t.index ["id", "type"], name: "index_on_deploy_keys_id_and_type_and_public", unique: true, where: "(public = true)"
    t.index ["id"], name: "index_keys_on_id_and_ldap_key_type", where: "((type)::text = 'LDAPKey'::text)"
    t.index ["last_used_at"], name: "index_keys_on_last_used_at", order: "DESC NULLS LAST"
    t.index ["user_id"], name: "index_keys_on_user_id"
  end

  create_table "label_links", id: :serial, force: :cascade do |t|
    t.integer "label_id"
    t.integer "target_id"
    t.string "target_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["label_id", "target_type"], name: "index_label_links_on_label_id_and_target_type"
    t.index ["target_id", "label_id", "target_type"], name: "index_on_label_links_all_columns"
    t.index ["target_id", "target_type"], name: "index_label_links_on_target_id_and_target_type"
  end

  create_table "label_priorities", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "label_id", null: false
    t.integer "priority", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_label_priorities_on_label_id"
    t.index ["priority"], name: "index_label_priorities_on_priority"
    t.index ["project_id", "label_id"], name: "index_label_priorities_on_project_id_and_label_id", unique: true
  end

  create_table "labels", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "color"
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "template", default: false
    t.string "description"
    t.text "description_html"
    t.string "type"
    t.integer "group_id"
    t.integer "cached_markdown_version"
    t.index ["group_id", "title"], name: "index_labels_on_group_id_and_title_varchar_unique", unique: true, opclass: { title: :varchar_pattern_ops }, where: "(project_id IS NULL)"
    t.index ["group_id"], name: "index_labels_on_group_id"
    t.index ["project_id", "title"], name: "index_labels_on_project_id_and_title_varchar_unique", unique: true, opclass: { title: :varchar_pattern_ops }, where: "(group_id IS NULL)"
    t.index ["project_id"], name: "index_labels_on_project_id"
    t.index ["template"], name: "index_labels_on_template", where: "template"
    t.index ["title"], name: "index_labels_on_title_varchar", opclass: :varchar_pattern_ops
    t.index ["type", "project_id"], name: "index_labels_on_type_and_project_id"
  end

  create_table "ldap_group_links", id: :serial, force: :cascade do |t|
    t.string "cn"
    t.integer "group_access", null: false
    t.integer "group_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "provider"
    t.string "filter"
  end

  create_table "lfs_file_locks", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.string "path", limit: 511
    t.index ["project_id", "path"], name: "index_lfs_file_locks_on_project_id_and_path", unique: true
    t.index ["user_id"], name: "index_lfs_file_locks_on_user_id"
  end

  create_table "lfs_object_states", primary_key: "lfs_object_id", force: :cascade do |t|
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.integer "verification_retry_count", limit: 2
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.index ["lfs_object_id"], name: "index_lfs_object_states_on_lfs_object_id"
    t.index ["verification_retry_at"], name: "index_lfs_object_states_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_lfs_object_states_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_lfs_object_states_on_verification_state"
    t.index ["verified_at"], name: "index_lfs_object_states_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_efe45a8ab3"
  end

  create_table "lfs_objects", id: :serial, force: :cascade do |t|
    t.string "oid", null: false
    t.bigint "size", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file"
    t.integer "file_store", default: 1
    t.index ["file_store"], name: "index_lfs_objects_on_file_store"
    t.index ["oid"], name: "index_lfs_objects_on_oid", unique: true
    t.check_constraint "file_store IS NOT NULL", name: "check_eecfc5717d"
  end

  create_table "lfs_objects_projects", id: :serial, force: :cascade do |t|
    t.integer "lfs_object_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "repository_type", limit: 2
    t.index ["lfs_object_id"], name: "index_lfs_objects_projects_on_lfs_object_id"
    t.index ["project_id", "lfs_object_id"], name: "index_lfs_objects_projects_on_project_id_and_lfs_object_id"
  end

  create_table "licenses", id: :serial, force: :cascade do |t|
    t.text "data", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "cloud", default: false
    t.datetime_with_timezone "last_synced_at"
  end

  create_table "list_user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "list_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "collapsed"
    t.index ["list_id"], name: "index_list_user_preferences_on_list_id"
    t.index ["user_id", "list_id"], name: "index_list_user_preferences_on_user_id_and_list_id", unique: true
    t.index ["user_id"], name: "index_list_user_preferences_on_user_id"
  end

  create_table "lists", id: :serial, force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "label_id"
    t.integer "list_type", default: 1, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "milestone_id"
    t.integer "max_issue_count", default: 0, null: false
    t.integer "max_issue_weight", default: 0, null: false
    t.string "limit_metric", limit: 20
    t.bigint "iteration_id"
    t.index ["board_id", "label_id"], name: "index_lists_on_board_id_and_label_id", unique: true
    t.index ["iteration_id"], name: "index_lists_on_iteration_id"
    t.index ["label_id"], name: "index_lists_on_label_id"
    t.index ["list_type"], name: "index_lists_on_list_type"
    t.index ["milestone_id"], name: "index_lists_on_milestone_id"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "loose_foreign_keys_deleted_records", primary_key: ["partition", "id"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "partition", default: 1, null: false
    t.bigint "primary_key_value", null: false
    t.integer "status", limit: 2, default: 1, null: false
    t.datetime_with_timezone "created_at", default: -> { "now()" }, null: false
    t.text "fully_qualified_table_name", null: false
    t.datetime_with_timezone "consume_after", default: -> { "now()" }
    t.integer "cleanup_attempts", limit: 2, default: 0
    t.index ["partition", "fully_qualified_table_name", "consume_after", "id"], name: "index_loose_foreign_keys_deleted_records_for_partitioned_query", where: "(status = 1)"
    t.check_constraint "char_length(fully_qualified_table_name) <= 150", name: "check_1a541f3235"
  end

  create_table "member_roles", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "base_access_level", null: false
    t.boolean "download_code", default: false
    t.index ["namespace_id"], name: "index_member_roles_on_namespace_id"
  end

  create_table "member_tasks", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "tasks", limit: 2, default: [], null: false, array: true
    t.index ["member_id", "project_id"], name: "index_member_tasks_on_member_id_and_project_id", unique: true
    t.index ["member_id"], name: "index_member_tasks_on_member_id"
    t.index ["project_id"], name: "index_member_tasks_on_project_id"
  end

  create_table "members", id: :serial, force: :cascade do |t|
    t.integer "access_level", null: false
    t.integer "source_id", null: false
    t.string "source_type", null: false
    t.integer "user_id"
    t.integer "notification_level", null: false
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_id"
    t.string "invite_email"
    t.string "invite_token"
    t.datetime "invite_accepted_at"
    t.datetime "requested_at"
    t.date "expires_at"
    t.boolean "ldap", default: false, null: false
    t.boolean "override", default: false, null: false
    t.integer "state", limit: 2, default: 0
    t.boolean "invite_email_success", default: true, null: false
    t.bigint "member_namespace_id"
    t.bigint "member_role_id"
    t.index ["access_level"], name: "index_members_on_access_level"
    t.index ["created_at"], name: "idx_members_created_at_user_id_invite_token", where: "((invite_token IS NOT NULL) AND (user_id IS NULL))"
    t.index ["expires_at"], name: "index_members_on_expires_at"
    t.index ["id"], name: "index_project_members_on_id_temp", where: "((source_type)::text = 'Project'::text)"
    t.index ["invite_email"], name: "index_members_on_invite_email"
    t.index ["invite_token"], name: "index_members_on_invite_token", unique: true
    t.index ["member_namespace_id"], name: "index_members_on_member_namespace_id"
    t.index ["member_namespace_id"], name: "tmp_index_for_null_member_namespace_id", where: "(member_namespace_id IS NULL)"
    t.index ["member_role_id"], name: "index_members_on_member_role_id"
    t.index ["requested_at"], name: "index_members_on_requested_at"
    t.index ["source_id", "source_type"], name: "index_members_on_source_id_and_source_type"
    t.index ["source_id", "source_type"], name: "index_non_requested_project_members_on_source_id_and_type", where: "((requested_at IS NULL) AND ((type)::text = 'ProjectMember'::text))"
    t.index ["state"], name: "tmp_index_members_on_state", where: "(state = 2)"
    t.index ["user_id", "access_level"], name: "index_members_on_user_id_and_access_level_requested_at_is_null", where: "(requested_at IS NULL)"
    t.index ["user_id", "created_at"], name: "index_members_on_user_id_created_at", where: "((ldap = true) AND ((type)::text = 'GroupMember'::text) AND ((source_type)::text = 'Namespace'::text))"
    t.index ["user_id", "source_id", "source_type"], name: "index_members_on_user_id_source_id_source_type"
    t.check_constraint "member_namespace_id IS NOT NULL", name: "check_508774aac0"
  end

  create_table "merge_request_assignees", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "merge_request_id", null: false
    t.datetime_with_timezone "created_at"
    t.index ["merge_request_id", "user_id"], name: "index_merge_request_assignees_on_merge_request_id_and_user_id", unique: true
    t.index ["merge_request_id"], name: "index_merge_request_assignees_on_merge_request_id"
    t.index ["user_id"], name: "index_merge_request_assignees_on_user_id"
  end

  create_table "merge_request_blocks", force: :cascade do |t|
    t.integer "blocking_merge_request_id", null: false
    t.integer "blocked_merge_request_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["blocked_merge_request_id"], name: "index_merge_request_blocks_on_blocked_merge_request_id"
    t.index ["blocking_merge_request_id", "blocked_merge_request_id"], name: "index_mr_blocks_on_blocking_and_blocked_mr_ids", unique: true
  end

  create_table "merge_request_cleanup_schedules", primary_key: "merge_request_id", force: :cascade do |t|
    t.datetime_with_timezone "scheduled_at", null: false
    t.datetime_with_timezone "completed_at"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.integer "failed_count", default: 0, null: false
    t.index ["merge_request_id"], name: "index_merge_request_cleanup_schedules_on_merge_request_id", unique: true
    t.index ["scheduled_at"], name: "index_mr_cleanup_schedules_timestamps_status", where: "((completed_at IS NULL) AND (status = 0))"
    t.index ["status"], name: "index_merge_request_cleanup_schedules_on_status"
  end

  create_table "merge_request_context_commit_diff_files", primary_key: ["merge_request_context_commit_id", "relative_order"], force: :cascade do |t|
    t.binary "sha", null: false
    t.integer "relative_order", null: false
    t.boolean "new_file", null: false
    t.boolean "renamed_file", null: false
    t.boolean "deleted_file", null: false
    t.boolean "too_large", null: false
    t.string "a_mode", limit: 255, null: false
    t.string "b_mode", limit: 255, null: false
    t.text "new_path", null: false
    t.text "old_path", null: false
    t.text "diff"
    t.boolean "binary"
    t.bigint "merge_request_context_commit_id", null: false
    t.index ["merge_request_context_commit_id", "sha"], name: "idx_mr_cc_diff_files_on_mr_cc_id_and_sha"
  end

  create_table "merge_request_context_commits", force: :cascade do |t|
    t.datetime_with_timezone "authored_date"
    t.datetime_with_timezone "committed_date"
    t.integer "relative_order", null: false
    t.binary "sha", null: false
    t.text "author_name"
    t.text "author_email"
    t.text "committer_name"
    t.text "committer_email"
    t.text "message"
    t.bigint "merge_request_id"
    t.jsonb "trailers", default: {}, null: false
    t.index ["merge_request_id", "sha"], name: "index_mr_context_commits_on_merge_request_id_and_sha", unique: true
  end

  create_table "merge_request_diff_commit_users", force: :cascade do |t|
    t.text "name"
    t.text "email"
    t.index ["name", "email"], name: "index_merge_request_diff_commit_users_on_name_and_email", unique: true
    t.check_constraint "(COALESCE(name, ''::text) <> ''::text) OR (COALESCE(email, ''::text) <> ''::text)", name: "merge_request_diff_commit_users_name_or_email_existence"
    t.check_constraint "char_length(email) <= 512", name: "check_f5fa206cf7"
    t.check_constraint "char_length(name) <= 512", name: "check_147358fc42"
  end

  create_table "merge_request_diff_commits", primary_key: ["merge_request_diff_id", "relative_order"], force: :cascade do |t|
    t.datetime "authored_date"
    t.datetime "committed_date"
    t.integer "merge_request_diff_id", null: false
    t.integer "relative_order", null: false
    t.binary "sha", null: false
    t.text "message"
    t.jsonb "trailers", default: {}, null: false
    t.bigint "commit_author_id"
    t.bigint "committer_id"
    t.index ["sha"], name: "index_merge_request_diff_commits_on_sha"
  end

  create_table "merge_request_diff_details", primary_key: "merge_request_diff_id", force: :cascade do |t|
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_retry_count", limit: 2
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.datetime_with_timezone "verification_started_at"
    t.index ["merge_request_diff_id"], name: "index_merge_request_diff_details_on_merge_request_diff_id"
    t.index ["verification_retry_at"], name: "index_merge_request_diff_details_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_merge_request_diff_details_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_merge_request_diff_details_on_verification_state"
    t.index ["verified_at"], name: "index_merge_request_diff_details_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_81429e3622"
  end

  create_table "merge_request_diff_files", primary_key: ["merge_request_diff_id", "relative_order"], force: :cascade do |t|
    t.integer "merge_request_diff_id", null: false
    t.integer "relative_order", null: false
    t.boolean "new_file", null: false
    t.boolean "renamed_file", null: false
    t.boolean "deleted_file", null: false
    t.boolean "too_large", null: false
    t.string "a_mode", null: false
    t.string "b_mode", null: false
    t.text "new_path", null: false
    t.text "old_path", null: false
    t.text "diff"
    t.boolean "binary"
    t.integer "external_diff_offset"
    t.integer "external_diff_size"
  end

  create_table "merge_request_diffs", id: :serial, force: :cascade do |t|
    t.string "state"
    t.integer "merge_request_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "base_commit_sha"
    t.string "real_size"
    t.string "head_commit_sha"
    t.string "start_commit_sha"
    t.integer "commits_count"
    t.string "external_diff"
    t.integer "external_diff_store", default: 1
    t.boolean "stored_externally"
    t.integer "files_count", limit: 2
    t.boolean "sorted", default: false, null: false
    t.integer "diff_type", limit: 2, default: 1, null: false
    t.index ["external_diff_store"], name: "index_merge_request_diffs_on_external_diff_store"
    t.index ["id"], name: "index_merge_request_diffs_by_id_partial", where: "((files_count > 0) AND ((NOT stored_externally) OR (stored_externally IS NULL)))"
    t.index ["merge_request_id", "id"], name: "index_merge_request_diffs_on_merge_request_id_and_id"
    t.index ["merge_request_id"], name: "index_merge_request_diffs_on_unique_merge_request_id", unique: true, where: "(diff_type = 2)"
    t.check_constraint "external_diff_store IS NOT NULL", name: "check_93ee616ac9"
  end

  create_table "merge_request_metrics", id: :serial, force: :cascade do |t|
    t.integer "merge_request_id", null: false
    t.datetime "latest_build_started_at"
    t.datetime "latest_build_finished_at"
    t.datetime "first_deployed_to_production_at"
    t.datetime "merged_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pipeline_id"
    t.integer "merged_by_id"
    t.integer "latest_closed_by_id"
    t.datetime_with_timezone "latest_closed_at"
    t.datetime_with_timezone "first_comment_at"
    t.datetime_with_timezone "first_commit_at"
    t.datetime_with_timezone "last_commit_at"
    t.integer "diff_size"
    t.integer "modified_paths_size"
    t.integer "commits_count"
    t.datetime_with_timezone "first_approved_at"
    t.datetime_with_timezone "first_reassigned_at"
    t.integer "added_lines"
    t.integer "removed_lines"
    t.integer "target_project_id"
    t.index ["first_deployed_to_production_at"], name: "index_merge_request_metrics_on_first_deployed_to_production_at"
    t.index ["latest_closed_at"], name: "index_merge_request_metrics_on_latest_closed_at", where: "(latest_closed_at IS NOT NULL)"
    t.index ["latest_closed_by_id"], name: "index_merge_request_metrics_on_latest_closed_by_id"
    t.index ["merge_request_id", "merged_at"], name: "index_merge_request_metrics_on_merge_request_id_and_merged_at", where: "(merged_at IS NOT NULL)"
    t.index ["merge_request_id"], name: "unique_merge_request_metrics_by_merge_request_id", unique: true
    t.index ["merged_at"], name: "index_merge_request_metrics_on_merged_at"
    t.index ["merged_by_id"], name: "index_merge_request_metrics_on_merged_by_id"
    t.index ["pipeline_id"], name: "index_merge_request_metrics_on_pipeline_id"
    t.index ["target_project_id", "merged_at", "created_at"], name: "index_mr_metrics_on_target_project_id_merged_at_time_to_merge", where: "(merged_at > created_at)"
    t.index ["target_project_id", "merged_at", "id"], name: "index_mr_metrics_on_target_project_id_merged_at_nulls_last", order: { merged_at: "DESC NULLS LAST", id: :desc }
    t.index ["target_project_id"], name: "index_merge_request_metrics_on_target_project_id"
    t.check_constraint "target_project_id IS NOT NULL", name: "check_e03d0900bf"
  end

  create_table "merge_request_predictions", primary_key: "merge_request_id", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.jsonb "suggested_reviewers", default: {}, null: false
    t.jsonb "accepted_reviewers", default: {}, null: false
  end

  create_table "merge_request_reviewers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "merge_request_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.integer "state", limit: 2, default: 0, null: false
    t.index ["merge_request_id", "user_id"], name: "index_merge_request_reviewers_on_merge_request_id_and_user_id", unique: true
    t.index ["user_id", "state"], name: "index_on_merge_request_reviewers_user_id_and_state", where: "(state = 2)"
    t.index ["user_id"], name: "index_merge_request_reviewers_on_user_id"
  end

  create_table "merge_request_user_mentions", force: :cascade do |t|
    t.integer "merge_request_id", null: false
    t.integer "note_id"
    t.integer "mentioned_users_ids", array: true
    t.integer "mentioned_projects_ids", array: true
    t.integer "mentioned_groups_ids", array: true
    t.index ["merge_request_id", "note_id"], name: "merge_request_user_mentions_on_mr_id_and_note_id_index", unique: true
    t.index ["merge_request_id"], name: "merge_request_user_mentions_on_mr_id_index", unique: true, where: "(note_id IS NULL)"
    t.index ["note_id"], name: "index_merge_request_user_mentions_on_note_id", unique: true, where: "(note_id IS NOT NULL)"
  end

  create_table "merge_requests", id: :serial, force: :cascade do |t|
    t.string "target_branch", null: false
    t.string "source_branch", null: false
    t.integer "source_project_id"
    t.integer "author_id"
    t.integer "assignee_id"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "milestone_id"
    t.string "merge_status", default: "unchecked", null: false
    t.integer "target_project_id", null: false
    t.integer "iid"
    t.text "description"
    t.integer "updated_by_id"
    t.text "merge_error"
    t.text "merge_params"
    t.boolean "merge_when_pipeline_succeeds", default: false, null: false
    t.integer "merge_user_id"
    t.string "merge_commit_sha"
    t.integer "approvals_before_merge"
    t.string "rebase_commit_sha"
    t.string "in_progress_merge_commit_sha"
    t.integer "lock_version", default: 0
    t.text "title_html"
    t.text "description_html"
    t.integer "time_estimate"
    t.boolean "squash", default: false, null: false
    t.integer "cached_markdown_version"
    t.datetime "last_edited_at"
    t.integer "last_edited_by_id"
    t.integer "head_pipeline_id"
    t.string "merge_jid"
    t.boolean "discussion_locked"
    t.integer "latest_merge_request_diff_id"
    t.boolean "allow_maintainer_to_push", default: true
    t.integer "state_id", limit: 2, default: 1, null: false
    t.string "rebase_jid"
    t.binary "squash_commit_sha"
    t.bigint "sprint_id"
    t.binary "merge_ref_sha"
    t.boolean "draft", default: false, null: false
    t.index ["assignee_id"], name: "index_merge_requests_on_assignee_id"
    t.index ["author_id", "created_at"], name: "index_merge_requests_on_author_id_and_created_at"
    t.index ["author_id", "id"], name: "index_merge_requests_on_author_id_and_id"
    t.index ["author_id", "target_project_id"], name: "index_merge_requests_on_author_id_and_target_project_id"
    t.index ["author_id"], name: "index_merge_requests_on_author_id"
    t.index ["created_at"], name: "index_merge_requests_on_created_at"
    t.index ["description"], name: "index_merge_requests_on_description_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["head_pipeline_id"], name: "index_merge_requests_on_head_pipeline_id"
    t.index ["id", "merge_jid"], name: "idx_merge_requests_on_id_and_merge_jid", where: "((merge_jid IS NOT NULL) AND (state_id = 4))"
    t.index ["id"], name: "idx_merge_requests_on_merged_state", where: "(state_id = 3)"
    t.index ["id"], name: "merge_request_mentions_temp_index", where: "((description ~~ '%@%'::text) OR ((title)::text ~~ '%@%'::text))"
    t.index ["id"], name: "merge_requests_state_id_temp_index", where: "(state_id = ANY (ARRAY[2, 3]))"
    t.index ["latest_merge_request_diff_id"], name: "index_merge_requests_on_latest_merge_request_diff_id"
    t.index ["merge_user_id"], name: "index_merge_requests_on_merge_user_id", where: "(merge_user_id IS NOT NULL)"
    t.index ["milestone_id"], name: "index_merge_requests_on_milestone_id"
    t.index ["source_branch"], name: "index_merge_requests_on_source_branch"
    t.index ["source_project_id", "source_branch"], name: "idx_merge_requests_on_source_project_and_branch_state_opened", where: "(state_id = 1)"
    t.index ["source_project_id", "source_branch"], name: "index_merge_requests_on_source_project_id_and_source_branch"
    t.index ["sprint_id"], name: "index_merge_requests_on_sprint_id"
    t.index ["state_id", "merge_status"], name: "idx_merge_requests_on_state_id_and_merge_status", where: "((state_id = 1) AND ((merge_status)::text = 'can_be_merged'::text))"
    t.index ["target_branch"], name: "index_merge_requests_on_target_branch"
    t.index ["target_project_id", "created_at", "id"], name: "index_merge_requests_on_target_project_id_and_created_at_and_id"
    t.index ["target_project_id", "id", "latest_merge_request_diff_id"], name: "index_on_merge_requests_for_latest_diffs", comment: "Index used to efficiently obtain the oldest merge request for a commit SHA"
    t.index ["target_project_id", "iid", "state_id"], name: "index_merge_requests_on_target_project_id_and_iid_and_state_id"
    t.index ["target_project_id", "iid"], name: "idx_merge_requests_on_target_project_id_and_iid_opened", where: "(state_id = 1)"
    t.index ["target_project_id", "iid"], name: "index_merge_requests_on_target_project_id_and_iid", unique: true
    t.index ["target_project_id", "iid"], name: "index_merge_requests_on_target_project_id_and_iid_jira_title", where: "((title)::text ~ '[A-Z][A-Z_0-9]+-\\d+'::text)"
    t.index ["target_project_id", "iid"], name: "index_merge_requests_on_target_project_id_iid_jira_description", where: "(description ~ '[A-Z][A-Z_0-9]+-\\d+'::text)"
    t.index ["target_project_id", "merge_commit_sha", "id"], name: "index_merge_requests_on_tp_id_and_merge_commit_sha_and_id"
    t.index ["target_project_id", "source_branch"], name: "index_merge_requests_on_target_project_id_and_source_branch"
    t.index ["target_project_id", "squash_commit_sha"], name: "index_merge_requests_on_target_project_id_and_squash_commit_sha"
    t.index ["target_project_id", "state_id", "created_at", "id"], name: "idx_mrs_on_target_id_and_created_at_and_state_id"
    t.index ["target_project_id", "target_branch"], name: "index_merge_requests_on_target_project_id_and_target_branch", where: "((state_id = 1) AND (merge_when_pipeline_succeeds = true))"
    t.index ["target_project_id", "updated_at", "id"], name: "index_merge_requests_on_target_project_id_and_updated_at_and_id"
    t.index ["target_project_id"], name: "idx_merge_requests_on_target_project_id_and_locked_state", where: "(state_id = 4)"
    t.index ["title"], name: "index_merge_requests_on_title_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["updated_by_id"], name: "index_merge_requests_on_updated_by_id", where: "(updated_by_id IS NOT NULL)"
    t.check_constraint "lock_version IS NOT NULL", name: "check_970d272570"
  end

  create_table "merge_requests_closing_issues", id: :serial, force: :cascade do |t|
    t.integer "merge_request_id", null: false
    t.integer "issue_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_merge_requests_closing_issues_on_issue_id"
    t.index ["merge_request_id"], name: "index_merge_requests_closing_issues_on_merge_request_id"
  end

  create_table "merge_requests_compliance_violations", force: :cascade do |t|
    t.bigint "violating_user_id", null: false
    t.bigint "merge_request_id", null: false
    t.integer "reason", limit: 2, null: false
    t.integer "severity_level", limit: 2, default: 0, null: false
    t.index ["merge_request_id", "violating_user_id", "reason"], name: "index_merge_requests_compliance_violations_unique_columns", unique: true
    t.index ["violating_user_id"], name: "index_merge_requests_compliance_violations_on_violating_user_id"
  end

  create_table "merge_trains", force: :cascade do |t|
    t.integer "merge_request_id", null: false
    t.integer "user_id", null: false
    t.integer "pipeline_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "target_project_id", null: false
    t.text "target_branch", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.datetime_with_timezone "merged_at"
    t.integer "duration"
    t.index ["merge_request_id"], name: "index_merge_trains_on_merge_request_id", unique: true
    t.index ["pipeline_id"], name: "index_merge_trains_on_pipeline_id"
    t.index ["target_project_id", "target_branch", "status"], name: "index_for_status_per_branch_per_project"
    t.index ["user_id"], name: "index_merge_trains_on_user_id"
  end

  create_table "metrics_dashboard_annotations", force: :cascade do |t|
    t.datetime_with_timezone "starting_at", null: false
    t.datetime_with_timezone "ending_at"
    t.bigint "environment_id"
    t.bigint "cluster_id"
    t.string "dashboard_path", limit: 255, null: false
    t.string "panel_xid", limit: 255
    t.text "description", null: false
    t.index "COALESCE(ending_at, starting_at)", name: "index_metrics_dashboard_annotations_on_timespan_end"
    t.index ["cluster_id", "dashboard_path", "starting_at", "ending_at"], name: "index_metrics_dashboard_annotations_on_cluster_id_and_3_columns", where: "(cluster_id IS NOT NULL)"
    t.index ["environment_id", "dashboard_path", "starting_at", "ending_at"], name: "index_metrics_dashboard_annotations_on_environment_id_and_3_col", where: "(environment_id IS NOT NULL)"
  end

  create_table "metrics_users_starred_dashboards", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.text "dashboard_path", null: false
    t.index ["project_id"], name: "index_metrics_users_starred_dashboards_on_project_id"
    t.index ["user_id", "project_id", "dashboard_path"], name: "idx_metrics_users_starred_dashboard_on_user_project_dashboard", unique: true
    t.check_constraint "char_length(dashboard_path) <= 255", name: "check_79a84a0f57"
  end

  create_table "milestone_releases", primary_key: ["milestone_id", "release_id"], force: :cascade do |t|
    t.bigint "milestone_id", null: false
    t.bigint "release_id", null: false
    t.index ["release_id"], name: "index_milestone_releases_on_release_id"
  end

  create_table "milestones", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.integer "project_id"
    t.text "description"
    t.date "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "state"
    t.integer "iid"
    t.text "title_html"
    t.text "description_html"
    t.date "start_date"
    t.integer "cached_markdown_version"
    t.integer "group_id"
    t.index ["description"], name: "index_milestones_on_description_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["due_date"], name: "index_milestones_on_due_date"
    t.index ["group_id"], name: "index_milestones_on_group_id"
    t.index ["project_id", "iid"], name: "index_milestones_on_project_id_and_iid", unique: true
    t.index ["title"], name: "index_milestones_on_title"
    t.index ["title"], name: "index_milestones_on_title_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "ml_candidate_metadata", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "candidate_id", null: false
    t.text "name", null: false
    t.text "value", null: false
    t.index ["candidate_id", "name"], name: "index_ml_candidate_metadata_on_candidate_id_and_name", unique: true
    t.index ["name"], name: "index_ml_candidate_metadata_on_name"
    t.check_constraint "char_length(name) <= 255", name: "check_6b38a286a5"
    t.check_constraint "char_length(value) <= 5000", name: "check_9453f4a8e9"
  end

  create_table "ml_candidate_metrics", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "candidate_id"
    t.float "value"
    t.integer "step"
    t.binary "is_nan"
    t.text "name", null: false
    t.bigint "tracked_at"
    t.index ["candidate_id"], name: "index_ml_candidate_metrics_on_candidate_id"
    t.check_constraint "char_length(name) <= 250", name: "check_3bb4a3fbd9"
  end

  create_table "ml_candidate_params", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "candidate_id"
    t.text "name", null: false
    t.text "value", null: false
    t.index ["candidate_id", "name"], name: "index_ml_candidate_params_on_candidate_id_on_name", unique: true
    t.index ["candidate_id"], name: "index_ml_candidate_params_on_candidate_id"
    t.check_constraint "char_length(name) <= 250", name: "check_093034d049"
    t.check_constraint "char_length(value) <= 250", name: "check_28a3c29e43"
  end

  create_table "ml_candidates", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.uuid "iid", null: false
    t.bigint "experiment_id", null: false
    t.bigint "user_id"
    t.bigint "start_time"
    t.bigint "end_time"
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["experiment_id", "iid"], name: "index_ml_candidates_on_experiment_id_and_iid", unique: true
    t.index ["user_id"], name: "index_ml_candidates_on_user_id"
  end

  create_table "ml_experiment_metadata", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "experiment_id", null: false
    t.text "name", null: false
    t.text "value", null: false
    t.index ["experiment_id", "name"], name: "index_ml_experiment_metadata_on_experiment_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_112fe5002d"
    t.check_constraint "char_length(value) <= 5000", name: "check_a91c633d68"
  end

  create_table "ml_experiments", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "iid", null: false
    t.bigint "project_id", null: false
    t.bigint "user_id"
    t.text "name", null: false
    t.datetime_with_timezone "deleted_on"
    t.index ["project_id", "iid"], name: "index_ml_experiments_on_project_id_and_iid", unique: true
    t.index ["project_id", "name"], name: "index_ml_experiments_on_project_id_and_name", unique: true
    t.index ["user_id"], name: "index_ml_experiments_on_user_id"
    t.check_constraint "char_length(name) <= 255", name: "check_ee07a0be2c"
  end

  create_table "namespace_admin_notes", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "namespace_id", null: false
    t.text "note"
    t.index ["namespace_id"], name: "index_namespace_admin_notes_on_namespace_id"
    t.check_constraint "char_length(note) <= 1000", name: "check_e9d2e71b5d"
  end

  create_table "namespace_aggregation_schedules", primary_key: "namespace_id", id: :integer, default: nil, force: :cascade do |t|
    t.index ["namespace_id"], name: "index_namespace_aggregation_schedules_on_namespace_id", unique: true
  end

  create_table "namespace_bans", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.bigint "user_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["namespace_id", "user_id"], name: "index_namespace_bans_on_namespace_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_namespace_bans_on_user_id"
  end

  create_table "namespace_ci_cd_settings", primary_key: "namespace_id", id: :bigint, default: nil, force: :cascade do |t|
    t.boolean "allow_stale_runner_pruning", default: false, null: false
    t.index ["namespace_id"], name: "index_cicd_settings_on_namespace_id_where_stale_pruning_enabled", where: "(allow_stale_runner_pruning = true)"
  end

  create_table "namespace_commit_emails", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "namespace_id", null: false
    t.bigint "email_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["email_id"], name: "index_namespace_commit_emails_on_email_id"
    t.index ["namespace_id"], name: "index_namespace_commit_emails_on_namespace_id"
    t.index ["user_id", "namespace_id"], name: "index_namespace_commit_emails_on_user_id_and_namespace_id", unique: true
  end

  create_table "namespace_details", primary_key: "namespace_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at"
    t.datetime_with_timezone "updated_at"
    t.integer "cached_markdown_version"
    t.text "description"
    t.text "description_html"
    t.datetime_with_timezone "free_user_cap_over_limt_notified_at"
    t.datetime_with_timezone "free_user_cap_over_limit_notified_at"
    t.datetime_with_timezone "dashboard_notification_at"
    t.datetime_with_timezone "dashboard_enforcement_at"
  end

  create_table "namespace_limits", primary_key: "namespace_id", id: :integer, default: nil, force: :cascade do |t|
    t.bigint "additional_purchased_storage_size", default: 0, null: false
    t.date "additional_purchased_storage_ends_on"
    t.date "temporary_storage_increase_ends_on"
  end

  create_table "namespace_package_settings", primary_key: "namespace_id", id: :bigint, default: nil, force: :cascade do |t|
    t.boolean "maven_duplicates_allowed", default: true, null: false
    t.text "maven_duplicate_exception_regex", default: "", null: false
    t.boolean "generic_duplicates_allowed", default: true, null: false
    t.text "generic_duplicate_exception_regex", default: "", null: false
    t.boolean "maven_package_requests_forwarding"
    t.boolean "lock_maven_package_requests_forwarding", default: false, null: false
    t.boolean "pypi_package_requests_forwarding"
    t.boolean "lock_pypi_package_requests_forwarding", default: false, null: false
    t.boolean "npm_package_requests_forwarding"
    t.boolean "lock_npm_package_requests_forwarding", default: false, null: false
    t.check_constraint "char_length(generic_duplicate_exception_regex) <= 255", name: "check_31340211b1"
    t.check_constraint "char_length(maven_duplicate_exception_regex) <= 255", name: "check_d63274b2b6"
  end

  create_table "namespace_root_storage_statistics", primary_key: "namespace_id", id: :integer, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "repository_size", default: 0, null: false
    t.bigint "lfs_objects_size", default: 0, null: false
    t.bigint "wiki_size", default: 0, null: false
    t.bigint "build_artifacts_size", default: 0, null: false
    t.bigint "storage_size", default: 0, null: false
    t.bigint "packages_size", default: 0, null: false
    t.bigint "snippets_size", default: 0, null: false
    t.bigint "pipeline_artifacts_size", default: 0, null: false
    t.bigint "uploads_size", default: 0, null: false
    t.bigint "dependency_proxy_size", default: 0, null: false
    t.integer "notification_level", limit: 2, default: 100, null: false
    t.bigint "container_registry_size", default: 0, null: false
    t.index ["namespace_id"], name: "index_namespace_root_storage_statistics_on_namespace_id", unique: true
  end

  create_table "namespace_settings", primary_key: "namespace_id", id: :integer, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "prevent_forking_outside_group", default: false, null: false
    t.boolean "allow_mfa_for_subgroups", default: true, null: false
    t.text "default_branch_name"
    t.boolean "repository_read_only", default: false, null: false
    t.boolean "delayed_project_removal"
    t.boolean "resource_access_token_creation_allowed", default: true, null: false
    t.boolean "lock_delayed_project_removal", default: false, null: false
    t.boolean "prevent_sharing_groups_outside_hierarchy", default: false, null: false
    t.integer "new_user_signups_cap"
    t.boolean "setup_for_company"
    t.integer "jobs_to_be_done", limit: 2
    t.integer "runner_token_expiration_interval"
    t.integer "subgroup_runner_token_expiration_interval"
    t.integer "project_runner_token_expiration_interval"
    t.boolean "show_diff_preview_in_email", default: true, null: false
    t.integer "enabled_git_access_protocol", limit: 2, default: 0, null: false
    t.integer "unique_project_download_limit", limit: 2, default: 0, null: false
    t.integer "unique_project_download_limit_interval_in_seconds", default: 0, null: false
    t.integer "project_import_level", limit: 2, default: 50, null: false
    t.text "unique_project_download_limit_allowlist", default: [], null: false, array: true
    t.boolean "auto_ban_user_on_excessive_projects_download", default: false, null: false
    t.boolean "only_allow_merge_if_pipeline_succeeds", default: false, null: false
    t.boolean "allow_merge_on_skipped_pipeline", default: false, null: false
    t.boolean "only_allow_merge_if_all_discussions_are_resolved", default: false, null: false
    t.bigint "default_compliance_framework_id"
    t.boolean "runner_registration_enabled", default: true
    t.index ["default_compliance_framework_id"], name: "idx_namespace_settings_on_default_compliance_framework_id", unique: true
    t.check_constraint "cardinality(unique_project_download_limit_allowlist) <= 100", name: "namespace_settings_unique_project_download_limit_allowlist_size"
    t.check_constraint "char_length(default_branch_name) <= 255", name: "check_0ba93c78c7"
  end

  create_table "namespace_statistics", id: :serial, force: :cascade do |t|
    t.integer "namespace_id", null: false
    t.integer "shared_runners_seconds", default: 0, null: false
    t.datetime "shared_runners_seconds_last_reset"
    t.bigint "storage_size", default: 0, null: false
    t.bigint "wiki_size", default: 0, null: false
    t.bigint "dependency_proxy_size", default: 0, null: false
    t.index ["namespace_id"], name: "index_namespace_statistics_on_namespace_id", unique: true
  end

  create_table "namespaces", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "path", null: false
    t.integer "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type", default: "User", null: false
    t.string "description", default: "", null: false
    t.string "avatar"
    t.boolean "membership_lock", default: false
    t.boolean "share_with_group_lock", default: false
    t.integer "visibility_level", default: 20, null: false
    t.boolean "request_access_enabled", default: true, null: false
    t.string "ldap_sync_status", default: "ready", null: false
    t.string "ldap_sync_error"
    t.datetime "ldap_sync_last_update_at"
    t.datetime "ldap_sync_last_successful_update_at"
    t.datetime "ldap_sync_last_sync_at"
    t.text "description_html"
    t.boolean "lfs_enabled"
    t.integer "parent_id"
    t.integer "shared_runners_minutes_limit"
    t.bigint "repository_size_limit"
    t.boolean "require_two_factor_authentication", default: false, null: false
    t.integer "two_factor_grace_period", default: 48, null: false
    t.integer "cached_markdown_version"
    t.integer "project_creation_level"
    t.string "runners_token"
    t.integer "file_template_project_id"
    t.string "saml_discovery_token"
    t.string "runners_token_encrypted"
    t.integer "custom_project_templates_group_id"
    t.boolean "auto_devops_enabled"
    t.integer "extra_shared_runners_minutes_limit"
    t.datetime_with_timezone "last_ci_minutes_notification_at"
    t.integer "last_ci_minutes_usage_notification_level"
    t.integer "subgroup_creation_level", default: 1
    t.boolean "emails_disabled"
    t.integer "max_pages_size"
    t.integer "max_artifacts_size"
    t.boolean "mentions_disabled"
    t.integer "default_branch_protection", limit: 2
    t.boolean "unlock_membership_to_ldap"
    t.integer "max_personal_access_token_lifetime"
    t.bigint "push_rule_id"
    t.boolean "shared_runners_enabled", default: true, null: false
    t.boolean "allow_descendants_override_disabled_shared_runners", default: false, null: false
    t.integer "traversal_ids", default: [], null: false, array: true
    t.index "lower((name)::text)", name: "index_on_namespaces_lower_name"
    t.index "lower((path)::text)", name: "index_on_namespaces_lower_path"
    t.index ["created_at"], name: "index_namespaces_on_created_at"
    t.index ["custom_project_templates_group_id", "type"], name: "index_namespaces_on_custom_project_templates_group_id_and_type", where: "(custom_project_templates_group_id IS NOT NULL)"
    t.index ["file_template_project_id"], name: "index_namespaces_on_file_template_project_id"
    t.index ["id"], name: "index_namespaces_on_type_and_visibility_and_parent_id", where: "(((type)::text = 'Group'::text) AND (parent_id IS NULL) AND (visibility_level <> 20))"
    t.index ["ldap_sync_last_successful_update_at"], name: "index_namespaces_on_ldap_sync_last_successful_update_at"
    t.index ["ldap_sync_last_update_at"], name: "index_namespaces_on_ldap_sync_last_update_at"
    t.index ["name", "id"], name: "index_namespaces_public_groups_name_id", where: "(((type)::text = 'Group'::text) AND (visibility_level = 20))"
    t.index ["name", "parent_id", "type"], name: "index_namespaces_name_parent_id_type", unique: true
    t.index ["name"], name: "index_namespaces_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["owner_id"], name: "index_namespaces_on_owner_id"
    t.index ["parent_id", "id"], name: "index_groups_on_parent_id_id", where: "((type)::text = 'Group'::text)"
    t.index ["parent_id", "id"], name: "index_namespaces_on_parent_id_and_id", unique: true
    t.index ["path"], name: "index_namespaces_on_path"
    t.index ["path"], name: "index_namespaces_on_path_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["push_rule_id"], name: "index_namespaces_on_push_rule_id", unique: true
    t.index ["require_two_factor_authentication"], name: "index_namespaces_on_require_two_factor_authentication"
    t.index ["runners_token"], name: "index_namespaces_on_runners_token", unique: true
    t.index ["runners_token_encrypted"], name: "index_namespaces_on_runners_token_encrypted", unique: true
    t.index ["shared_runners_minutes_limit", "extra_shared_runners_minutes_limit"], name: "index_namespaces_on_shared_and_extra_runners_minutes_limit"
    t.index ["traversal_ids"], name: "index_btree_namespaces_traversal_ids"
    t.index ["traversal_ids"], name: "index_namespaces_on_traversal_ids", using: :gin
    t.index ["traversal_ids"], name: "index_namespaces_on_traversal_ids_for_groups", where: "((type)::text = 'Group'::text)", using: :gin
    t.index ["traversal_ids"], name: "index_namespaces_on_traversal_ids_for_groups_btree", where: "((type)::text = 'Group'::text)"
    t.index ["type", "id"], name: "index_namespaces_on_type_and_id"
  end

  create_table "namespaces_sync_events", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.index ["namespace_id"], name: "index_namespaces_sync_events_on_namespace_id"
  end

  create_table "note_diff_files", id: :serial, force: :cascade do |t|
    t.integer "diff_note_id", null: false
    t.text "diff", null: false
    t.boolean "new_file", null: false
    t.boolean "renamed_file", null: false
    t.boolean "deleted_file", null: false
    t.string "a_mode", null: false
    t.string "b_mode", null: false
    t.text "new_path", null: false
    t.text "old_path", null: false
    t.index ["diff_note_id"], name: "index_note_diff_files_on_diff_note_id", unique: true
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.text "note"
    t.string "noteable_type"
    t.integer "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "project_id"
    t.string "attachment"
    t.string "line_code"
    t.string "commit_id"
    t.integer "noteable_id"
    t.boolean "system", default: false, null: false
    t.text "st_diff"
    t.integer "updated_by_id"
    t.string "type"
    t.text "position"
    t.text "original_position"
    t.datetime "resolved_at"
    t.integer "resolved_by_id"
    t.string "discussion_id"
    t.text "note_html"
    t.integer "cached_markdown_version"
    t.text "change_position"
    t.boolean "resolved_by_push"
    t.bigint "review_id"
    t.boolean "confidential"
    t.datetime_with_timezone "last_edited_at"
    t.boolean "internal", default: false, null: false
    t.index ["author_id", "created_at", "id"], name: "index_notes_on_author_id_and_created_at_and_id"
    t.index ["commit_id"], name: "index_notes_on_commit_id"
    t.index ["created_at"], name: "index_notes_on_created_at"
    t.index ["discussion_id"], name: "index_notes_on_discussion_id"
    t.index ["id", "noteable_type"], name: "note_mentions_temp_index", where: "(note ~~ '%@%'::text)"
    t.index ["id"], name: "index_notes_on_id_where_confidential", where: "(confidential = true)"
    t.index ["id"], name: "index_notes_on_id_where_internal", where: "(internal = true)"
    t.index ["line_code"], name: "index_notes_on_line_code"
    t.index ["noteable_id", "noteable_type", "system"], name: "index_notes_on_noteable_id_and_noteable_type_and_system"
    t.index ["project_id", "commit_id"], name: "index_notes_for_cherry_picked_merge_requests", where: "((noteable_type)::text = 'MergeRequest'::text)"
    t.index ["project_id", "id"], name: "index_notes_on_project_id_and_id_and_system_false", where: "(NOT system)"
    t.index ["project_id", "noteable_type"], name: "index_notes_on_project_id_and_noteable_type"
    t.index ["review_id"], name: "index_notes_on_review_id"
  end

  create_table "notification_settings", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "source_id"
    t.string "source_type"
    t.integer "level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "new_note"
    t.boolean "new_issue"
    t.boolean "reopen_issue"
    t.boolean "close_issue"
    t.boolean "reassign_issue"
    t.boolean "new_merge_request"
    t.boolean "reopen_merge_request"
    t.boolean "close_merge_request"
    t.boolean "reassign_merge_request"
    t.boolean "merge_merge_request"
    t.boolean "failed_pipeline"
    t.boolean "success_pipeline"
    t.boolean "push_to_merge_request"
    t.boolean "issue_due"
    t.boolean "new_epic"
    t.string "notification_email"
    t.boolean "fixed_pipeline"
    t.boolean "new_release"
    t.boolean "moved_project", default: true, null: false
    t.boolean "change_reviewer_merge_request"
    t.boolean "merge_when_pipeline_succeeds", default: false, null: false
    t.index ["source_id", "source_type", "level", "user_id"], name: "index_notification_settings_on_source_and_level_and_user"
    t.index ["user_id", "source_id", "source_type"], name: "index_notifications_on_user_id_and_source_id_and_source_type", unique: true
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.text "code_challenge"
    t.text "code_challenge_method"
    t.index ["resource_owner_id", "application_id", "created_at"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
    t.check_constraint "char_length(code_challenge) <= 128", name: "oauth_access_grants_code_challenge"
    t.check_constraint "char_length(code_challenge_method) <= 5", name: "oauth_access_grants_code_challenge_method"
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id", "application_id", "created_at"], name: "partial_index_user_id_app_id_created_at_token_not_revoked", where: "(revoked_at IS NULL)"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.boolean "trusted", default: false, null: false
    t.boolean "confidential", default: true, null: false
    t.boolean "expire_access_tokens", default: false, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_openid_requests", id: :serial, force: :cascade do |t|
    t.integer "access_grant_id", null: false
    t.string "nonce", null: false
    t.index ["access_grant_id"], name: "index_oauth_openid_requests_on_access_grant_id"
  end

  create_table "onboarding_progresses", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "git_pull_at"
    t.datetime_with_timezone "git_write_at"
    t.datetime_with_timezone "merge_request_created_at"
    t.datetime_with_timezone "pipeline_created_at"
    t.datetime_with_timezone "user_added_at"
    t.datetime_with_timezone "trial_started_at"
    t.datetime_with_timezone "subscription_created_at"
    t.datetime_with_timezone "required_mr_approvals_enabled_at"
    t.datetime_with_timezone "code_owners_enabled_at"
    t.datetime_with_timezone "scoped_label_created_at"
    t.datetime_with_timezone "security_scan_enabled_at"
    t.datetime_with_timezone "issue_auto_closed_at"
    t.datetime_with_timezone "repository_imported_at"
    t.datetime_with_timezone "repository_mirrored_at"
    t.datetime_with_timezone "issue_created_at"
    t.datetime_with_timezone "secure_dependency_scanning_run_at"
    t.datetime_with_timezone "secure_container_scanning_run_at"
    t.datetime_with_timezone "secure_dast_run_at"
    t.datetime_with_timezone "secure_secret_detection_run_at"
    t.datetime_with_timezone "secure_coverage_fuzzing_run_at"
    t.datetime_with_timezone "secure_cluster_image_scanning_run_at"
    t.datetime_with_timezone "secure_api_fuzzing_run_at"
    t.datetime_with_timezone "license_scanning_run_at"
    t.index "GREATEST(git_write_at, pipeline_created_at)", name: "index_onboarding_progresses_for_trial_track", where: "((git_write_at IS NOT NULL) AND (pipeline_created_at IS NOT NULL) AND (trial_started_at IS NULL))"
    t.index "GREATEST(git_write_at, pipeline_created_at, trial_started_at)", name: "index_onboarding_progresses_for_team_track", where: "((git_write_at IS NOT NULL) AND (pipeline_created_at IS NOT NULL) AND (trial_started_at IS NOT NULL) AND (user_added_at IS NULL))"
    t.index ["created_at"], name: "index_onboarding_progresses_for_create_track", where: "(git_write_at IS NULL)"
    t.index ["git_write_at"], name: "index_onboarding_progresses_for_verify_track", where: "((git_write_at IS NOT NULL) AND (pipeline_created_at IS NULL))"
    t.index ["namespace_id"], name: "index_onboarding_progresses_on_namespace_id", unique: true
  end

  create_table "operations_feature_flag_scopes", force: :cascade do |t|
    t.bigint "feature_flag_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "active", null: false
    t.string "environment_scope", default: "*", null: false
    t.jsonb "strategies", default: [{"name"=>"default", "parameters"=>{}}], null: false
    t.index ["feature_flag_id", "environment_scope"], name: "index_feature_flag_scopes_on_flag_id_and_environment_scope", unique: true
  end

  create_table "operations_feature_flags", force: :cascade do |t|
    t.integer "project_id", null: false
    t.boolean "active", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "iid", null: false
    t.integer "version", limit: 2, default: 1, null: false
    t.index ["project_id", "iid"], name: "index_operations_feature_flags_on_project_id_and_iid", unique: true
    t.index ["project_id", "name"], name: "index_operations_feature_flags_on_project_id_and_name", unique: true
  end

  create_table "operations_feature_flags_clients", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "token_encrypted"
    t.datetime_with_timezone "last_feature_flag_updated_at"
    t.index ["project_id", "token_encrypted"], name: "index_feature_flags_clients_on_project_id_and_token_encrypted", unique: true
  end

  create_table "operations_feature_flags_issues", force: :cascade do |t|
    t.bigint "feature_flag_id", null: false
    t.bigint "issue_id", null: false
    t.index ["feature_flag_id", "issue_id"], name: "index_ops_feature_flags_issues_on_feature_flag_id_and_issue_id", unique: true
    t.index ["issue_id"], name: "index_operations_feature_flags_issues_on_issue_id"
  end

  create_table "operations_scopes", force: :cascade do |t|
    t.bigint "strategy_id", null: false
    t.string "environment_scope", limit: 255, null: false
    t.index ["strategy_id", "environment_scope"], name: "index_operations_scopes_on_strategy_id_and_environment_scope", unique: true
  end

  create_table "operations_strategies", force: :cascade do |t|
    t.bigint "feature_flag_id", null: false
    t.string "name", limit: 255, null: false
    t.jsonb "parameters", default: {}, null: false
    t.index ["feature_flag_id"], name: "index_operations_strategies_on_feature_flag_id"
  end

  create_table "operations_strategies_user_lists", force: :cascade do |t|
    t.bigint "strategy_id", null: false
    t.bigint "user_list_id", null: false
    t.index ["strategy_id", "user_list_id"], name: "index_ops_strategies_user_lists_on_strategy_id_and_user_list_id", unique: true
    t.index ["user_list_id"], name: "index_operations_strategies_user_lists_on_user_list_id"
  end

  create_table "operations_user_lists", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "iid", null: false
    t.string "name", limit: 255, null: false
    t.text "user_xids", default: "", null: false
    t.index ["project_id", "iid"], name: "index_operations_user_lists_on_project_id_and_iid", unique: true
    t.index ["project_id", "name"], name: "index_operations_user_lists_on_project_id_and_name", unique: true
  end

  create_table "p_ci_builds_metadata", primary_key: ["id", "partition_id"], force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "timeout"
    t.integer "timeout_source", default: 1, null: false
    t.boolean "interruptible"
    t.jsonb "config_options"
    t.jsonb "config_variables"
    t.boolean "has_exposed_artifacts"
    t.string "environment_auto_stop_in", limit: 255
    t.string "expanded_environment_name", limit: 255
    t.jsonb "secrets", default: {}, null: false
    t.bigint "build_id", null: false
    t.bigint "id", default: -> { "nextval('ci_builds_metadata_id_seq'::regclass)" }, null: false
    t.jsonb "runtime_runner_features", default: {}, null: false
    t.jsonb "id_tokens", default: {}, null: false
    t.bigint "partition_id", default: 100, null: false
    t.boolean "debug_trace_enabled", default: false, null: false
    t.index ["build_id", "id"], name: "p_ci_builds_metadata_build_id_id_idx", where: "(interruptible = true)"
    t.index ["build_id", "partition_id"], name: "p_ci_builds_metadata_build_id_partition_id_idx", unique: true
    t.index ["build_id"], name: "p_ci_builds_metadata_build_id_idx", where: "(has_exposed_artifacts IS TRUE)"
    t.index ["id", "partition_id"], name: "p_ci_builds_metadata_id_partition_id_idx", unique: true
    t.index ["project_id"], name: "p_ci_builds_metadata_project_id_idx"
  end

  create_table "packages_build_infos", force: :cascade do |t|
    t.integer "package_id", null: false
    t.integer "pipeline_id"
    t.index ["package_id", "pipeline_id", "id"], name: "index_packages_build_infos_package_id_pipeline_id_id"
    t.index ["pipeline_id"], name: "index_packages_build_infos_on_pipeline_id"
  end

  create_table "packages_cleanup_policies", primary_key: "project_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "next_run_at"
    t.text "keep_n_duplicated_package_files", default: "all", null: false
    t.index ["next_run_at", "project_id"], name: "idx_enabled_pkgs_cleanup_policies_on_next_run_at_project_id", where: "(keep_n_duplicated_package_files <> 'all'::text)"
    t.check_constraint "char_length(keep_n_duplicated_package_files) <= 255", name: "check_e53f35ab7b"
  end

  create_table "packages_composer_cache_files", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "delete_at"
    t.integer "namespace_id"
    t.integer "file_store", limit: 2, default: 1, null: false
    t.text "file", null: false
    t.binary "file_sha256", null: false
    t.index ["delete_at", "id"], name: "composer_cache_files_index_on_deleted_at"
    t.index ["id"], name: "index_composer_cache_files_where_namespace_id_is_null", where: "(namespace_id IS NULL)"
    t.index ["namespace_id", "file_sha256"], name: "index_packages_composer_cache_namespace_and_sha", unique: true
    t.check_constraint "char_length(file) <= 255", name: "check_84f5ba81f5"
  end

  create_table "packages_composer_metadata", primary_key: "package_id", id: :bigint, default: nil, force: :cascade do |t|
    t.binary "target_sha", null: false
    t.jsonb "composer_json", default: {}, null: false
    t.binary "version_cache_sha"
    t.index ["package_id", "target_sha"], name: "index_packages_composer_metadata_on_package_id_and_target_sha", unique: true
  end

  create_table "packages_conan_file_metadata", force: :cascade do |t|
    t.bigint "package_file_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "recipe_revision", limit: 255, default: "0", null: false
    t.string "package_revision", limit: 255
    t.string "conan_package_reference", limit: 255
    t.integer "conan_file_type", limit: 2, null: false
    t.index ["package_file_id"], name: "index_packages_conan_file_metadata_on_package_file_id", unique: true
  end

  create_table "packages_conan_metadata", force: :cascade do |t|
    t.bigint "package_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "package_username", limit: 255, null: false
    t.string "package_channel", limit: 255, null: false
    t.index ["package_id", "package_username", "package_channel"], name: "index_packages_conan_metadata_on_package_id_username_channel", unique: true
  end

  create_table "packages_debian_file_metadata", primary_key: "package_file_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "file_type", limit: 2, null: false
    t.text "component"
    t.text "architecture"
    t.jsonb "fields"
    t.check_constraint "char_length(architecture) <= 255", name: "check_e6e1fffcca"
    t.check_constraint "char_length(component) <= 255", name: "check_2ebedda4b6"
  end

  create_table "packages_debian_group_architectures", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "distribution_id", null: false
    t.text "name", null: false
    t.index ["distribution_id", "name"], name: "uniq_pkgs_deb_grp_architectures_on_distribution_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_ddb220164a"
  end

  create_table "packages_debian_group_component_files", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "component_id", null: false
    t.bigint "architecture_id"
    t.integer "size", null: false
    t.integer "file_type", limit: 2, null: false
    t.integer "compression_type", limit: 2
    t.integer "file_store", limit: 2, default: 1, null: false
    t.text "file", null: false
    t.binary "file_md5", null: false
    t.binary "file_sha256", null: false
    t.index ["architecture_id"], name: "idx_packages_debian_group_component_files_on_architecture_id"
    t.index ["component_id"], name: "index_packages_debian_group_component_files_on_component_id"
    t.check_constraint "char_length(file) <= 255", name: "check_839e1685bc"
  end

  create_table "packages_debian_group_components", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "distribution_id", null: false
    t.text "name", null: false
    t.index ["distribution_id", "name"], name: "uniq_pkgs_deb_grp_components_on_distribution_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_a9bc7d85be"
  end

  create_table "packages_debian_group_distribution_keys", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "distribution_id", null: false
    t.text "encrypted_private_key", null: false
    t.text "encrypted_private_key_iv", null: false
    t.text "encrypted_passphrase", null: false
    t.text "encrypted_passphrase_iv", null: false
    t.text "public_key", null: false
    t.text "fingerprint", null: false
    t.index ["distribution_id"], name: "idx_pkgs_debian_group_distribution_keys_on_distribution_id"
    t.check_constraint "char_length(fingerprint) <= 255", name: "check_bc95dc3fbe"
    t.check_constraint "char_length(public_key) <= 524288", name: "check_f708183491"
  end

  create_table "packages_debian_group_distributions", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "group_id", null: false
    t.bigint "creator_id"
    t.integer "valid_time_duration_seconds"
    t.integer "file_store", limit: 2, default: 1, null: false
    t.boolean "automatic", default: true, null: false
    t.boolean "automatic_upgrades", default: false, null: false
    t.text "codename", null: false
    t.text "suite"
    t.text "origin"
    t.text "label"
    t.text "version"
    t.text "description"
    t.text "file"
    t.text "file_signature"
    t.text "signed_file"
    t.integer "signed_file_store", limit: 2, default: 1, null: false
    t.index ["creator_id"], name: "index_packages_debian_group_distributions_on_creator_id"
    t.index ["group_id", "codename"], name: "uniq_pkgs_debian_group_distributions_group_id_and_codename", unique: true
    t.index ["group_id", "suite"], name: "uniq_pkgs_debian_group_distributions_group_id_and_suite", unique: true
    t.index ["group_id"], name: "index_packages_debian_group_distributions_on_group_id"
    t.check_constraint "char_length(codename) <= 255", name: "check_590e18405a"
    t.check_constraint "char_length(description) <= 255", name: "check_310ac457b8"
    t.check_constraint "char_length(file) <= 255", name: "check_be5ed8d307"
    t.check_constraint "char_length(file_signature) <= 4096", name: "check_3d6f87fc31"
    t.check_constraint "char_length(label) <= 255", name: "check_d3244bfc0b"
    t.check_constraint "char_length(origin) <= 255", name: "check_b057cd840a"
    t.check_constraint "char_length(signed_file) <= 255", name: "check_0007e0bf61"
    t.check_constraint "char_length(suite) <= 255", name: "check_e7c928a24b"
    t.check_constraint "char_length(version) <= 255", name: "check_3fdadf4a0c"
  end

  create_table "packages_debian_project_architectures", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "distribution_id", null: false
    t.text "name", null: false
    t.index ["distribution_id", "name"], name: "uniq_pkgs_deb_proj_architectures_on_distribution_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_9c2e1c99d8"
  end

  create_table "packages_debian_project_component_files", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "component_id", null: false
    t.bigint "architecture_id"
    t.integer "size", null: false
    t.integer "file_type", limit: 2, null: false
    t.integer "compression_type", limit: 2
    t.integer "file_store", limit: 2, default: 1, null: false
    t.text "file", null: false
    t.binary "file_md5", null: false
    t.binary "file_sha256", null: false
    t.index ["architecture_id"], name: "idx_packages_debian_project_component_files_on_architecture_id"
    t.index ["component_id"], name: "index_packages_debian_project_component_files_on_component_id"
    t.check_constraint "char_length(file) <= 255", name: "check_e5af03fa2d"
  end

  create_table "packages_debian_project_components", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "distribution_id", null: false
    t.text "name", null: false
    t.index ["distribution_id", "name"], name: "uniq_pkgs_deb_proj_components_on_distribution_id_and_name", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_517559f298"
  end

  create_table "packages_debian_project_distribution_keys", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "distribution_id", null: false
    t.text "encrypted_private_key", null: false
    t.text "encrypted_private_key_iv", null: false
    t.text "encrypted_passphrase", null: false
    t.text "encrypted_passphrase_iv", null: false
    t.text "public_key", null: false
    t.text "fingerprint", null: false
    t.index ["distribution_id"], name: "idx_pkgs_debian_project_distribution_keys_on_distribution_id"
    t.check_constraint "char_length(fingerprint) <= 255", name: "check_9e8a5eef0a"
    t.check_constraint "char_length(public_key) <= 524288", name: "check_d188f6547f"
  end

  create_table "packages_debian_project_distributions", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.bigint "creator_id"
    t.integer "valid_time_duration_seconds"
    t.integer "file_store", limit: 2, default: 1, null: false
    t.boolean "automatic", default: true, null: false
    t.boolean "automatic_upgrades", default: false, null: false
    t.text "codename", null: false
    t.text "suite"
    t.text "origin"
    t.text "label"
    t.text "version"
    t.text "description"
    t.text "file"
    t.text "file_signature"
    t.text "signed_file"
    t.integer "signed_file_store", limit: 2, default: 1, null: false
    t.index ["creator_id"], name: "index_packages_debian_project_distributions_on_creator_id"
    t.index ["project_id", "codename"], name: "uniq_pkgs_debian_project_distributions_project_id_and_codename", unique: true
    t.index ["project_id", "suite"], name: "uniq_pkgs_debian_project_distributions_project_id_and_suite", unique: true
    t.index ["project_id"], name: "index_packages_debian_project_distributions_on_project_id"
    t.check_constraint "char_length(codename) <= 255", name: "check_834dabadb6"
    t.check_constraint "char_length(description) <= 255", name: "check_b93154339f"
    t.check_constraint "char_length(file) <= 255", name: "check_cb4ac9599e"
    t.check_constraint "char_length(file_signature) <= 4096", name: "check_a5a2ac6af2"
    t.check_constraint "char_length(label) <= 255", name: "check_6f6b55a4c4"
    t.check_constraint "char_length(origin) <= 255", name: "check_6177ccd4a6"
    t.check_constraint "char_length(signed_file) <= 255", name: "check_9e5e22b7ff"
    t.check_constraint "char_length(suite) <= 255", name: "check_a56ae58a17"
    t.check_constraint "char_length(version) <= 255", name: "check_96965792c2"
  end

  create_table "packages_debian_publications", force: :cascade do |t|
    t.bigint "package_id", null: false
    t.bigint "distribution_id", null: false
    t.index ["distribution_id"], name: "index_packages_debian_publications_on_distribution_id"
    t.index ["package_id"], name: "index_packages_debian_publications_on_package_id", unique: true
  end

  create_table "packages_dependencies", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "version_pattern", limit: 255, null: false
    t.index ["name", "version_pattern"], name: "index_packages_dependencies_on_name_and_version_pattern", unique: true
  end

  create_table "packages_dependency_links", force: :cascade do |t|
    t.bigint "package_id", null: false
    t.bigint "dependency_id", null: false
    t.integer "dependency_type", limit: 2, null: false
    t.index ["dependency_id"], name: "index_packages_dependency_links_on_dependency_id"
    t.index ["package_id", "dependency_id", "dependency_type"], name: "idx_pkgs_dep_links_on_pkg_id_dependency_id_dependency_type", unique: true
  end

  create_table "packages_events", force: :cascade do |t|
    t.integer "event_type", limit: 2, null: false
    t.integer "event_scope", limit: 2, null: false
    t.integer "originator_type", limit: 2, null: false
    t.bigint "originator"
    t.datetime_with_timezone "created_at", null: false
    t.bigint "package_id"
    t.index ["package_id"], name: "index_packages_events_on_package_id"
  end

  create_table "packages_helm_file_metadata", primary_key: "package_file_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "channel", null: false
    t.jsonb "metadata"
    t.index ["channel"], name: "index_packages_helm_file_metadata_on_channel"
    t.index ["package_file_id", "channel"], name: "index_packages_helm_file_metadata_on_pf_id_and_channel"
    t.check_constraint "char_length(channel) <= 255", name: "check_06e8d100af"
  end

  create_table "packages_maven_metadata", force: :cascade do |t|
    t.bigint "package_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "app_group", null: false
    t.string "app_name", null: false
    t.string "app_version"
    t.string "path", limit: 512, null: false
    t.index ["package_id", "path"], name: "index_packages_maven_metadata_on_package_id_and_path"
    t.index ["path"], name: "index_packages_maven_metadata_on_path"
  end

  create_table "packages_npm_metadata", primary_key: "package_id", id: :bigint, default: nil, force: :cascade do |t|
    t.jsonb "package_json", default: {}, null: false
    t.check_constraint "char_length((package_json)::text) < 20000"
  end

  create_table "packages_nuget_dependency_link_metadata", primary_key: "dependency_link_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "target_framework", null: false
    t.index ["dependency_link_id"], name: "index_packages_nuget_dl_metadata_on_dependency_link_id"
    t.check_constraint "char_length(target_framework) <= 255", name: "packages_nuget_dependency_link_metadata_target_framework_constr"
  end

  create_table "packages_nuget_metadata", primary_key: "package_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "license_url"
    t.text "project_url"
    t.text "icon_url"
    t.check_constraint "char_length(icon_url) <= 255", name: "packages_nuget_metadata_icon_url_constraint"
    t.check_constraint "char_length(license_url) <= 255", name: "packages_nuget_metadata_license_url_constraint"
    t.check_constraint "char_length(project_url) <= 255", name: "packages_nuget_metadata_project_url_constraint"
  end

  create_table "packages_package_file_build_infos", force: :cascade do |t|
    t.bigint "package_file_id", null: false
    t.bigint "pipeline_id"
    t.index ["package_file_id"], name: "index_packages_package_file_build_infos_on_package_file_id"
    t.index ["pipeline_id"], name: "index_packages_package_file_build_infos_on_pipeline_id"
  end

  create_table "packages_package_files", force: :cascade do |t|
    t.bigint "package_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "size"
    t.integer "file_store", default: 1
    t.binary "file_md5"
    t.binary "file_sha1"
    t.string "file_name", null: false
    t.text "file", null: false
    t.binary "file_sha256"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.string "verification_failure", limit: 255
    t.integer "verification_retry_count"
    t.binary "verification_checksum"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.datetime_with_timezone "verification_started_at"
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["file_store"], name: "index_packages_package_files_on_file_store"
    t.index ["id"], name: "index_packages_package_files_on_id_for_cleanup", where: "(status = 1)"
    t.index ["package_id", "file_name"], name: "index_packages_package_files_on_package_id_and_file_name"
    t.index ["package_id", "id", "file_name"], name: "idx_pkgs_installable_package_files_on_package_id_id_file_name", where: "(status = 0)"
    t.index ["package_id", "id"], name: "index_packages_package_files_on_package_id_id"
    t.index ["package_id", "status", "id"], name: "index_packages_package_files_on_package_id_status_and_id"
    t.index ["status"], name: "index_packages_package_files_on_status"
    t.index ["verification_retry_at"], name: "packages_packages_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_packages_package_files_on_verification_state"
    t.index ["verification_state"], name: "packages_packages_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verified_at"], name: "packages_packages_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "file_store IS NOT NULL", name: "check_4c5e6bb0b3"
  end

  create_table "packages_packages", force: :cascade do |t|
    t.integer "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "name", null: false
    t.string "version"
    t.integer "package_type", limit: 2, null: false
    t.integer "creator_id"
    t.integer "status", limit: 2, default: 0, null: false
    t.datetime_with_timezone "last_downloaded_at"
    t.index "project_id, lower((version)::text)", name: "index_packages_packages_on_project_id_and_lower_version", where: "(package_type = 4)"
    t.index ["creator_id"], name: "index_packages_packages_on_creator_id"
    t.index ["id", "created_at"], name: "index_packages_packages_on_id_and_created_at"
    t.index ["name"], name: "index_packages_packages_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["name"], name: "package_name_index"
    t.index ["project_id", "created_at"], name: "index_packages_packages_on_project_id_and_created_at"
    t.index ["project_id", "id"], name: "idx_installable_conan_pkgs_on_project_id_id", where: "((package_type = 3) AND (status = ANY (ARRAY[0, 1])))"
    t.index ["project_id", "id"], name: "idx_installable_helm_pkgs_on_project_id_id"
    t.index ["project_id", "id"], name: "index_packages_on_available_pypi_packages", where: "((status = ANY (ARRAY[0, 1])) AND (package_type = 5) AND (version IS NOT NULL))"
    t.index ["project_id", "name", "version", "id"], name: "idx_installable_npm_pkgs_on_project_id_name_version_id", where: "((package_type = 2) AND (status = 0))"
    t.index ["project_id", "name", "version", "package_type"], name: "idx_packages_packages_on_project_id_name_version_package_type"
    t.index ["project_id", "name", "version"], name: "idx_packages_on_project_id_name_version_unique_when_generic", unique: true, where: "((package_type = 7) AND (status <> 4))"
    t.index ["project_id", "name", "version"], name: "idx_packages_on_project_id_name_version_unique_when_golang", unique: true, where: "((package_type = 8) AND (status <> 4))"
    t.index ["project_id", "name", "version"], name: "idx_packages_on_project_id_name_version_unique_when_helm", unique: true, where: "((package_type = 11) AND (status <> 4))"
    t.index ["project_id", "name"], name: "index_packages_project_id_name_partial_for_nuget", where: "(((name)::text <> 'NuGet.Temporary.Package'::text) AND (version IS NOT NULL) AND (package_type = 4))"
    t.index ["project_id", "package_type"], name: "index_packages_packages_on_project_id_and_package_type"
    t.index ["project_id", "status", "id"], name: "index_packages_packages_on_project_id_and_status_and_id"
    t.index ["project_id", "version"], name: "index_packages_packages_on_project_id_and_version"
  end

  create_table "packages_pypi_metadata", primary_key: "package_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "required_python", default: ""
    t.check_constraint "char_length(required_python) <= 255", name: "check_379019d5da"
    t.check_constraint "required_python IS NOT NULL", name: "check_0d9aed55b2"
  end

  create_table "packages_rpm_metadata", primary_key: "package_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "release", default: "1", null: false
    t.text "summary", default: "", null: false
    t.text "description", default: "", null: false
    t.text "arch", default: "", null: false
    t.text "license"
    t.text "url"
    t.integer "epoch", default: 0, null: false
    t.index ["package_id"], name: "index_packages_rpm_metadata_on_package_id"
    t.check_constraint "char_length(arch) <= 255", name: "check_3798bae3d6"
    t.check_constraint "char_length(description) <= 5000", name: "check_5d29ba59ac"
    t.check_constraint "char_length(license) <= 1000", name: "check_845ba4d7d0"
    t.check_constraint "char_length(release) <= 128", name: "check_c3e2fc2e89"
    t.check_constraint "char_length(summary) <= 1000", name: "check_b010bf4870"
    t.check_constraint "char_length(url) <= 1000", name: "check_6e8cbd536d"
  end

  create_table "packages_rpm_repository_files", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.integer "file_store", default: 1
    t.integer "status", limit: 2, default: 0, null: false
    t.integer "size"
    t.binary "file_md5"
    t.binary "file_sha1"
    t.binary "file_sha256"
    t.text "file", null: false
    t.text "file_name", null: false
    t.index ["project_id", "file_name"], name: "index_packages_rpm_repository_files_on_project_id_and_file_name"
    t.check_constraint "char_length(file) <= 255", name: "check_a9fef187f5"
    t.check_constraint "char_length(file_name) <= 255", name: "check_b6b721b275"
  end

  create_table "packages_rubygems_metadata", primary_key: "package_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "authors"
    t.text "files"
    t.text "summary"
    t.text "description"
    t.text "email"
    t.text "homepage"
    t.text "licenses"
    t.text "metadata"
    t.text "author"
    t.text "bindir"
    t.text "cert_chain"
    t.text "executables"
    t.text "extensions"
    t.text "extra_rdoc_files"
    t.text "platform"
    t.text "post_install_message"
    t.text "rdoc_options"
    t.text "require_paths"
    t.text "required_ruby_version"
    t.text "required_rubygems_version"
    t.text "requirements"
    t.text "rubygems_version"
    t.text "signing_key"
    t.check_constraint "char_length(author) <= 255", name: "check_b7b296b420"
    t.check_constraint "char_length(authors) <= 255", name: "check_994b68eb64"
    t.check_constraint "char_length(bindir) <= 255", name: "check_9824fc9efc"
    t.check_constraint "char_length(cert_chain) <= 255", name: "check_6ff3abe325"
    t.check_constraint "char_length(description) <= 1024", name: "check_0154a18c82"
    t.check_constraint "char_length(email) <= 255", name: "check_22814c771b"
    t.check_constraint "char_length(executables) <= 255", name: "check_5988451714"
    t.check_constraint "char_length(extensions) <= 255", name: "check_242293030e"
    t.check_constraint "char_length(extra_rdoc_files) <= 255", name: "check_6ac7043c50"
    t.check_constraint "char_length(files) <= 255", name: "check_b0f4f8c853"
    t.check_constraint "char_length(homepage) <= 255", name: "check_946cb96acb"
    t.check_constraint "char_length(licenses) <= 255", name: "check_7cb01436df"
    t.check_constraint "char_length(metadata) <= 30000", name: "check_ea02f4800f"
    t.check_constraint "char_length(platform) <= 255", name: "check_5f9c84ea17"
    t.check_constraint "char_length(post_install_message) <= 255", name: "check_3d1b6f3a39"
    t.check_constraint "char_length(rdoc_options) <= 255", name: "check_bf16b21a47"
    t.check_constraint "char_length(require_paths) <= 255", name: "check_f76bad1a9a"
    t.check_constraint "char_length(required_ruby_version) <= 255", name: "check_ca641a3354"
    t.check_constraint "char_length(required_rubygems_version) <= 255", name: "check_545f7606f9"
    t.check_constraint "char_length(requirements) <= 255", name: "check_64f1cecf05"
    t.check_constraint "char_length(rubygems_version) <= 255", name: "check_27619a7922"
    t.check_constraint "char_length(signing_key) <= 255", name: "check_9d42fa48ae"
    t.check_constraint "char_length(summary) <= 1024", name: "check_8be21d92e7"
  end

  create_table "packages_tags", force: :cascade do |t|
    t.integer "package_id", null: false
    t.string "name", limit: 255, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["package_id", "updated_at"], name: "index_packages_tags_on_package_id_and_updated_at", order: { updated_at: :desc }
    t.index ["package_id"], name: "index_packages_tags_on_package_id"
  end

  create_table "pages_deployment_states", primary_key: "pages_deployment_id", force: :cascade do |t|
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_retry_count", limit: 2
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.index ["pages_deployment_id"], name: "index_pages_deployment_states_on_pages_deployment_id"
    t.index ["verification_retry_at"], name: "index_pages_deployment_states_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_pages_deployment_states_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_pages_deployment_states_on_verification_state"
    t.index ["verified_at"], name: "index_pages_deployment_states_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_15217e8c3a"
  end

  create_table "pages_deployments", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.bigint "ci_build_id"
    t.integer "file_store", limit: 2, null: false
    t.text "file", null: false
    t.integer "file_count", null: false
    t.binary "file_sha256", null: false
    t.bigint "size"
    t.index ["ci_build_id"], name: "index_pages_deployments_on_ci_build_id"
    t.index ["file_store", "id"], name: "index_pages_deployments_on_file_store_and_id"
    t.index ["project_id"], name: "index_pages_deployments_on_project_id"
    t.check_constraint "char_length(file) <= 255", name: "check_f0fe8032dd"
    t.check_constraint "size IS NOT NULL", name: "check_5f9132a958"
  end

  create_table "pages_domain_acme_orders", force: :cascade do |t|
    t.integer "pages_domain_id", null: false
    t.datetime_with_timezone "expires_at", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "url", null: false
    t.string "challenge_token", null: false
    t.text "challenge_file_content", null: false
    t.text "encrypted_private_key", null: false
    t.text "encrypted_private_key_iv", null: false
    t.index ["challenge_token"], name: "index_pages_domain_acme_orders_on_challenge_token"
    t.index ["pages_domain_id"], name: "index_pages_domain_acme_orders_on_pages_domain_id"
  end

  create_table "pages_domains", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.text "certificate"
    t.text "encrypted_key"
    t.string "encrypted_key_iv"
    t.string "encrypted_key_salt"
    t.string "domain"
    t.datetime_with_timezone "verified_at"
    t.string "verification_code", null: false
    t.datetime_with_timezone "enabled_until"
    t.datetime_with_timezone "remove_at"
    t.boolean "auto_ssl_enabled", default: false, null: false
    t.datetime_with_timezone "certificate_valid_not_before"
    t.datetime_with_timezone "certificate_valid_not_after"
    t.integer "certificate_source", limit: 2, default: 0, null: false
    t.boolean "wildcard", default: false, null: false
    t.integer "usage", limit: 2, default: 0, null: false
    t.integer "scope", limit: 2, default: 2, null: false
    t.boolean "auto_ssl_failed", default: false, null: false
    t.index "lower((domain)::text)", name: "index_pages_domains_on_domain_lowercase"
    t.index ["certificate_valid_not_after"], name: "index_pages_domains_need_auto_ssl_renewal_valid_not_after", where: "((auto_ssl_enabled = true) AND (auto_ssl_failed = false))"
    t.index ["domain", "wildcard"], name: "index_pages_domains_on_domain_and_wildcard", unique: true
    t.index ["id"], name: "index_pages_domains_need_auto_ssl_renewal_user_provided", where: "((auto_ssl_enabled = true) AND (auto_ssl_failed = false) AND (certificate_source = 0))"
    t.index ["project_id", "enabled_until"], name: "index_pages_domains_on_project_id_and_enabled_until"
    t.index ["project_id"], name: "index_pages_domains_on_project_id"
    t.index ["remove_at"], name: "index_pages_domains_on_remove_at"
    t.index ["scope"], name: "index_pages_domains_on_scope"
    t.index ["usage"], name: "index_pages_domains_on_usage"
    t.index ["verified_at", "enabled_until"], name: "index_pages_domains_on_verified_at_and_enabled_until"
    t.index ["verified_at"], name: "index_pages_domains_on_verified_at"
    t.index ["wildcard"], name: "index_pages_domains_on_wildcard"
  end

  create_table "path_locks", id: :serial, force: :cascade do |t|
    t.string "path", null: false
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["path"], name: "index_path_locks_on_path"
    t.index ["project_id"], name: "index_path_locks_on_project_id"
    t.index ["user_id"], name: "index_path_locks_on_user_id"
  end

  create_table "personal_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.boolean "revoked", default: false
    t.date "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scopes", default: "--- []\n", null: false
    t.boolean "impersonation", default: false, null: false
    t.string "token_digest"
    t.boolean "expire_notification_delivered", default: false, null: false
    t.datetime_with_timezone "last_used_at"
    t.boolean "after_expiry_notification_delivered", default: false, null: false
    t.index ["id", "created_at"], name: "index_personal_access_tokens_on_id_and_created_at"
    t.index ["id", "expires_at"], name: "index_expired_and_not_notified_personal_access_tokens", where: "((impersonation = false) AND (revoked = false) AND (expire_notification_delivered = false))"
    t.index ["token_digest"], name: "index_personal_access_tokens_on_token_digest", unique: true
    t.index ["user_id", "expires_at"], name: "index_pat_on_user_id_and_expires_at"
    t.index ["user_id"], name: "index_personal_access_tokens_on_user_id"
  end

  create_table "plan_limits", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.integer "ci_active_pipelines", default: 0, null: false
    t.integer "ci_pipeline_size", default: 0, null: false
    t.integer "ci_active_jobs", default: 0, null: false
    t.integer "project_hooks", default: 100, null: false
    t.integer "group_hooks", default: 50, null: false
    t.integer "ci_project_subscriptions", default: 2, null: false
    t.integer "ci_pipeline_schedules", default: 10, null: false
    t.integer "offset_pagination_limit", default: 50000, null: false
    t.integer "ci_instance_level_variables", default: 25, null: false
    t.integer "storage_size_limit", default: 0, null: false
    t.integer "ci_max_artifact_size_lsif", default: 100, null: false
    t.integer "ci_max_artifact_size_archive", default: 0, null: false
    t.integer "ci_max_artifact_size_metadata", default: 0, null: false
    t.integer "ci_max_artifact_size_trace", default: 0, null: false
    t.integer "ci_max_artifact_size_junit", default: 0, null: false
    t.integer "ci_max_artifact_size_sast", default: 0, null: false
    t.integer "ci_max_artifact_size_dependency_scanning", default: 350, null: false
    t.integer "ci_max_artifact_size_container_scanning", default: 150, null: false
    t.integer "ci_max_artifact_size_dast", default: 0, null: false
    t.integer "ci_max_artifact_size_codequality", default: 0, null: false
    t.integer "ci_max_artifact_size_license_management", default: 0, null: false
    t.integer "ci_max_artifact_size_license_scanning", default: 100, null: false
    t.integer "ci_max_artifact_size_performance", default: 0, null: false
    t.integer "ci_max_artifact_size_metrics", default: 0, null: false
    t.integer "ci_max_artifact_size_metrics_referee", default: 0, null: false
    t.integer "ci_max_artifact_size_network_referee", default: 0, null: false
    t.integer "ci_max_artifact_size_dotenv", default: 0, null: false
    t.integer "ci_max_artifact_size_cobertura", default: 0, null: false
    t.integer "ci_max_artifact_size_terraform", default: 5, null: false
    t.integer "ci_max_artifact_size_accessibility", default: 0, null: false
    t.integer "ci_max_artifact_size_cluster_applications", default: 0, null: false
    t.integer "ci_max_artifact_size_secret_detection", default: 0, null: false
    t.integer "ci_max_artifact_size_requirements", default: 0, null: false
    t.integer "ci_max_artifact_size_coverage_fuzzing", default: 0, null: false
    t.integer "ci_max_artifact_size_browser_performance", default: 0, null: false
    t.integer "ci_max_artifact_size_load_performance", default: 0, null: false
    t.integer "ci_needs_size_limit", default: 50, null: false
    t.bigint "conan_max_file_size", default: 3221225472, null: false
    t.bigint "maven_max_file_size", default: 3221225472, null: false
    t.bigint "npm_max_file_size", default: 524288000, null: false
    t.bigint "nuget_max_file_size", default: 524288000, null: false
    t.bigint "pypi_max_file_size", default: 3221225472, null: false
    t.bigint "generic_packages_max_file_size", default: 5368709120, null: false
    t.bigint "golang_max_file_size", default: 104857600, null: false
    t.bigint "debian_max_file_size", default: 3221225472, null: false
    t.integer "project_feature_flags", default: 200, null: false
    t.integer "ci_max_artifact_size_api_fuzzing", default: 0, null: false
    t.integer "ci_pipeline_deployments", default: 500, null: false
    t.integer "pull_mirror_interval_seconds", default: 300, null: false
    t.integer "daily_invites", default: 0, null: false
    t.bigint "rubygems_max_file_size", default: 3221225472, null: false
    t.bigint "terraform_module_max_file_size", default: 1073741824, null: false
    t.bigint "helm_max_file_size", default: 5242880, null: false
    t.integer "ci_registered_group_runners", default: 1000, null: false
    t.integer "ci_registered_project_runners", default: 1000, null: false
    t.integer "web_hook_calls", default: 0, null: false
    t.integer "ci_daily_pipeline_schedule_triggers", default: 0, null: false
    t.integer "ci_max_artifact_size_running_container_scanning", default: 0, null: false
    t.integer "ci_max_artifact_size_cluster_image_scanning", default: 0, null: false
    t.integer "ci_jobs_trace_size_limit", default: 100, null: false
    t.integer "pages_file_entries", default: 200000, null: false
    t.integer "dast_profile_schedules", default: 1, null: false
    t.integer "external_audit_event_destinations", default: 5, null: false
    t.integer "dotenv_variables", default: 20, null: false
    t.integer "dotenv_size", default: 5120, null: false
    t.integer "pipeline_triggers", default: 25000, null: false
    t.integer "project_ci_secure_files", default: 100, null: false
    t.bigint "repository_size", default: 0, null: false
    t.integer "security_policy_scan_execution_schedules", default: 0, null: false
    t.integer "web_hook_calls_mid", default: 0, null: false
    t.integer "web_hook_calls_low", default: 0, null: false
    t.integer "project_ci_variables", default: 200, null: false
    t.integer "group_ci_variables", default: 200, null: false
    t.integer "ci_max_artifact_size_cyclonedx", default: 1, null: false
    t.bigint "rpm_max_file_size", default: 5368709120, null: false
    t.index ["plan_id"], name: "index_plan_limits_on_plan_id", unique: true
  end

  create_table "plans", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "title"
    t.index ["name"], name: "index_plans_on_name", unique: true
  end

  create_table "pm_licenses", force: :cascade do |t|
    t.text "spdx_identifier", null: false
    t.index ["spdx_identifier"], name: "i_pm_licenses_on_spdx_identifier", unique: true
    t.check_constraint "char_length(spdx_identifier) <= 50", name: "check_c1eb81d1ba"
  end

  create_table "pm_package_version_licenses", primary_key: ["pm_package_version_id", "pm_license_id"], force: :cascade do |t|
    t.bigint "pm_package_version_id", null: false
    t.bigint "pm_license_id", null: false
    t.index ["pm_license_id"], name: "index_pm_package_version_licenses_on_pm_license_id"
    t.index ["pm_package_version_id"], name: "index_pm_package_version_licenses_on_pm_package_version_id"
  end

  create_table "pm_package_versions", force: :cascade do |t|
    t.bigint "pm_package_id"
    t.text "version", null: false
    t.index ["pm_package_id", "version"], name: "i_pm_package_versions_on_package_id_and_version", unique: true
    t.index ["pm_package_id"], name: "index_pm_package_versions_on_pm_package_id"
    t.check_constraint "char_length(version) <= 255", name: "check_2d8a88cfcc"
  end

  create_table "pm_packages", force: :cascade do |t|
    t.integer "purl_type", limit: 2, null: false
    t.text "name", null: false
    t.index ["purl_type", "name"], name: "i_pm_packages_purl_type_and_name", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_3a3aedb8ba"
  end

  create_table "pool_repositories", force: :cascade do |t|
    t.integer "shard_id", null: false
    t.string "disk_path"
    t.string "state"
    t.integer "source_project_id"
    t.index ["disk_path"], name: "index_pool_repositories_on_disk_path", unique: true
    t.index ["shard_id"], name: "index_pool_repositories_on_shard_id"
    t.index ["source_project_id", "shard_id"], name: "index_pool_repositories_on_source_project_id_and_shard_id", unique: true
  end

  create_table "postgres_async_indexes", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "name", null: false
    t.text "definition", null: false
    t.text "table_name", null: false
    t.index ["name"], name: "index_postgres_async_indexes_on_name", unique: true
    t.check_constraint "char_length(definition) <= 2048", name: "check_083b21157b"
    t.check_constraint "char_length(name) <= 63", name: "check_b732c6cd1d"
    t.check_constraint "char_length(table_name) <= 63", name: "check_e64ff4359e"
  end

  create_table "postgres_reindex_actions", force: :cascade do |t|
    t.datetime_with_timezone "action_start", null: false
    t.datetime_with_timezone "action_end"
    t.bigint "ondisk_size_bytes_start", null: false
    t.bigint "ondisk_size_bytes_end"
    t.integer "state", limit: 2, default: 0, null: false
    t.text "index_identifier", null: false
    t.bigint "bloat_estimate_bytes_start"
    t.index ["index_identifier"], name: "index_postgres_reindex_actions_on_index_identifier"
    t.check_constraint "char_length(index_identifier) <= 255", name: "check_f12527622c"
  end

  create_table "postgres_reindex_queued_actions", force: :cascade do |t|
    t.text "index_identifier", null: false
    t.integer "state", limit: 2, default: 0, null: false
    t.datetime_with_timezone "created_at", default: -> { "now()" }, null: false
    t.datetime_with_timezone "updated_at", default: -> { "now()" }, null: false
    t.index ["state"], name: "index_postgres_reindex_queued_actions_on_state"
    t.check_constraint "char_length(index_identifier) <= 255", name: "check_e4b01395c0"
  end

  create_table "product_analytics_events_experimental", primary_key: ["id", "project_id"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.integer "project_id", null: false
    t.string "platform", limit: 255
    t.datetime_with_timezone "etl_tstamp"
    t.datetime_with_timezone "collector_tstamp", null: false
    t.datetime_with_timezone "dvce_created_tstamp"
    t.string "event", limit: 128
    t.string "event_id", limit: 36, null: false
    t.integer "txn_id"
    t.string "name_tracker", limit: 128
    t.string "v_tracker", limit: 100
    t.string "v_collector", limit: 100, null: false
    t.string "v_etl", limit: 100, null: false
    t.string "user_id", limit: 255
    t.string "user_ipaddress", limit: 45
    t.string "user_fingerprint", limit: 50
    t.string "domain_userid", limit: 36
    t.integer "domain_sessionidx", limit: 2
    t.string "network_userid", limit: 38
    t.string "geo_country", limit: 2
    t.string "geo_region", limit: 3
    t.string "geo_city", limit: 75
    t.string "geo_zipcode", limit: 15
    t.float "geo_latitude"
    t.float "geo_longitude"
    t.string "geo_region_name", limit: 100
    t.string "ip_isp", limit: 100
    t.string "ip_organization", limit: 100
    t.string "ip_domain", limit: 100
    t.string "ip_netspeed", limit: 100
    t.text "page_url"
    t.string "page_title", limit: 2000
    t.text "page_referrer"
    t.string "page_urlscheme", limit: 16
    t.string "page_urlhost", limit: 255
    t.integer "page_urlport"
    t.string "page_urlpath", limit: 3000
    t.string "page_urlquery", limit: 6000
    t.string "page_urlfragment", limit: 3000
    t.string "refr_urlscheme", limit: 16
    t.string "refr_urlhost", limit: 255
    t.integer "refr_urlport"
    t.string "refr_urlpath", limit: 6000
    t.string "refr_urlquery", limit: 6000
    t.string "refr_urlfragment", limit: 3000
    t.string "refr_medium", limit: 25
    t.string "refr_source", limit: 50
    t.string "refr_term", limit: 255
    t.string "mkt_medium", limit: 255
    t.string "mkt_source", limit: 255
    t.string "mkt_term", limit: 255
    t.string "mkt_content", limit: 500
    t.string "mkt_campaign", limit: 255
    t.string "se_category", limit: 1000
    t.string "se_action", limit: 1000
    t.string "se_label", limit: 1000
    t.string "se_property", limit: 1000
    t.float "se_value"
    t.string "tr_orderid", limit: 255
    t.string "tr_affiliation", limit: 255
    t.decimal "tr_total", precision: 18, scale: 2
    t.decimal "tr_tax", precision: 18, scale: 2
    t.decimal "tr_shipping", precision: 18, scale: 2
    t.string "tr_city", limit: 255
    t.string "tr_state", limit: 255
    t.string "tr_country", limit: 255
    t.string "ti_orderid", limit: 255
    t.string "ti_sku", limit: 255
    t.string "ti_name", limit: 255
    t.string "ti_category", limit: 255
    t.decimal "ti_price", precision: 18, scale: 2
    t.integer "ti_quantity"
    t.integer "pp_xoffset_min"
    t.integer "pp_xoffset_max"
    t.integer "pp_yoffset_min"
    t.integer "pp_yoffset_max"
    t.string "useragent", limit: 1000
    t.string "br_name", limit: 50
    t.string "br_family", limit: 50
    t.string "br_version", limit: 50
    t.string "br_type", limit: 50
    t.string "br_renderengine", limit: 50
    t.string "br_lang", limit: 255
    t.boolean "br_features_pdf"
    t.boolean "br_features_flash"
    t.boolean "br_features_java"
    t.boolean "br_features_director"
    t.boolean "br_features_quicktime"
    t.boolean "br_features_realplayer"
    t.boolean "br_features_windowsmedia"
    t.boolean "br_features_gears"
    t.boolean "br_features_silverlight"
    t.boolean "br_cookies"
    t.string "br_colordepth", limit: 12
    t.integer "br_viewwidth"
    t.integer "br_viewheight"
    t.string "os_name", limit: 50
    t.string "os_family", limit: 50
    t.string "os_manufacturer", limit: 50
    t.string "os_timezone", limit: 50
    t.string "dvce_type", limit: 50
    t.boolean "dvce_ismobile"
    t.integer "dvce_screenwidth"
    t.integer "dvce_screenheight"
    t.string "doc_charset", limit: 128
    t.integer "doc_width"
    t.integer "doc_height"
    t.string "tr_currency", limit: 3
    t.decimal "tr_total_base", precision: 18, scale: 2
    t.decimal "tr_tax_base", precision: 18, scale: 2
    t.decimal "tr_shipping_base", precision: 18, scale: 2
    t.string "ti_currency", limit: 3
    t.decimal "ti_price_base", precision: 18, scale: 2
    t.string "base_currency", limit: 3
    t.string "geo_timezone", limit: 64
    t.string "mkt_clickid", limit: 128
    t.string "mkt_network", limit: 64
    t.string "etl_tags", limit: 500
    t.datetime_with_timezone "dvce_sent_tstamp"
    t.string "refr_domain_userid", limit: 36
    t.datetime_with_timezone "refr_dvce_tstamp"
    t.string "domain_sessionid", limit: 36
    t.datetime_with_timezone "derived_tstamp"
    t.string "event_vendor", limit: 1000
    t.string "event_name", limit: 1000
    t.string "event_format", limit: 128
    t.string "event_version", limit: 128
    t.string "event_fingerprint", limit: 128
    t.datetime_with_timezone "true_tstamp"
    t.index ["project_id", "collector_tstamp"], name: "index_product_analytics_events_experimental_project_and_time"
  end

  create_table "programming_languages", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "color", null: false
    t.datetime_with_timezone "created_at", null: false
    t.index ["name"], name: "index_programming_languages_on_name", unique: true
  end

  create_table "project_access_tokens", primary_key: ["personal_access_token_id", "project_id"], force: :cascade do |t|
    t.bigint "personal_access_token_id", null: false
    t.bigint "project_id", null: false
    t.index ["project_id"], name: "index_project_access_tokens_on_project_id"
  end

  create_table "project_alerting_settings", primary_key: "project_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "encrypted_token", null: false
    t.string "encrypted_token_iv", null: false
  end

  create_table "project_aliases", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["name"], name: "index_project_aliases_on_name", unique: true
    t.index ["project_id"], name: "index_project_aliases_on_project_id"
  end

  create_table "project_authorizations", primary_key: ["user_id", "project_id", "access_level"], force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.integer "access_level", null: false
    t.index ["project_id", "user_id"], name: "index_unique_project_authorizations_on_project_id_user_id", unique: true
  end

  create_table "project_auto_devops", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "enabled"
    t.integer "deploy_strategy", default: 0, null: false
    t.index ["project_id"], name: "index_project_auto_devops_on_project_id", unique: true
  end

  create_table "project_build_artifacts_size_refreshes", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "last_job_artifact_id"
    t.integer "state", limit: 2, default: 1, null: false
    t.datetime_with_timezone "refresh_started_at"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "last_job_artifact_id_on_refresh_start", default: 0
    t.index ["project_id"], name: "index_project_build_artifacts_size_refreshes_on_project_id", unique: true
    t.index ["state", "updated_at"], name: "idx_build_artifacts_size_refreshes_state_updated_at"
  end

  create_table "project_ci_cd_settings", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.boolean "group_runners_enabled", default: true, null: false
    t.boolean "merge_pipelines_enabled"
    t.integer "default_git_depth"
    t.boolean "forward_deployment_enabled"
    t.boolean "merge_trains_enabled", default: false
    t.boolean "auto_rollback_enabled", default: false, null: false
    t.boolean "keep_latest_artifact", default: true, null: false
    t.boolean "restrict_user_defined_variables", default: false, null: false
    t.boolean "job_token_scope_enabled", default: false, null: false
    t.integer "runner_token_expiration_interval"
    t.boolean "separated_caches", default: true, null: false
    t.boolean "opt_in_jwt", default: false, null: false
    t.boolean "allow_fork_pipelines_to_run_in_parent_project", default: true, null: false
    t.boolean "inbound_job_token_scope_enabled", default: false, null: false
    t.index ["project_id"], name: "index_project_ci_cd_settings_on_project_id", unique: true
  end

  create_table "project_ci_feature_usages", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.integer "feature", limit: 2, null: false
    t.boolean "default_branch", default: false, null: false
    t.index ["project_id", "feature", "default_branch"], name: "index_project_ci_feature_usages_unique_columns", unique: true
  end

  create_table "project_compliance_framework_settings", primary_key: "project_id", force: :cascade do |t|
    t.bigint "framework_id"
    t.index ["framework_id"], name: "index_project_compliance_framework_settings_on_framework_id"
    t.index ["project_id"], name: "index_project_compliance_framework_settings_on_project_id"
    t.check_constraint "framework_id IS NOT NULL", name: "check_d348de9e2d"
  end

  create_table "project_custom_attributes", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "project_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.index ["key", "value"], name: "index_project_custom_attributes_on_key_and_value"
    t.index ["project_id", "key"], name: "index_project_custom_attributes_on_project_id_and_key", unique: true
  end

  create_table "project_daily_statistics", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "fetch_count", null: false
    t.date "date"
    t.index ["project_id", "date"], name: "index_project_daily_statistics_on_project_id_and_date", unique: true, order: { date: :desc }
  end

  create_table "project_deploy_tokens", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "deploy_token_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.index ["deploy_token_id"], name: "index_project_deploy_tokens_on_deploy_token_id"
    t.index ["project_id", "deploy_token_id"], name: "index_project_deploy_tokens_on_project_id_and_deploy_token_id", unique: true
  end

  create_table "project_error_tracking_settings", primary_key: "project_id", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "enabled", default: false, null: false
    t.string "api_url"
    t.string "encrypted_token"
    t.string "encrypted_token_iv"
    t.string "project_name"
    t.string "organization_name"
    t.boolean "integrated", default: true, null: false
    t.bigint "sentry_project_id"
  end

  create_table "project_export_jobs", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.string "jid", limit: 100, null: false
    t.index ["jid"], name: "index_project_export_jobs_on_jid", unique: true
    t.index ["project_id", "jid"], name: "index_project_export_jobs_on_project_id_and_jid"
    t.index ["project_id", "status"], name: "index_project_export_jobs_on_project_id_and_status"
    t.index ["status"], name: "index_project_export_jobs_on_status"
  end

  create_table "project_feature_usages", primary_key: "project_id", id: :integer, default: nil, force: :cascade do |t|
    t.datetime "jira_dvcs_cloud_last_sync_at"
    t.datetime "jira_dvcs_server_last_sync_at"
    t.index ["jira_dvcs_cloud_last_sync_at", "project_id"], name: "idx_proj_feat_usg_on_jira_dvcs_cloud_last_sync_at_and_proj_id", where: "(jira_dvcs_cloud_last_sync_at IS NOT NULL)"
    t.index ["jira_dvcs_server_last_sync_at", "project_id"], name: "idx_proj_feat_usg_on_jira_dvcs_server_last_sync_at_and_proj_id", where: "(jira_dvcs_server_last_sync_at IS NOT NULL)"
    t.index ["project_id"], name: "index_project_feature_usages_on_project_id"
  end

  create_table "project_features", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "merge_requests_access_level"
    t.integer "issues_access_level"
    t.integer "wiki_access_level"
    t.integer "snippets_access_level", default: 20, null: false
    t.integer "builds_access_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "repository_access_level", default: 20, null: false
    t.integer "pages_access_level", null: false
    t.integer "forking_access_level"
    t.integer "metrics_dashboard_access_level"
    t.integer "requirements_access_level", default: 20, null: false
    t.integer "operations_access_level", default: 20, null: false
    t.integer "analytics_access_level", default: 20, null: false
    t.integer "security_and_compliance_access_level", default: 10, null: false
    t.integer "container_registry_access_level", default: 0, null: false
    t.integer "package_registry_access_level", default: 0, null: false
    t.integer "monitor_access_level", default: 20, null: false
    t.integer "infrastructure_access_level", default: 20, null: false
    t.integer "feature_flags_access_level", default: 20, null: false
    t.integer "environments_access_level", default: 20, null: false
    t.integer "releases_access_level", default: 20, null: false
    t.index ["project_id", "container_registry_access_level"], name: "index_project_features_on_project_id_include_container_registry", unique: true, comment: "Included column (container_registry_access_level) improves performance of the ContainerRepository.for_group_and_its_subgroups scope query"
    t.index ["project_id"], name: "index_project_features_on_project_id", unique: true
    t.index ["project_id"], name: "index_project_features_on_project_id_bal_20", where: "(builds_access_level = 20)"
    t.index ["project_id"], name: "index_project_features_on_project_id_ral_20", where: "(repository_access_level = 20)"
  end

  create_table "project_group_links", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "group_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "group_access", default: 30, null: false
    t.date "expires_at"
    t.index ["group_id", "project_id"], name: "index_project_group_links_on_group_id_and_project_id"
    t.index ["project_id"], name: "index_project_group_links_on_project_id"
  end

  create_table "project_import_data", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.text "data"
    t.text "encrypted_credentials"
    t.string "encrypted_credentials_iv"
    t.string "encrypted_credentials_salt"
    t.index ["project_id"], name: "index_project_import_data_on_project_id"
  end

  create_table "project_incident_management_settings", primary_key: "project_id", id: :serial, force: :cascade do |t|
    t.boolean "create_issue", default: false, null: false
    t.boolean "send_email", default: false, null: false
    t.text "issue_template_key"
    t.boolean "pagerduty_active", default: false, null: false
    t.binary "encrypted_pagerduty_token"
    t.binary "encrypted_pagerduty_token_iv"
    t.boolean "auto_close_incident", default: true, null: false
    t.boolean "sla_timer", default: false
    t.integer "sla_timer_minutes"
    t.index ["project_id"], name: "index_project_incident_management_settings_on_p_id_sla_timer", where: "(sla_timer = true)"
    t.check_constraint "octet_length(encrypted_pagerduty_token) <= 255", name: "pagerduty_token_length_constraint"
    t.check_constraint "octet_length(encrypted_pagerduty_token_iv) <= 12", name: "pagerduty_token_iv_length_constraint"
  end

  create_table "project_metrics_settings", primary_key: "project_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "external_dashboard_url"
    t.integer "dashboard_timezone", limit: 2, default: 0, null: false
  end

  create_table "project_mirror_data", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "retry_count", default: 0, null: false
    t.datetime "last_update_started_at"
    t.datetime "last_update_scheduled_at"
    t.datetime "next_execution_timestamp"
    t.string "status"
    t.string "jid"
    t.text "last_error"
    t.datetime_with_timezone "last_update_at"
    t.datetime_with_timezone "last_successful_update_at"
    t.string "correlation_id_value", limit: 128
    t.index ["last_successful_update_at"], name: "index_project_mirror_data_on_last_successful_update_at"
    t.index ["last_update_at", "retry_count"], name: "index_project_mirror_data_on_last_update_at_and_retry_count"
    t.index ["next_execution_timestamp", "retry_count"], name: "index_mirror_data_non_scheduled_or_started", where: "((status)::text <> ALL ('{scheduled,started}'::text[]))"
    t.index ["project_id"], name: "index_project_mirror_data_on_project_id", unique: true
    t.index ["status"], name: "index_project_mirror_data_on_status"
  end

  create_table "project_pages_metadata", primary_key: "project_id", id: :bigint, default: nil, force: :cascade do |t|
    t.boolean "deployed", default: false, null: false
    t.bigint "pages_deployment_id"
    t.boolean "onboarding_complete", default: false, null: false
    t.index ["pages_deployment_id"], name: "index_project_pages_metadata_on_pages_deployment_id"
    t.index ["project_id"], name: "index_on_pages_metadata_not_migrated", where: "((deployed = true) AND (pages_deployment_id IS NULL))"
    t.index ["project_id"], name: "index_project_pages_metadata_on_project_id_and_deployed_is_true", where: "(deployed = true)"
  end

  create_table "project_relation_export_uploads", force: :cascade do |t|
    t.bigint "project_relation_export_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "export_file", null: false
    t.index ["project_relation_export_id"], name: "index_project_relation_export_upload_id"
    t.check_constraint "char_length(export_file) <= 255", name: "check_d8ee243e9e"
  end

  create_table "project_relation_exports", force: :cascade do |t|
    t.bigint "project_export_job_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.text "relation", null: false
    t.text "jid"
    t.text "export_error"
    t.index ["project_export_job_id", "relation"], name: "index_project_export_job_relation", unique: true
    t.index ["project_export_job_id"], name: "index_project_relation_exports_on_project_export_job_id"
    t.check_constraint "char_length(export_error) <= 300", name: "check_dbd1cf73d0"
    t.check_constraint "char_length(jid) <= 255", name: "check_15e644d856"
    t.check_constraint "char_length(relation) <= 255", name: "check_4b5880b795"
  end

  create_table "project_repositories", force: :cascade do |t|
    t.integer "shard_id", null: false
    t.string "disk_path", null: false
    t.integer "project_id", null: false
    t.index ["disk_path"], name: "index_project_repositories_on_disk_path", unique: true
    t.index ["project_id"], name: "index_project_repositories_on_project_id", unique: true
    t.index ["shard_id", "project_id"], name: "index_project_repositories_on_shard_id_and_project_id"
    t.index ["shard_id"], name: "index_project_repositories_on_shard_id"
  end

  create_table "project_repository_states", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.binary "repository_verification_checksum"
    t.binary "wiki_verification_checksum"
    t.string "last_repository_verification_failure"
    t.string "last_wiki_verification_failure"
    t.datetime_with_timezone "repository_retry_at"
    t.datetime_with_timezone "wiki_retry_at"
    t.integer "repository_retry_count"
    t.integer "wiki_retry_count"
    t.datetime_with_timezone "last_repository_verification_ran_at"
    t.datetime_with_timezone "last_wiki_verification_ran_at"
    t.datetime_with_timezone "last_repository_updated_at"
    t.datetime_with_timezone "last_wiki_updated_at"
    t.index ["last_repository_verification_failure"], name: "idx_repository_states_on_repository_failure_partial", where: "(last_repository_verification_failure IS NOT NULL)"
    t.index ["last_wiki_verification_failure"], name: "idx_repository_states_on_wiki_failure_partial", where: "(last_wiki_verification_failure IS NOT NULL)"
    t.index ["project_id", "last_repository_verification_ran_at"], name: "idx_repository_states_on_last_repository_verification_ran_at", where: "((repository_verification_checksum IS NOT NULL) AND (last_repository_verification_failure IS NULL))"
    t.index ["project_id", "last_wiki_verification_ran_at"], name: "idx_repository_states_on_last_wiki_verification_ran_at", where: "((wiki_verification_checksum IS NOT NULL) AND (last_wiki_verification_failure IS NULL))"
    t.index ["project_id"], name: "idx_repository_states_outdated_checksums", where: "(((repository_verification_checksum IS NULL) AND (last_repository_verification_failure IS NULL)) OR ((wiki_verification_checksum IS NULL) AND (last_wiki_verification_failure IS NULL)))"
    t.index ["project_id"], name: "index_project_repository_states_on_project_id", unique: true
  end

  create_table "project_repository_storage_moves", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.integer "state", limit: 2, default: 1, null: false
    t.text "source_storage_name", null: false
    t.text "destination_storage_name", null: false
    t.index ["project_id"], name: "index_project_repository_storage_moves_on_project_id"
    t.check_constraint "char_length(destination_storage_name) <= 255", name: "project_repository_storage_moves_destination_storage_name"
    t.check_constraint "char_length(source_storage_name) <= 255", name: "project_repository_storage_moves_source_storage_name"
  end

  create_table "project_security_settings", primary_key: "project_id", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "auto_fix_container_scanning", default: true, null: false
    t.boolean "auto_fix_dast", default: true, null: false
    t.boolean "auto_fix_dependency_scanning", default: true, null: false
    t.boolean "auto_fix_sast", default: true, null: false
  end

  create_table "project_settings", primary_key: "project_id", id: :integer, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "push_rule_id"
    t.boolean "show_default_award_emojis", default: true
    t.boolean "allow_merge_on_skipped_pipeline"
    t.integer "squash_option", limit: 2, default: 3
    t.boolean "has_confluence", default: false, null: false
    t.boolean "has_vulnerabilities", default: false, null: false
    t.boolean "prevent_merge_without_jira_issue", default: false, null: false
    t.boolean "cve_id_request_enabled", default: true, null: false
    t.boolean "mr_default_target_self", default: false, null: false
    t.text "previous_default_branch"
    t.boolean "warn_about_potentially_unwanted_characters", default: true, null: false
    t.text "merge_commit_template"
    t.boolean "has_shimo", default: false, null: false
    t.text "squash_commit_template"
    t.boolean "legacy_open_source_license_available", default: true, null: false
    t.string "target_platforms", default: [], null: false, array: true
    t.boolean "enforce_auth_checks_on_uploads", default: true, null: false
    t.boolean "selective_code_owner_removals", default: false, null: false
    t.text "issue_branch_template"
    t.boolean "show_diff_preview_in_email", default: true, null: false
    t.text "jitsu_key"
    t.boolean "suggested_reviewers_enabled", default: false, null: false
    t.boolean "only_allow_merge_if_all_status_checks_passed", default: false, null: false
    t.text "mirror_branch_regex"
    t.boolean "allow_pipeline_trigger_approve_deployment", default: false, null: false
    t.index ["project_id"], name: "index_project_settings_on_legacy_os_license_project_id", where: "(legacy_open_source_license_available = true)"
    t.index ["project_id"], name: "index_project_settings_on_project_id_partially", where: "(has_vulnerabilities IS TRUE)"
    t.index ["push_rule_id"], name: "index_project_settings_on_push_rule_id", unique: true
    t.check_constraint "char_length(issue_branch_template) <= 255", name: "check_3ca5cbffe6"
    t.check_constraint "char_length(jitsu_key) <= 100", name: "check_2981f15877"
    t.check_constraint "char_length(merge_commit_template) <= 500", name: "check_eaf7cfb6a7"
    t.check_constraint "char_length(mirror_branch_regex) <= 255", name: "check_67292e4b99"
    t.check_constraint "char_length(previous_default_branch) <= 4096", name: "check_3a03e7557a"
    t.check_constraint "char_length(squash_commit_template) <= 500", name: "check_b09644994b"
    t.check_constraint "show_default_award_emojis IS NOT NULL", name: "check_bde223416c"
  end

  create_table "project_statistics", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "namespace_id", null: false
    t.bigint "commit_count", default: 0, null: false
    t.bigint "storage_size", default: 0, null: false
    t.bigint "repository_size", default: 0, null: false
    t.bigint "lfs_objects_size", default: 0, null: false
    t.bigint "build_artifacts_size", default: 0, null: false
    t.bigint "shared_runners_seconds", default: 0, null: false
    t.datetime "shared_runners_seconds_last_reset"
    t.bigint "packages_size", default: 0, null: false
    t.bigint "wiki_size"
    t.bigint "snippets_size"
    t.bigint "pipeline_artifacts_size", default: 0, null: false
    t.bigint "uploads_size", default: 0, null: false
    t.bigint "container_registry_size", default: 0, null: false
    t.datetime_with_timezone "created_at", default: -> { "now()" }, null: false
    t.datetime_with_timezone "updated_at", default: -> { "now()" }, null: false
    t.index ["namespace_id"], name: "index_project_statistics_on_namespace_id"
    t.index ["packages_size", "project_id"], name: "index_project_statistics_on_packages_size_and_project_id"
    t.index ["project_id"], name: "index_project_statistics_on_project_id", unique: true
    t.index ["project_id"], name: "tmp_index_project_statistics_cont_registry_size", where: "(container_registry_size = 0)"
    t.index ["project_id"], name: "tmp_index_project_statistics_uploads_size", where: "(uploads_size <> 0)"
    t.index ["repository_size", "project_id"], name: "index_project_statistics_on_repository_size_and_project_id"
    t.index ["storage_size", "project_id"], name: "index_project_statistics_on_storage_size_and_project_id"
    t.index ["wiki_size", "project_id"], name: "index_project_statistics_on_wiki_size_and_project_id"
  end

  create_table "project_topics", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "topic_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["project_id", "topic_id"], name: "index_project_topics_on_project_id_and_topic_id", unique: true
    t.index ["project_id"], name: "index_project_topics_on_project_id"
    t.index ["topic_id"], name: "index_project_topics_on_topic_id"
  end

  create_table "project_wiki_repositories", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["project_id"], name: "index_project_wiki_repositories_on_project_id", unique: true
  end

  create_table "project_wiki_repository_states", primary_key: "project_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.integer "verification_retry_count", limit: 2
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.bigint "project_wiki_repository_id"
    t.index ["project_wiki_repository_id"], name: "idx_project_wiki_repository_states_project_wiki_repository_id"
    t.index ["verification_retry_at"], name: "index_project_wiki_repository_states_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_project_wiki_repository_states_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_project_wiki_repository_states_on_verification_state"
    t.index ["verified_at"], name: "index_project_wiki_repository_states_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_119f134b68"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "path"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "namespace_id", null: false
    t.datetime "last_activity_at"
    t.string "import_url"
    t.integer "visibility_level", default: 0, null: false
    t.boolean "archived", default: false, null: false
    t.string "avatar"
    t.text "merge_requests_template"
    t.integer "star_count", default: 0, null: false
    t.boolean "merge_requests_rebase_enabled", default: false
    t.string "import_type"
    t.string "import_source"
    t.integer "approvals_before_merge", default: 0, null: false
    t.boolean "reset_approvals_on_push", default: true
    t.boolean "merge_requests_ff_only_enabled", default: false
    t.text "issues_template"
    t.boolean "mirror", default: false, null: false
    t.datetime "mirror_last_update_at"
    t.datetime "mirror_last_successful_update_at"
    t.integer "mirror_user_id"
    t.boolean "shared_runners_enabled", default: true, null: false
    t.string "runners_token"
    t.boolean "build_allow_git_fetch", default: true, null: false
    t.integer "build_timeout", default: 3600, null: false
    t.boolean "mirror_trigger_builds", default: false, null: false
    t.boolean "pending_delete", default: false
    t.boolean "public_builds", default: true, null: false
    t.boolean "last_repository_check_failed"
    t.datetime "last_repository_check_at"
    t.boolean "only_allow_merge_if_pipeline_succeeds", default: false, null: false
    t.boolean "has_external_issue_tracker"
    t.string "repository_storage", default: "default", null: false
    t.boolean "repository_read_only"
    t.boolean "request_access_enabled", default: true, null: false
    t.boolean "has_external_wiki"
    t.string "ci_config_path"
    t.boolean "lfs_enabled"
    t.text "description_html"
    t.boolean "only_allow_merge_if_all_discussions_are_resolved"
    t.bigint "repository_size_limit"
    t.boolean "printing_merge_request_link_enabled", default: true, null: false
    t.integer "auto_cancel_pending_pipelines", default: 1, null: false
    t.boolean "service_desk_enabled", default: true
    t.integer "cached_markdown_version"
    t.text "delete_error"
    t.datetime "last_repository_updated_at"
    t.boolean "disable_overriding_approvers_per_merge_request"
    t.integer "storage_version", limit: 2
    t.boolean "resolve_outdated_diff_discussions"
    t.boolean "remote_mirror_available_overridden"
    t.boolean "only_mirror_protected_branches"
    t.boolean "pull_mirror_available_overridden"
    t.integer "jobs_cache_index"
    t.string "external_authorization_classification_label"
    t.boolean "mirror_overwrites_diverged_branches"
    t.boolean "pages_https_only", default: true
    t.string "external_webhook_token"
    t.boolean "packages_enabled"
    t.boolean "merge_requests_author_approval", default: false
    t.bigint "pool_repository_id"
    t.string "runners_token_encrypted"
    t.string "bfg_object_map"
    t.boolean "detected_repository_languages"
    t.boolean "merge_requests_disable_committers_approval"
    t.boolean "require_password_to_approve"
    t.boolean "emails_disabled"
    t.integer "max_pages_size"
    t.integer "max_artifacts_size"
    t.string "pull_mirror_branch_prefix", limit: 50
    t.boolean "remove_source_branch_after_merge"
    t.date "marked_for_deletion_at"
    t.integer "marked_for_deletion_by_user_id"
    t.boolean "autoclose_referenced_issues"
    t.string "suggestion_commit_message", limit: 255
    t.bigint "project_namespace_id"
    t.boolean "hidden", default: false, null: false
    t.index "lower((name)::text)", name: "index_projects_on_lower_name"
    t.index "lower((path)::text)", name: "index_on_projects_lower_path"
    t.index ["created_at", "id"], name: "idx_projects_api_created_at_id_for_archived", where: "((archived = true) AND (pending_delete = false) AND (hidden = false))"
    t.index ["created_at", "id"], name: "idx_projects_api_created_at_id_for_archived_vis20", where: "((archived = true) AND (visibility_level = 20) AND (pending_delete = false) AND (hidden = false))"
    t.index ["created_at", "id"], name: "idx_projects_api_created_at_id_for_vis10", where: "((visibility_level = 10) AND (pending_delete = false) AND (hidden = false))"
    t.index ["created_at", "id"], name: "index_projects_api_created_at_id_desc", order: { id: :desc }
    t.index ["created_at", "id"], name: "index_projects_api_vis20_created_at", where: "(visibility_level = 20)"
    t.index ["created_at", "id"], name: "index_projects_on_created_at_and_id"
    t.index ["creator_id", "created_at", "id"], name: "index_projects_on_creator_id_and_created_at_and_id"
    t.index ["creator_id", "created_at"], name: "index_projects_on_mirror_creator_id_created_at", where: "((mirror = true) AND (mirror_trigger_builds = true))"
    t.index ["creator_id", "id"], name: "index_projects_on_creator_id_and_id"
    t.index ["creator_id", "import_type", "created_at"], name: "index_projects_on_creator_id_import_type_and_created_at_partial", where: "(import_type IS NOT NULL)"
    t.index ["description"], name: "index_projects_on_description_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["id", "created_at"], name: "idx_projects_id_created_at_disable_overriding_approvers_false", where: "((disable_overriding_approvers_per_merge_request = false) OR (disable_overriding_approvers_per_merge_request IS NULL))"
    t.index ["id", "created_at"], name: "idx_projects_id_created_at_disable_overriding_approvers_true", where: "(disable_overriding_approvers_per_merge_request = true)"
    t.index ["id", "creator_id", "created_at"], name: "index_service_desk_enabled_projects_on_id_creator_id_created_at", where: "(service_desk_enabled = true)"
    t.index ["id", "repository_storage", "last_repository_updated_at"], name: "idx_projects_on_repository_storage_last_repository_updated_at"
    t.index ["id"], name: "index_projects_not_aimed_for_deletion", where: "(marked_for_deletion_at IS NULL)"
    t.index ["id"], name: "index_projects_on_id_and_archived_and_pending_delete", where: "((archived = false) AND (pending_delete = false))"
    t.index ["id"], name: "index_projects_on_id_partial_for_visibility", unique: true, where: "(visibility_level = ANY (ARRAY[10, 20]))"
    t.index ["id"], name: "index_projects_on_id_service_desk_enabled", where: "(service_desk_enabled = true)"
    t.index ["id"], name: "index_projects_on_mirror_id_where_mirror_and_trigger_builds", where: "((mirror = true) AND (mirror_trigger_builds = true))"
    t.index ["import_type", "creator_id", "created_at"], name: "index_imported_projects_on_import_type_creator_id_created_at", where: "(import_type IS NOT NULL)"
    t.index ["import_type", "id"], name: "index_imported_projects_on_import_type_id", where: "(import_type IS NOT NULL)"
    t.index ["last_activity_at", "id"], name: "index_projects_api_last_activity_at_id_desc", order: { id: :desc }
    t.index ["last_activity_at", "id"], name: "index_projects_api_vis20_last_activity_at", where: "(visibility_level = 20)"
    t.index ["last_activity_at", "id"], name: "index_projects_on_last_activity_at_and_id"
    t.index ["last_repository_check_at"], name: "index_projects_on_last_repository_check_at", where: "(last_repository_check_at IS NOT NULL)"
    t.index ["last_repository_check_failed"], name: "index_projects_on_last_repository_check_failed"
    t.index ["last_repository_updated_at"], name: "index_projects_on_last_repository_updated_at"
    t.index ["marked_for_deletion_at"], name: "index_projects_aimed_for_deletion", where: "((marked_for_deletion_at IS NOT NULL) AND (pending_delete = false))"
    t.index ["marked_for_deletion_by_user_id"], name: "index_projects_on_marked_for_deletion_by_user_id", where: "(marked_for_deletion_by_user_id IS NOT NULL)"
    t.index ["mirror_last_successful_update_at"], name: "index_projects_on_mirror_last_successful_update_at"
    t.index ["mirror_user_id"], name: "index_projects_on_mirror_user_id"
    t.index ["name", "id"], name: "index_projects_api_name_id_desc", order: { id: :desc }
    t.index ["name", "id"], name: "index_projects_api_vis20_name", where: "(visibility_level = 20)"
    t.index ["name", "id"], name: "index_projects_on_name_and_id"
    t.index ["name", "namespace_id"], name: "unique_projects_on_name_namespace_id", unique: true
    t.index ["name"], name: "index_projects_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["namespace_id", "id"], name: "index_projects_on_namespace_id_and_id"
    t.index ["path", "id"], name: "index_projects_api_path_id_desc", order: { id: :desc }
    t.index ["path", "id"], name: "index_projects_api_vis20_path", where: "(visibility_level = 20)"
    t.index ["path", "id"], name: "index_projects_on_path_and_id"
    t.index ["path"], name: "index_on_projects_path"
    t.index ["path"], name: "index_projects_on_path_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["pending_delete"], name: "index_projects_on_pending_delete"
    t.index ["pool_repository_id"], name: "index_projects_on_pool_repository_id", where: "(pool_repository_id IS NOT NULL)"
    t.index ["project_namespace_id"], name: "index_projects_on_project_namespace_id", unique: true
    t.index ["repository_storage", "created_at"], name: "idx_project_repository_check_partial", where: "(last_repository_check_at IS NULL)"
    t.index ["repository_storage"], name: "index_projects_on_repository_storage"
    t.index ["runners_token"], name: "index_uniq_projects_on_runners_token", unique: true
    t.index ["runners_token_encrypted"], name: "index_uniq_projects_on_runners_token_encrypted", unique: true
    t.index ["star_count"], name: "index_projects_on_star_count"
    t.index ["updated_at", "id"], name: "index_projects_api_updated_at_id_desc", order: { id: :desc }
    t.index ["updated_at", "id"], name: "index_projects_api_vis20_updated_at", where: "(visibility_level = 20)"
    t.index ["updated_at", "id"], name: "index_projects_on_updated_at_and_id"
    t.check_constraint "project_namespace_id IS NOT NULL", name: "check_fa75869cb1"
  end

  create_table "projects_sync_events", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.index ["project_id"], name: "index_projects_sync_events_on_project_id"
  end

  create_table "prometheus_alert_events", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "prometheus_alert_id", null: false
    t.datetime_with_timezone "started_at", null: false
    t.datetime_with_timezone "ended_at"
    t.integer "status", limit: 2
    t.string "payload_key"
    t.index ["project_id", "status"], name: "index_prometheus_alert_events_on_project_id_and_status"
    t.index ["prometheus_alert_id", "payload_key"], name: "index_prometheus_alert_event_scoped_payload_key", unique: true
  end

  create_table "prometheus_alerts", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.float "threshold", null: false
    t.integer "operator", null: false
    t.integer "environment_id", null: false
    t.integer "project_id", null: false
    t.integer "prometheus_metric_id", null: false
    t.text "runbook_url"
    t.index ["environment_id"], name: "index_prometheus_alerts_on_environment_id"
    t.index ["project_id", "prometheus_metric_id", "environment_id"], name: "index_prometheus_alerts_metric_environment", unique: true
    t.index ["prometheus_metric_id"], name: "index_prometheus_alerts_on_prometheus_metric_id"
    t.check_constraint "char_length(runbook_url) <= 255", name: "check_cb76d7e629"
  end

  create_table "prometheus_metrics", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "title", null: false
    t.string "query", null: false
    t.string "y_label", null: false
    t.string "unit", null: false
    t.string "legend"
    t.integer "group", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "common", default: false, null: false
    t.string "identifier"
    t.text "dashboard_path"
    t.index ["common"], name: "index_prometheus_metrics_on_common"
    t.index ["group"], name: "index_prometheus_metrics_on_group"
    t.index ["identifier", "project_id"], name: "index_prometheus_metrics_on_identifier_and_project_id", unique: true
    t.index ["identifier"], name: "index_prometheus_metrics_on_identifier_and_null_project", unique: true, where: "(project_id IS NULL)"
    t.index ["project_id"], name: "index_prometheus_metrics_on_project_id"
    t.check_constraint "char_length(dashboard_path) <= 2048", name: "check_0ad9f01463"
  end

  create_table "protected_branch_merge_access_levels", id: :serial, force: :cascade do |t|
    t.integer "protected_branch_id", null: false
    t.integer "access_level", default: 40
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_protected_branch_merge_access_levels_on_group_id"
    t.index ["protected_branch_id"], name: "index_protected_branch_merge_access"
    t.index ["user_id"], name: "index_protected_branch_merge_access_levels_on_user_id"
  end

  create_table "protected_branch_push_access_levels", id: :serial, force: :cascade do |t|
    t.integer "protected_branch_id", null: false
    t.integer "access_level", default: 40
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "group_id"
    t.integer "deploy_key_id"
    t.index ["deploy_key_id"], name: "index_deploy_key_id_on_protected_branch_push_access_levels"
    t.index ["group_id"], name: "index_protected_branch_push_access_levels_on_group_id"
    t.index ["protected_branch_id"], name: "index_protected_branch_push_access"
    t.index ["user_id"], name: "index_protected_branch_push_access_levels_on_user_id"
  end

  create_table "protected_branch_unprotect_access_levels", id: :serial, force: :cascade do |t|
    t.integer "protected_branch_id", null: false
    t.integer "access_level", default: 40
    t.integer "user_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_protected_branch_unprotect_access_levels_on_group_id"
    t.index ["protected_branch_id"], name: "index_protected_branch_unprotect_access"
    t.index ["user_id"], name: "index_protected_branch_unprotect_access_levels_on_user_id"
  end

  create_table "protected_branches", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "code_owner_approval_required", default: false, null: false
    t.boolean "allow_force_push", default: false, null: false
    t.bigint "namespace_id"
    t.index ["namespace_id"], name: "index_protected_branches_namespace_id", where: "(namespace_id IS NOT NULL)"
    t.index ["project_id", "code_owner_approval_required"], name: "code_owner_approval_required", where: "(code_owner_approval_required = true)"
    t.index ["project_id"], name: "index_protected_branches_on_project_id"
    t.check_constraint "(project_id IS NULL) <> (namespace_id IS NULL)", name: "protected_branches_project_id_namespace_id_any_not_null"
  end

  create_table "protected_environment_approval_rules", force: :cascade do |t|
    t.bigint "protected_environment_id", null: false
    t.bigint "user_id"
    t.bigint "group_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "access_level", limit: 2
    t.integer "required_approvals", limit: 2, null: false
    t.integer "group_inheritance_type", limit: 2, default: 0, null: false
    t.index ["group_id"], name: "index_protected_environment_approval_rules_on_group_id"
    t.index ["protected_environment_id"], name: "index_approval_rule_on_protected_environment_id"
    t.index ["required_approvals", "created_at"], name: "index_pe_approval_rules_on_required_approvals_and_created_at"
    t.index ["user_id"], name: "index_protected_environment_approval_rules_on_user_id"
    t.check_constraint "((access_level IS NOT NULL) AND (group_id IS NULL) AND (user_id IS NULL)) OR ((user_id IS NOT NULL) AND (access_level IS NULL) AND (group_id IS NULL)) OR ((group_id IS NOT NULL) AND (user_id IS NULL) AND (access_level IS NULL))"
    t.check_constraint "required_approvals > 0"
  end

  create_table "protected_environment_deploy_access_levels", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "access_level", default: 40
    t.integer "protected_environment_id", null: false
    t.integer "user_id"
    t.integer "group_id"
    t.integer "group_inheritance_type", limit: 2, default: 0, null: false
    t.index ["group_id"], name: "index_protected_environment_deploy_access_levels_on_group_id"
    t.index ["protected_environment_id"], name: "index_protected_environment_deploy_access"
    t.index ["user_id"], name: "index_protected_environment_deploy_access_levels_on_user_id"
  end

  create_table "protected_environments", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "name", null: false
    t.bigint "group_id"
    t.integer "required_approval_count", default: 0, null: false
    t.index ["group_id", "name"], name: "index_protected_environments_on_group_id_and_name", unique: true, where: "(group_id IS NOT NULL)"
    t.index ["project_id", "name"], name: "index_protected_environments_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_protected_environments_on_project_id"
    t.index ["required_approval_count", "created_at"], name: "index_protected_environments_on_approval_count_and_created_at"
    t.check_constraint "(project_id IS NULL) <> (group_id IS NULL)", name: "protected_environments_project_or_group_existence"
    t.check_constraint "required_approval_count >= 0", name: "protected_environments_required_approval_count_positive"
  end

  create_table "protected_tag_create_access_levels", id: :serial, force: :cascade do |t|
    t.integer "protected_tag_id", null: false
    t.integer "access_level", default: 40
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_protected_tag_create_access_levels_on_group_id"
    t.index ["protected_tag_id"], name: "index_protected_tag_create_access"
    t.index ["user_id"], name: "index_protected_tag_create_access_levels_on_user_id"
  end

  create_table "protected_tags", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "name"], name: "index_protected_tags_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_protected_tags_on_project_id"
  end

  create_table "push_event_payloads", primary_key: "event_id", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "commit_count", null: false
    t.integer "action", limit: 2, null: false
    t.integer "ref_type", limit: 2, null: false
    t.binary "commit_from"
    t.binary "commit_to"
    t.text "ref"
    t.string "commit_title", limit: 70
    t.integer "ref_count"
  end

  create_table "push_rules", id: :serial, force: :cascade do |t|
    t.string "force_push_regex"
    t.string "delete_branch_regex"
    t.string "commit_message_regex"
    t.boolean "deny_delete_tag"
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "author_email_regex"
    t.boolean "member_check", default: false, null: false
    t.string "file_name_regex"
    t.boolean "is_sample", default: false
    t.integer "max_file_size", default: 0, null: false
    t.boolean "prevent_secrets", default: false, null: false
    t.string "branch_name_regex"
    t.boolean "reject_unsigned_commits"
    t.boolean "commit_committer_check"
    t.boolean "regexp_uses_re2", default: true
    t.string "commit_message_negative_regex"
    t.boolean "reject_non_dco_commits"
    t.boolean "commit_committer_name_check", default: false, null: false
    t.index ["is_sample"], name: "index_push_rules_on_is_sample", where: "is_sample"
    t.index ["project_id"], name: "index_push_rules_on_project_id"
  end

  create_table "raw_usage_data", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "recorded_at", null: false
    t.datetime_with_timezone "sent_at"
    t.jsonb "payload", null: false
    t.bigint "version_usage_data_id_value"
    t.index ["recorded_at"], name: "index_raw_usage_data_on_recorded_at", unique: true
  end

  create_table "redirect_routes", id: :serial, force: :cascade do |t|
    t.integer "source_id", null: false
    t.string "source_type", null: false
    t.string "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((path)::text) varchar_pattern_ops", name: "index_redirect_routes_on_path_unique_text_pattern_ops", unique: true
    t.index ["path"], name: "index_redirect_routes_on_path", unique: true
    t.index ["source_type", "source_id"], name: "index_redirect_routes_on_source_type_and_source_id"
  end

  create_table "related_epic_links", force: :cascade do |t|
    t.bigint "source_id", null: false
    t.bigint "target_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "link_type", limit: 2, default: 0, null: false
    t.index ["source_id", "target_id"], name: "index_related_epic_links_on_source_id_and_target_id", unique: true
    t.index ["source_id"], name: "index_related_epic_links_on_source_id"
    t.index ["target_id"], name: "index_related_epic_links_on_target_id"
  end

  create_table "release_links", force: :cascade do |t|
    t.integer "release_id", null: false
    t.string "url", null: false
    t.string "name", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "filepath", limit: 128
    t.integer "link_type", limit: 2, default: 0
    t.index ["release_id", "name"], name: "index_release_links_on_release_id_and_name", unique: true
    t.index ["release_id", "url"], name: "index_release_links_on_release_id_and_url", unique: true
  end

  create_table "releases", id: :serial, force: :cascade do |t|
    t.string "tag"
    t.text "description"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description_html"
    t.integer "cached_markdown_version"
    t.integer "author_id"
    t.string "name"
    t.string "sha"
    t.datetime_with_timezone "released_at", null: false
    t.index ["author_id", "id", "created_at"], name: "index_releases_on_author_id_id_created_at"
    t.index ["project_id", "id"], name: "index_releases_on_project_id_id"
    t.index ["project_id", "released_at", "id"], name: "index_releases_on_project_id_and_released_at_and_id"
    t.index ["project_id", "tag"], name: "index_releases_on_project_tag_unique", unique: true
    t.index ["released_at"], name: "index_releases_on_released_at"
    t.check_constraint "tag IS NOT NULL", name: "releases_not_null_tag"
  end

  create_table "remote_mirrors", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "url"
    t.boolean "enabled", default: false
    t.string "update_status"
    t.datetime "last_update_at"
    t.datetime "last_successful_update_at"
    t.string "last_error"
    t.text "encrypted_credentials"
    t.string "encrypted_credentials_iv"
    t.string "encrypted_credentials_salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_update_started_at"
    t.boolean "only_protected_branches", default: false, null: false
    t.string "remote_name"
    t.boolean "error_notification_sent"
    t.boolean "keep_divergent_refs"
    t.text "mirror_branch_regex"
    t.index ["last_successful_update_at"], name: "index_remote_mirrors_on_last_successful_update_at"
    t.index ["project_id"], name: "index_remote_mirrors_on_project_id"
    t.check_constraint "char_length(mirror_branch_regex) <= 255", name: "check_aa6b497785"
  end

  create_table "repository_languages", primary_key: ["project_id", "programming_language_id"], force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "programming_language_id", null: false
    t.float "share", null: false
  end

  create_table "required_code_owners_sections", force: :cascade do |t|
    t.bigint "protected_branch_id", null: false
    t.text "name", null: false
    t.index ["protected_branch_id"], name: "index_required_code_owners_sections_on_protected_branch_id"
    t.check_constraint "char_length(name) <= 1024", name: "check_e58d53741e"
  end

  create_table "requirements", force: :cascade do |t|
    t.datetime_with_timezone "created_at"
    t.datetime_with_timezone "updated_at"
    t.integer "project_id", null: false
    t.integer "author_id"
    t.integer "iid", null: false
    t.integer "cached_markdown_version"
    t.integer "state", limit: 2, default: 1
    t.string "title", limit: 255
    t.text "title_html"
    t.text "description"
    t.text "description_html"
    t.bigint "issue_id"
    t.index ["author_id"], name: "index_requirements_on_author_id"
    t.index ["created_at"], name: "index_requirements_on_created_at"
    t.index ["issue_id"], name: "index_requirements_on_issue_id", unique: true
    t.index ["project_id", "iid"], name: "index_requirements_on_project_id_and_iid", unique: true, where: "(project_id IS NOT NULL)"
    t.index ["project_id"], name: "index_requirements_on_project_id"
    t.index ["state"], name: "index_requirements_on_state"
    t.index ["title"], name: "index_requirements_on_title_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["updated_at"], name: "index_requirements_on_updated_at"
    t.check_constraint "char_length(description) <= 10000", name: "check_785ae25b9d"
    t.check_constraint "issue_id IS NOT NULL", name: "check_requirement_issue_not_null"
  end

  create_table "requirements_management_test_reports", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.bigint "author_id"
    t.integer "state", limit: 2, null: false
    t.bigint "build_id"
    t.bigint "issue_id"
    t.index ["author_id"], name: "index_requirements_management_test_reports_on_author_id"
    t.index ["build_id"], name: "index_requirements_management_test_reports_on_build_id"
    t.index ["issue_id", "created_at", "id"], name: "idx_test_reports_on_issue_id_created_at_and_id"
    t.index ["issue_id"], name: "index_requirements_management_test_reports_on_issue_id"
  end

  create_table "resource_iteration_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "issue_id"
    t.bigint "merge_request_id"
    t.bigint "iteration_id"
    t.datetime_with_timezone "created_at", null: false
    t.integer "action", limit: 2, null: false
    t.index ["issue_id"], name: "index_resource_iteration_events_on_issue_id"
    t.index ["iteration_id"], name: "index_resource_iteration_events_on_iteration_id"
    t.index ["iteration_id"], name: "index_resource_iteration_events_on_iteration_id_and_add_action", where: "(action = 1)"
    t.index ["merge_request_id"], name: "index_resource_iteration_events_on_merge_request_id"
    t.index ["user_id"], name: "index_resource_iteration_events_on_user_id"
  end

  create_table "resource_label_events", force: :cascade do |t|
    t.integer "action", null: false
    t.integer "issue_id"
    t.integer "merge_request_id"
    t.integer "epic_id"
    t.integer "label_id"
    t.integer "user_id"
    t.datetime_with_timezone "created_at", null: false
    t.integer "cached_markdown_version"
    t.text "reference"
    t.text "reference_html"
    t.index ["epic_id"], name: "index_resource_label_events_on_epic_id"
    t.index ["issue_id", "label_id", "action"], name: "index_resource_label_events_issue_id_label_id_action"
    t.index ["label_id", "action"], name: "index_resource_label_events_on_label_id_and_action"
    t.index ["merge_request_id", "label_id", "action"], name: "index_resource_label_events_on_merge_request_id_label_id_action"
    t.index ["user_id"], name: "index_resource_label_events_on_user_id"
  end

  create_table "resource_milestone_events", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "issue_id"
    t.bigint "merge_request_id"
    t.bigint "milestone_id"
    t.integer "action", limit: 2, null: false
    t.integer "state", limit: 2, null: false
    t.datetime_with_timezone "created_at", null: false
    t.index ["created_at"], name: "index_resource_milestone_events_created_at"
    t.index ["issue_id"], name: "index_resource_milestone_events_on_issue_id"
    t.index ["merge_request_id"], name: "index_resource_milestone_events_on_merge_request_id"
    t.index ["milestone_id"], name: "index_resource_milestone_events_on_milestone_id"
    t.index ["milestone_id"], name: "index_resource_milestone_events_on_milestone_id_and_add_action", where: "(action = 1)"
    t.index ["user_id"], name: "index_resource_milestone_events_on_user_id"
  end

  create_table "resource_state_events", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "issue_id"
    t.bigint "merge_request_id"
    t.datetime_with_timezone "created_at", null: false
    t.integer "state", limit: 2, null: false
    t.integer "epic_id"
    t.text "source_commit"
    t.boolean "close_after_error_tracking_resolve", default: false, null: false
    t.boolean "close_auto_resolve_prometheus_alert", default: false, null: false
    t.bigint "source_merge_request_id"
    t.index ["epic_id"], name: "index_resource_state_events_on_epic_id"
    t.index ["issue_id", "created_at"], name: "index_resource_state_events_on_issue_id_and_created_at"
    t.index ["merge_request_id"], name: "index_resource_state_events_on_merge_request_id"
    t.index ["source_merge_request_id"], name: "index_resource_state_events_on_source_merge_request_id"
    t.index ["user_id"], name: "index_resource_state_events_on_user_id"
    t.check_constraint "((issue_id <> NULL::bigint) AND (merge_request_id IS NULL) AND (epic_id IS NULL)) OR ((issue_id IS NULL) AND (merge_request_id <> NULL::bigint) AND (epic_id IS NULL)) OR ((issue_id IS NULL) AND (merge_request_id IS NULL) AND (epic_id <> NULL::integer))", name: "state_events_must_belong_to_issue_or_merge_request_or_epic"
    t.check_constraint "char_length(source_commit) <= 40", name: "check_f0bcfaa3a2"
  end

  create_table "resource_weight_events", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "issue_id", null: false
    t.integer "weight"
    t.datetime_with_timezone "created_at", null: false
    t.index ["issue_id", "created_at"], name: "index_resource_weight_events_on_issue_id_and_created_at"
    t.index ["issue_id", "weight"], name: "index_resource_weight_events_on_issue_id_and_weight"
    t.index ["user_id"], name: "index_resource_weight_events_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "author_id"
    t.integer "merge_request_id", null: false
    t.integer "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.index ["author_id"], name: "index_reviews_on_author_id"
    t.index ["merge_request_id"], name: "index_reviews_on_merge_request_id"
    t.index ["project_id"], name: "index_reviews_on_project_id"
  end

  create_table "routes", id: :serial, force: :cascade do |t|
    t.integer "source_id", null: false
    t.string "source_type", null: false
    t.string "path", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.bigint "namespace_id"
    t.index "lower((path)::text)", name: "index_on_routes_lower_path"
    t.index ["id"], name: "tmp_index_for_project_namespace_id_migration_on_routes", where: "((namespace_id IS NULL) AND ((source_type)::text = 'Project'::text))"
    t.index ["name"], name: "index_route_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["namespace_id"], name: "index_routes_on_namespace_id", unique: true
    t.index ["path"], name: "index_routes_on_path", unique: true
    t.index ["path"], name: "index_routes_on_path_text_pattern_ops", opclass: :varchar_pattern_ops
    t.index ["path"], name: "index_routes_on_path_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["source_type", "source_id"], name: "index_routes_on_source_type_and_source_id", unique: true
    t.check_constraint "namespace_id IS NOT NULL", name: "check_af84c6c93f"
  end

  create_table "saml_group_links", force: :cascade do |t|
    t.integer "access_level", limit: 2, null: false
    t.bigint "group_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "saml_group_name", null: false
    t.index ["group_id", "saml_group_name"], name: "index_saml_group_links_on_group_id_and_saml_group_name", unique: true
    t.check_constraint "char_length(saml_group_name) <= 255", name: "check_1b3fc49d1e"
  end

  create_table "saml_providers", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.boolean "enabled", null: false
    t.string "certificate_fingerprint", null: false
    t.string "sso_url", null: false
    t.boolean "enforced_sso", default: false, null: false
    t.boolean "enforced_group_managed_accounts", default: false, null: false
    t.boolean "prohibited_outer_forks", default: true, null: false
    t.integer "default_membership_role", limit: 2, default: 10, null: false
    t.boolean "git_check_enforced", default: false, null: false
    t.index ["group_id"], name: "index_saml_providers_on_group_id"
  end

  create_table "saved_replies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "name", null: false
    t.text "content", null: false
    t.index ["user_id", "name"], name: "index_saved_replies_on_name_text_pattern_ops", unique: true, opclass: { name: :text_pattern_ops }
    t.check_constraint "char_length(content) <= 10000", name: "check_0cb57dc22a"
    t.check_constraint "char_length(name) <= 255", name: "check_2eb3366d7f"
  end

  create_table "sbom_component_versions", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "component_id", null: false
    t.text "version", null: false
    t.index ["component_id", "version"], name: "index_sbom_component_versions_on_component_id_and_version", unique: true
    t.index ["component_id"], name: "index_sbom_component_versions_on_component_id"
    t.check_constraint "char_length(version) <= 255", name: "check_e71cad08d3"
  end

  create_table "sbom_components", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "component_type", limit: 2, null: false
    t.text "name", null: false
    t.integer "purl_type", limit: 2
    t.index ["name", "purl_type", "component_type"], name: "index_sbom_components_on_component_type_name_and_purl_type", unique: true
    t.check_constraint "char_length(name) <= 255", name: "check_91a8f6ad53"
  end

  create_table "sbom_occurrences", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "component_version_id"
    t.bigint "project_id", null: false
    t.bigint "pipeline_id"
    t.bigint "source_id"
    t.binary "commit_sha", null: false
    t.bigint "component_id", null: false
    t.index ["component_id"], name: "index_sbom_occurrences_on_component_id"
    t.index ["component_version_id"], name: "index_sbom_occurrences_on_component_version_id"
    t.index ["pipeline_id"], name: "index_sbom_occurrences_on_pipeline_id"
    t.index ["project_id", "component_id", "component_version_id", "source_id", "commit_sha"], name: "index_sbom_occurrences_on_ingestion_attributes", unique: true
    t.index ["project_id"], name: "index_sbom_occurrences_on_project_id"
    t.index ["source_id"], name: "index_sbom_occurrences_on_source_id"
  end

  create_table "sbom_sources", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "source_type", limit: 2, null: false
    t.jsonb "source", default: {}, null: false
    t.index ["source_type", "source"], name: "index_sbom_sources_on_source_type_and_source", unique: true
  end

  create_table "sbom_vulnerable_component_versions", force: :cascade do |t|
    t.bigint "vulnerability_advisory_id"
    t.bigint "sbom_component_version_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["sbom_component_version_id"], name: "index_vulnerable_component_versions_on_sbom_component_version"
    t.index ["vulnerability_advisory_id"], name: "index_vulnerable_component_versions_on_vulnerability_advisory"
  end

  create_table "scim_identities", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "user_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "active", default: false
    t.string "extern_uid", limit: 255, null: false
    t.index "lower((extern_uid)::text), group_id", name: "index_scim_identities_on_lower_extern_uid_and_group_id", unique: true
    t.index ["group_id"], name: "index_scim_identities_on_group_id"
    t.index ["user_id", "group_id"], name: "index_scim_identities_on_user_id_and_group_id", unique: true
  end

  create_table "scim_oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "group_id"
    t.string "token_encrypted", null: false
    t.index ["group_id", "token_encrypted"], name: "index_scim_oauth_access_tokens_on_group_id_and_token_encrypted", unique: true
  end

  create_table "security_findings", primary_key: ["id", "partition_number"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "scan_id", null: false
    t.bigint "scanner_id", null: false
    t.integer "severity", limit: 2, null: false
    t.integer "confidence", limit: 2
    t.text "project_fingerprint"
    t.boolean "deduplicated", default: false, null: false
    t.uuid "uuid"
    t.uuid "overridden_uuid"
    t.integer "partition_number", default: 1, null: false
    t.jsonb "finding_data", default: {}, null: false
    t.index ["confidence"], name: "security_findings_confidence_idx"
    t.index ["project_fingerprint"], name: "security_findings_project_fingerprint_idx"
    t.index ["scan_id", "deduplicated"], name: "security_findings_scan_id_deduplicated_idx"
    t.index ["scan_id", "id"], name: "security_findings_scan_id_id_idx"
    t.index ["scanner_id"], name: "security_findings_scanner_id_idx"
    t.index ["severity"], name: "security_findings_severity_idx"
    t.index ["uuid", "scan_id", "partition_number"], name: "security_findings_uuid_scan_id_partition_number_idx", unique: true
    t.check_constraint "char_length(project_fingerprint) <= 40", name: "check_b9508c6df8"
    t.check_constraint "uuid IS NOT NULL", name: "check_6c2851a8c9"
  end

  create_table "security_orchestration_policy_configurations", comment: "{\"owner\":\"group::container security\",\"description\":\"Configuration used to store relationship between project and security policy repository\"}", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "security_policy_management_project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "configured_at"
    t.bigint "namespace_id"
    t.index ["namespace_id"], name: "partial_index_sop_configs_on_namespace_id", unique: true, where: "(namespace_id IS NOT NULL)"
    t.index ["project_id"], name: "partial_index_sop_configs_on_project_id", unique: true, where: "(project_id IS NOT NULL)"
    t.index ["security_policy_management_project_id", "project_id"], name: "index_sop_configurations_project_id_policy_project_id"
    t.check_constraint "(project_id IS NULL) <> (namespace_id IS NULL)", name: "cop_configs_project_or_namespace_existence"
  end

  create_table "security_orchestration_policy_rule_schedules", comment: "{\"owner\":\"group::container security\",\"description\":\"Schedules used to store relationship between project and security policy repository\"}", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "next_run_at"
    t.bigint "security_orchestration_policy_configuration_id", null: false
    t.bigint "user_id", null: false
    t.integer "policy_index", null: false
    t.text "cron", null: false
    t.integer "rule_index", default: 0, null: false
    t.index ["security_orchestration_policy_configuration_id"], name: "index_sop_schedules_on_sop_configuration_id"
    t.index ["user_id"], name: "index_sop_schedules_on_user_id"
    t.check_constraint "char_length(cron) <= 255", name: "check_915825a76e"
  end

  create_table "security_scans", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "build_id", null: false
    t.integer "scan_type", limit: 2, null: false
    t.jsonb "info", default: {}, null: false
    t.bigint "project_id"
    t.bigint "pipeline_id"
    t.boolean "latest", default: true, null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.integer "findings_partition_number", default: 1, null: false
    t.index "date(timezone('UTC'::text, created_at)), id", name: "index_security_scans_on_date_created_at_and_id"
    t.index "pipeline_id, jsonb_array_length(COALESCE((info -> 'errors'::text), '[]'::jsonb))", name: "index_security_scans_on_length_of_errors"
    t.index "pipeline_id, jsonb_array_length(COALESCE((info -> 'warnings'::text), '[]'::jsonb))", name: "index_security_scans_on_length_of_warnings"
    t.index ["build_id", "scan_type"], name: "idx_security_scans_on_build_and_scan_type", unique: true
    t.index ["created_at", "id"], name: "index_security_scans_for_non_purged_records", where: "(status <> 6)"
    t.index ["created_at"], name: "index_security_scans_on_created_at"
    t.index ["pipeline_id"], name: "index_security_scans_on_pipeline_id"
    t.index ["project_id"], name: "index_security_scans_on_project_id"
    t.index ["scan_type"], name: "idx_security_scans_on_scan_type"
  end

  create_table "security_training_providers", force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.text "url", null: false
    t.text "logo_url"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["name"], name: "index_security_training_providers_on_unique_name", unique: true
    t.check_constraint "char_length(description) <= 512", name: "check_a8ff21ced5"
    t.check_constraint "char_length(logo_url) <= 512", name: "check_6fe222f071"
    t.check_constraint "char_length(name) <= 256", name: "check_dae433eed6"
    t.check_constraint "char_length(url) <= 512", name: "check_544b3dc935"
  end

  create_table "security_trainings", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "provider_id", null: false
    t.boolean "is_primary", default: false, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["project_id"], name: "index_security_trainings_on_project_id"
    t.index ["project_id"], name: "index_security_trainings_on_unique_project_id", unique: true, where: "(is_primary IS TRUE)"
    t.index ["provider_id"], name: "index_security_trainings_on_provider_id"
  end

  create_table "self_managed_prometheus_alert_events", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "environment_id"
    t.datetime_with_timezone "started_at", null: false
    t.datetime_with_timezone "ended_at"
    t.integer "status", limit: 2, null: false
    t.string "title", limit: 255, null: false
    t.string "query_expression", limit: 255
    t.string "payload_key", limit: 255, null: false
    t.index ["environment_id"], name: "index_self_managed_prometheus_alert_events_on_environment_id"
    t.index ["project_id", "payload_key"], name: "idx_project_id_payload_key_self_managed_prometheus_alert_events", unique: true
  end

  create_table "sent_notifications", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "noteable_id"
    t.string "noteable_type"
    t.integer "recipient_id"
    t.string "commit_id"
    t.string "reply_key", null: false
    t.string "line_code"
    t.string "note_type"
    t.text "position"
    t.string "in_reply_to_discussion_id"
    t.index ["noteable_id"], name: "index_sent_notifications_on_noteable_type_noteable_id", where: "((noteable_type)::text = 'Issue'::text)"
    t.index ["reply_key"], name: "index_sent_notifications_on_reply_key", unique: true
  end

  create_table "sentry_issues", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.bigint "sentry_issue_identifier", null: false
    t.index ["issue_id"], name: "index_sentry_issues_on_issue_id", unique: true
    t.index ["sentry_issue_identifier"], name: "index_sentry_issues_on_sentry_issue_identifier"
  end

  create_table "serverless_domain_cluster", primary_key: "uuid", id: { type: :string, limit: 14 }, force: :cascade do |t|
    t.bigint "pages_domain_id", null: false
    t.bigint "clusters_applications_knative_id", null: false
    t.bigint "creator_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "encrypted_key"
    t.string "encrypted_key_iv", limit: 255
    t.text "certificate"
    t.index ["clusters_applications_knative_id"], name: "idx_serverless_domain_cluster_on_clusters_applications_knative", unique: true
    t.index ["creator_id"], name: "index_serverless_domain_cluster_on_creator_id"
    t.index ["pages_domain_id"], name: "index_serverless_domain_cluster_on_pages_domain_id"
  end

  create_table "service_desk_settings", primary_key: "project_id", id: :bigint, default: nil, force: :cascade do |t|
    t.string "issue_template_key", limit: 255
    t.string "outgoing_name", limit: 255
    t.string "project_key", limit: 255
    t.bigint "file_template_project_id"
    t.index ["file_template_project_id"], name: "index_service_desk_settings_on_file_template_project_id"
  end

  create_table "shards", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_shards_on_name", unique: true
  end

  create_table "slack_integrations", id: :serial, force: :cascade do |t|
    t.string "team_id", null: false
    t.string "team_name", null: false
    t.string "alias", null: false
    t.string "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "bot_user_id"
    t.binary "encrypted_bot_access_token"
    t.binary "encrypted_bot_access_token_iv"
    t.integer "integration_id"
    t.index ["id"], name: "partial_index_slack_integrations_with_bot_user_id", where: "(bot_user_id IS NOT NULL)"
    t.index ["integration_id"], name: "index_slack_integrations_on_integration_id"
    t.index ["team_id", "alias"], name: "index_slack_integrations_on_team_id_and_alias", unique: true
    t.check_constraint "char_length(bot_user_id) <= 255", name: "check_bc553aea8a"
    t.check_constraint "integration_id IS NOT NULL", name: "check_c9ca9ae80d"
  end

  create_table "smartcard_identities", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "subject", null: false
    t.string "issuer", null: false
    t.index ["subject", "issuer"], name: "index_smartcard_identities_on_subject_and_issuer", unique: true
    t.index ["user_id"], name: "index_smartcard_identities_on_user_id"
  end

  create_table "snippet_repositories", primary_key: "snippet_id", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "shard_id", null: false
    t.string "disk_path", limit: 80, null: false
    t.integer "verification_retry_count", limit: 2
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.datetime_with_timezone "verification_started_at"
    t.index ["disk_path"], name: "index_snippet_repositories_on_disk_path", unique: true
    t.index ["shard_id"], name: "index_snippet_repositories_on_shard_id"
    t.index ["verification_retry_at"], name: "index_snippet_repositories_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_snippet_repositories_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_snippet_repositories_verification_state"
    t.index ["verified_at"], name: "index_snippet_repositories_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "snippet_repositories_verification_failure_text_limit"
  end

  create_table "snippet_repository_storage_moves", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "snippet_id", null: false
    t.integer "state", limit: 2, default: 1, null: false
    t.text "source_storage_name", null: false
    t.text "destination_storage_name", null: false
    t.index ["snippet_id"], name: "index_snippet_repository_storage_moves_on_snippet_id"
    t.check_constraint "char_length(destination_storage_name) <= 255", name: "snippet_repository_storage_moves_destination_storage_name"
    t.check_constraint "char_length(source_storage_name) <= 255", name: "snippet_repository_storage_moves_source_storage_name"
  end

  create_table "snippet_statistics", primary_key: "snippet_id", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "repository_size", default: 0, null: false
    t.bigint "file_count", default: 0, null: false
    t.bigint "commit_count", default: 0, null: false
  end

  create_table "snippet_user_mentions", force: :cascade do |t|
    t.integer "snippet_id", null: false
    t.integer "note_id"
    t.integer "mentioned_users_ids", array: true
    t.integer "mentioned_projects_ids", array: true
    t.integer "mentioned_groups_ids", array: true
    t.index ["note_id"], name: "index_snippet_user_mentions_on_note_id", unique: true, where: "(note_id IS NOT NULL)"
    t.index ["snippet_id", "note_id"], name: "snippet_user_mentions_on_snippet_id_and_note_id_index", unique: true
    t.index ["snippet_id"], name: "snippet_user_mentions_on_snippet_id_index", unique: true, where: "(note_id IS NULL)"
  end

  create_table "snippets", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "author_id", null: false
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file_name"
    t.string "type"
    t.integer "visibility_level", default: 0, null: false
    t.text "title_html"
    t.text "content_html"
    t.integer "cached_markdown_version"
    t.text "description"
    t.text "description_html"
    t.string "encrypted_secret_token", limit: 255
    t.string "encrypted_secret_token_iv", limit: 255
    t.boolean "secret", default: false, null: false
    t.boolean "repository_read_only", default: false, null: false
    t.index ["author_id"], name: "index_snippets_on_author_id"
    t.index ["content"], name: "index_snippets_on_content_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["created_at"], name: "index_snippets_on_created_at"
    t.index ["description"], name: "index_snippets_on_description_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["file_name"], name: "index_snippets_on_file_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["id", "created_at"], name: "index_snippets_on_id_and_created_at"
    t.index ["id", "project_id"], name: "index_snippet_on_id_and_project_id"
    t.index ["id", "type"], name: "index_snippets_on_id_and_type"
    t.index ["project_id", "title"], name: "index_snippets_on_project_id_and_title"
    t.index ["project_id", "visibility_level"], name: "index_snippets_on_project_id_and_visibility_level"
    t.index ["title"], name: "index_snippets_on_title_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["updated_at"], name: "index_snippets_on_updated_at"
    t.index ["visibility_level", "secret"], name: "index_snippets_on_visibility_level_and_secret"
  end

  create_table "software_license_policies", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "software_license_id", null: false
    t.integer "classification", default: 0, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["project_id", "software_license_id"], name: "index_software_license_policies_unique_per_project", unique: true
    t.index ["software_license_id"], name: "index_software_license_policies_on_software_license_id"
  end

  create_table "software_licenses", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "spdx_identifier", limit: 255
    t.index ["name"], name: "index_software_licenses_on_unique_name", unique: true
    t.index ["spdx_identifier"], name: "index_software_licenses_on_spdx_identifier"
  end

  create_table "spam_logs", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "source_ip"
    t.string "user_agent"
    t.boolean "via_api"
    t.string "noteable_type"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "submitted_as_ham", default: false, null: false
    t.boolean "recaptcha_verified", default: false, null: false
    t.index ["user_id"], name: "index_spam_logs_on_user_id"
  end

  create_table "sprints", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.date "start_date"
    t.date "due_date"
    t.bigint "group_id"
    t.integer "iid", null: false
    t.integer "cached_markdown_version"
    t.text "title"
    t.text "title_html"
    t.text "description"
    t.text "description_html"
    t.integer "state_enum", limit: 2, default: 1, null: false
    t.integer "iterations_cadence_id"
    t.integer "sequence"
    t.index "iterations_cadence_id, daterange(start_date, due_date, '[]'::text)", name: "iteration_start_and_due_date_iterations_cadence_id_constraint", where: "(group_id IS NOT NULL)", using: :gist
    t.index ["description"], name: "index_sprints_on_description_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["due_date"], name: "index_sprints_on_due_date"
    t.index ["group_id"], name: "index_sprints_on_group_id"
    t.index ["iterations_cadence_id", "sequence"], name: "sequence_is_unique_per_iterations_cadence_id", unique: true
    t.index ["iterations_cadence_id"], name: "index_sprints_iterations_cadence_id"
    t.index ["title"], name: "index_sprints_on_title"
    t.index ["title"], name: "index_sprints_on_title_trigram", opclass: :gin_trgm_ops, using: :gin
    t.check_constraint "char_length(title) <= 255", name: "sprints_title"
    t.check_constraint "due_date IS NOT NULL", name: "check_df3816aed7"
    t.check_constraint "start_date IS NOT NULL", name: "check_ccd8a1eae0"
  end

  create_table "ssh_signatures", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.bigint "key_id"
    t.integer "verification_status", limit: 2, default: 0, null: false
    t.binary "commit_sha", null: false
    t.index ["commit_sha"], name: "index_ssh_signatures_on_commit_sha", unique: true
    t.index ["key_id"], name: "index_ssh_signatures_on_key_id"
    t.index ["project_id"], name: "index_ssh_signatures_on_project_id"
  end

  create_table "status_check_responses", force: :cascade do |t|
    t.bigint "merge_request_id", null: false
    t.bigint "external_approval_rule_id"
    t.binary "sha", null: false
    t.bigint "external_status_check_id", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["external_approval_rule_id"], name: "index_status_check_responses_on_external_approval_rule_id"
    t.index ["external_status_check_id"], name: "index_status_check_responses_on_external_status_check_id"
    t.index ["merge_request_id"], name: "index_status_check_responses_on_merge_request_id"
  end

  create_table "status_page_published_incidents", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "issue_id", null: false
    t.index ["issue_id"], name: "index_status_page_published_incidents_on_issue_id", unique: true
  end

  create_table "status_page_settings", primary_key: "project_id", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.boolean "enabled", default: false, null: false
    t.string "aws_s3_bucket_name", limit: 63, null: false
    t.string "aws_region", limit: 255, null: false
    t.string "aws_access_key", limit: 255, null: false
    t.string "encrypted_aws_secret_key", limit: 255, null: false
    t.string "encrypted_aws_secret_key_iv", limit: 255, null: false
    t.text "status_page_url"
    t.index ["project_id"], name: "index_status_page_settings_on_project_id"
    t.check_constraint "char_length(status_page_url) <= 1024", name: "check_75a79cd992"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "subscribable_id"
    t.string "subscribable_type"
    t.boolean "subscribed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "project_id"
    t.index ["project_id"], name: "index_subscriptions_on_project_id"
    t.index ["subscribable_id", "subscribable_type", "user_id", "project_id"], name: "index_subscriptions_on_subscribable_and_user_id_and_project_id", unique: true
  end

  create_table "suggestions", force: :cascade do |t|
    t.integer "note_id", null: false
    t.integer "relative_order", limit: 2, null: false
    t.boolean "applied", default: false, null: false
    t.string "commit_id"
    t.text "from_content", null: false
    t.text "to_content", null: false
    t.integer "lines_above", default: 0, null: false
    t.integer "lines_below", default: 0, null: false
    t.boolean "outdated", default: false, null: false
    t.index ["note_id", "relative_order"], name: "index_suggestions_on_note_id_and_relative_order", unique: true
  end

  create_table "system_note_metadata", id: :serial, force: :cascade do |t|
    t.integer "note_id", null: false
    t.integer "commit_count"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "description_version_id"
    t.index ["description_version_id"], name: "index_system_note_metadata_on_description_version_id", unique: true, where: "(description_version_id IS NOT NULL)"
    t.index ["note_id"], name: "index_system_note_metadata_on_note_id", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context"
    t.datetime "created_at"
    t.bigint "taggable_id"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["name"], name: "index_tags_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "term_agreements", id: :serial, force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "user_id", null: false
    t.boolean "accepted", default: false, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["term_id"], name: "index_term_agreements_on_term_id"
    t.index ["user_id", "term_id"], name: "term_agreements_unique_index", unique: true
    t.index ["user_id"], name: "index_term_agreements_on_user_id"
  end

  create_table "terraform_state_versions", force: :cascade do |t|
    t.bigint "terraform_state_id", null: false
    t.bigint "created_by_user_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "version", null: false
    t.integer "file_store", limit: 2, null: false
    t.text "file", null: false
    t.integer "verification_retry_count", limit: 2
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.bigint "ci_build_id"
    t.datetime_with_timezone "verification_started_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.index ["ci_build_id"], name: "index_terraform_state_versions_on_ci_build_id"
    t.index ["created_by_user_id"], name: "index_terraform_state_versions_on_created_by_user_id"
    t.index ["terraform_state_id", "version"], name: "index_terraform_state_versions_on_state_id_and_version", unique: true
    t.index ["verification_retry_at"], name: "index_terraform_state_versions_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_terraform_state_versions_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_terraform_state_versions_on_verification_state"
    t.index ["verified_at"], name: "index_terraform_state_versions_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(file) <= 255", name: "check_0824bb7bbd"
    t.check_constraint "char_length(verification_failure) <= 255", name: "tf_state_versions_verification_failure_text_limit"
  end

  create_table "terraform_states", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "file_store", limit: 2
    t.string "file", limit: 255
    t.string "lock_xid", limit: 255
    t.datetime_with_timezone "locked_at"
    t.bigint "locked_by_user_id"
    t.string "uuid", limit: 32, null: false
    t.string "name", limit: 255, null: false
    t.boolean "versioning_enabled", default: true, null: false
    t.datetime_with_timezone "deleted_at"
    t.index ["file_store"], name: "index_terraform_states_on_file_store"
    t.index ["locked_by_user_id"], name: "index_terraform_states_on_locked_by_user_id"
    t.index ["project_id", "name"], name: "index_terraform_states_on_project_id_and_name", unique: true
    t.index ["uuid"], name: "index_terraform_states_on_uuid", unique: true
  end

  create_table "timelog_categories", force: :cascade do |t|
    t.bigint "namespace_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.decimal "billing_rate", precision: 18, scale: 4, default: "0.0"
    t.boolean "billable", default: false, null: false
    t.text "name", null: false
    t.text "description"
    t.text "color", default: "#6699cc", null: false
    t.index "namespace_id, lower(name)", name: "index_timelog_categories_on_unique_name_per_namespace", unique: true
    t.check_constraint "char_length(color) <= 7", name: "check_4ba862ba3e"
    t.check_constraint "char_length(description) <= 1024", name: "check_c4b8aec13a"
    t.check_constraint "char_length(name) <= 255", name: "check_37ad5f23d7"
  end

  create_table "timelogs", id: :serial, force: :cascade do |t|
    t.integer "time_spent", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "issue_id"
    t.integer "merge_request_id"
    t.datetime "spent_at", default: -> { "now()" }
    t.integer "note_id"
    t.integer "project_id"
    t.text "summary"
    t.index ["issue_id"], name: "index_timelogs_on_issue_id"
    t.index ["merge_request_id"], name: "index_timelogs_on_merge_request_id"
    t.index ["note_id"], name: "index_timelogs_on_note_id"
    t.index ["project_id", "spent_at"], name: "index_timelogs_on_project_id_and_spent_at"
    t.index ["spent_at"], name: "index_timelogs_on_spent_at", where: "(spent_at IS NOT NULL)"
    t.index ["user_id"], name: "index_timelogs_on_user_id"
    t.check_constraint "char_length(summary) <= 255", name: "check_271d321699"
  end

  create_table "todos", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id"
    t.integer "target_id"
    t.string "target_type", null: false
    t.integer "author_id", null: false
    t.integer "action", null: false
    t.string "state", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "note_id"
    t.string "commit_id"
    t.integer "group_id"
    t.integer "resolved_by_action", limit: 2
    t.index ["author_id", "created_at"], name: "index_todos_on_author_id_and_created_at"
    t.index ["author_id"], name: "index_todos_on_author_id"
    t.index ["commit_id"], name: "index_todos_on_commit_id"
    t.index ["group_id"], name: "index_todos_on_group_id"
    t.index ["note_id"], name: "index_todos_on_note_id"
    t.index ["project_id", "id"], name: "index_todos_on_project_id_and_id"
    t.index ["project_id", "user_id", "id", "target_type"], name: "index_requirements_project_id_user_id_id_and_target_type"
    t.index ["target_type", "target_id"], name: "index_todos_on_target_type_and_target_id"
    t.index ["user_id", "id"], name: "index_todos_on_user_id_and_id_done", where: "((state)::text = 'done'::text)"
    t.index ["user_id", "id"], name: "index_todos_on_user_id_and_id_pending", where: "((state)::text = 'pending'::text)"
    t.index ["user_id", "project_id", "target_type", "target_id", "id"], name: "index_on_todos_user_project_target_and_state", where: "((state)::text = 'pending'::text)"
    t.index ["user_id", "target_type"], name: "index_requirements_user_id_and_target_type"
  end

  create_table "token_with_ivs", force: :cascade do |t|
    t.binary "hashed_token", null: false
    t.binary "hashed_plaintext_token", null: false
    t.binary "iv", null: false
    t.index ["hashed_plaintext_token"], name: "index_token_with_ivs_on_hashed_plaintext_token", unique: true
    t.index ["hashed_token"], name: "index_token_with_ivs_on_hashed_token", unique: true
  end

  create_table "topics", force: :cascade do |t|
    t.text "name", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "avatar"
    t.text "description"
    t.bigint "total_projects_count", default: 0, null: false
    t.bigint "non_private_projects_count", default: 0, null: false
    t.text "title"
    t.index "lower(name)", name: "index_topics_on_lower_name"
    t.index ["name"], name: "index_topics_on_name", unique: true
    t.index ["name"], name: "index_topics_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["non_private_projects_count", "id"], name: "index_topics_non_private_projects_count", order: { non_private_projects_count: :desc }
    t.index ["total_projects_count", "id"], name: "index_topics_total_projects_count", order: { total_projects_count: :desc }
    t.check_constraint "char_length(avatar) <= 255", name: "check_26753fb43a"
    t.check_constraint "char_length(description) <= 1024", name: "check_5d1a07c8c8"
    t.check_constraint "char_length(name) <= 255", name: "check_7a90d4c757"
    t.check_constraint "char_length(title) <= 255", name: "check_223b50f9be"
  end

  create_table "trending_projects", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.index ["project_id"], name: "index_trending_projects_on_project_id", unique: true
  end

  create_table "u2f_registrations", id: :serial, force: :cascade do |t|
    t.text "certificate"
    t.string "key_handle"
    t.string "public_key"
    t.integer "counter"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["key_handle"], name: "index_u2f_registrations_on_key_handle"
    t.index ["user_id"], name: "index_u2f_registrations_on_user_id"
  end

  create_table "upcoming_reconciliations", force: :cascade do |t|
    t.bigint "namespace_id"
    t.date "next_reconciliation_date", null: false
    t.date "display_alert_from", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["namespace_id"], name: "index_upcoming_reconciliations_on_namespace_id", unique: true
  end

  create_table "upload_states", primary_key: "upload_id", force: :cascade do |t|
    t.datetime_with_timezone "verification_started_at"
    t.datetime_with_timezone "verification_retry_at"
    t.datetime_with_timezone "verified_at"
    t.integer "verification_state", limit: 2, default: 0, null: false
    t.integer "verification_retry_count", limit: 2
    t.binary "verification_checksum"
    t.text "verification_failure"
    t.index ["upload_id"], name: "index_upload_states_on_upload_id"
    t.index ["verification_retry_at"], name: "index_upload_states_failed_verification", order: "NULLS FIRST", where: "(verification_state = 3)"
    t.index ["verification_state"], name: "index_upload_states_needs_verification", where: "((verification_state = 0) OR (verification_state = 3))"
    t.index ["verification_state"], name: "index_upload_states_on_verification_state"
    t.index ["verified_at"], name: "index_upload_states_pending_verification", order: "NULLS FIRST", where: "(verification_state = 0)"
    t.check_constraint "char_length(verification_failure) <= 255", name: "check_7396dc8591"
  end

  create_table "uploads", id: :serial, force: :cascade do |t|
    t.bigint "size", null: false
    t.string "path", limit: 511, null: false
    t.string "checksum", limit: 64
    t.integer "model_id"
    t.string "model_type"
    t.string "uploader", null: false
    t.datetime "created_at", null: false
    t.integer "store", default: 1
    t.string "mount_point"
    t.string "secret"
    t.index ["checksum"], name: "index_uploads_on_checksum"
    t.index ["model_id", "model_type"], name: "index_uploads_on_model_id_and_model_type"
    t.index ["store"], name: "index_uploads_on_store"
    t.index ["uploader", "path"], name: "index_uploads_on_uploader_and_path"
    t.check_constraint "store IS NOT NULL", name: "check_5e9547379c"
  end

  create_table "user_agent_details", id: :serial, force: :cascade do |t|
    t.string "user_agent", null: false
    t.string "ip_address", null: false
    t.integer "subject_id", null: false
    t.string "subject_type", null: false
    t.boolean "submitted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id", "subject_type"], name: "index_user_agent_details_on_subject_id_and_subject_type"
  end

  create_table "user_callouts", id: :serial, force: :cascade do |t|
    t.integer "feature_name", null: false
    t.integer "user_id", null: false
    t.datetime_with_timezone "dismissed_at"
    t.index ["user_id", "feature_name"], name: "index_user_callouts_on_user_id_and_feature_name", unique: true
    t.index ["user_id"], name: "index_user_callouts_on_user_id"
  end

  create_table "user_canonical_emails", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "canonical_email", null: false
    t.index ["canonical_email"], name: "index_user_canonical_emails_on_canonical_email"
    t.index ["user_id", "canonical_email"], name: "index_user_canonical_emails_on_user_id_and_canonical_email", unique: true
    t.index ["user_id"], name: "index_user_canonical_emails_on_user_id", unique: true
  end

  create_table "user_credit_card_validations", primary_key: "user_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "credit_card_validated_at", null: false
    t.date "expiration_date"
    t.integer "last_digits", limit: 2
    t.text "holder_name"
    t.text "network"
    t.index "lower(holder_name), expiration_date, last_digits, credit_card_validated_at", name: "index_user_credit_card_validations_meta_data_full_match_lower"
    t.index ["expiration_date", "last_digits", "network", "credit_card_validated_at"], name: "index_user_credit_card_validations_meta_data_partial_match"
    t.check_constraint "(last_digits >= 0) AND (last_digits <= 9999)", name: "check_3eea080c91"
    t.check_constraint "char_length(holder_name) <= 50", name: "check_cc0c8dc0fe"
    t.check_constraint "char_length(network) <= 32", name: "check_1765e2b30f"
  end

  create_table "user_custom_attributes", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.index ["key", "updated_at"], name: "index_key_updated_at_on_user_custom_attribute"
    t.index ["key", "value"], name: "index_user_custom_attributes_on_key_and_value"
    t.index ["user_id", "key"], name: "index_user_custom_attributes_on_user_id_and_key", unique: true
  end

  create_table "user_details", primary_key: "user_id", force: :cascade do |t|
    t.string "job_title", limit: 200, default: "", null: false
    t.string "bio", limit: 255, default: "", null: false
    t.text "webauthn_xid"
    t.bigint "provisioned_by_group_id"
    t.text "pronouns"
    t.text "pronunciation"
    t.integer "registration_objective", limit: 2
    t.text "phone", comment: "JiHu-specific column"
    t.boolean "requires_credit_card_verification", default: false, null: false
    t.text "linkedin", default: "", null: false
    t.text "twitter", default: "", null: false
    t.text "skype", default: "", null: false
    t.text "website_url", default: "", null: false
    t.text "location", default: "", null: false
    t.text "organization", default: "", null: false
    t.datetime_with_timezone "password_last_changed_at", default: -> { "now()" }, null: false, comment: "JiHu-specific column"
    t.text "onboarding_step_url"
    t.index ["password_last_changed_at"], name: "index_user_details_on_password_last_changed_at", comment: "JiHu-specific index"
    t.index ["phone"], name: "index_user_details_on_phone", unique: true, where: "(phone IS NOT NULL)", comment: "JiHu-specific index"
    t.index ["provisioned_by_group_id", "user_id"], name: "idx_user_details_on_provisioned_by_group_id_user_id"
    t.index ["user_id"], name: "index_user_details_on_user_id", unique: true
    t.check_constraint "char_length(linkedin) <= 500", name: "check_7d6489f8f3"
    t.check_constraint "char_length(location) <= 500", name: "check_8a7fcf8a60"
    t.check_constraint "char_length(onboarding_step_url) <= 2000", name: "check_4f51129940"
    t.check_constraint "char_length(organization) <= 500", name: "check_7b246dad73"
    t.check_constraint "char_length(phone) <= 50", name: "check_a73b398c60"
    t.check_constraint "char_length(pronouns) <= 50", name: "check_eeeaf8d4f0"
    t.check_constraint "char_length(pronunciation) <= 255", name: "check_f932ed37db"
    t.check_constraint "char_length(skype) <= 500", name: "check_444573ee52"
    t.check_constraint "char_length(twitter) <= 500", name: "check_466a25be35"
    t.check_constraint "char_length(webauthn_xid) <= 100", name: "check_245664af82"
    t.check_constraint "char_length(website_url) <= 500", name: "check_7fe2044093"
  end

  create_table "user_follow_users", primary_key: ["follower_id", "followee_id"], force: :cascade do |t|
    t.integer "follower_id", null: false
    t.integer "followee_id", null: false
    t.index ["followee_id"], name: "user_follow_users_followee_id_idx"
  end

  create_table "user_group_callouts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.integer "feature_name", limit: 2, null: false
    t.datetime_with_timezone "dismissed_at"
    t.index ["group_id"], name: "index_user_group_callouts_on_group_id"
    t.index ["user_id", "feature_name", "group_id"], name: "index_group_user_callouts_feature", unique: true
  end

  create_table "user_highest_roles", primary_key: "user_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "updated_at", null: false
    t.integer "highest_access_level"
    t.index ["user_id", "highest_access_level"], name: "index_user_highest_roles_on_user_id_and_highest_access_level"
  end

  create_table "user_interacted_projects", primary_key: ["project_id", "user_id"], force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.index ["user_id"], name: "index_user_interacted_projects_on_user_id"
  end

  create_table "user_namespace_callouts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "namespace_id", null: false
    t.datetime_with_timezone "dismissed_at"
    t.integer "feature_name", limit: 2, null: false
    t.index ["namespace_id"], name: "index_user_namespace_callouts_on_namespace_id"
    t.index ["user_id", "feature_name", "namespace_id"], name: "index_ns_user_callouts_feature", unique: true
  end

  create_table "user_permission_export_uploads", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "file_store"
    t.integer "status", limit: 2, default: 0, null: false
    t.text "file"
    t.index ["user_id", "status"], name: "index_user_permission_export_uploads_on_user_id_and_status"
    t.check_constraint "char_length(file) <= 255", name: "check_1956806648"
  end

  create_table "user_phone_number_validations", primary_key: "user_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "validated_at"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "international_dial_code", limit: 2, null: false
    t.integer "verification_attempts", limit: 2, default: 0, null: false
    t.integer "risk_score", limit: 2, default: 0, null: false
    t.text "country", null: false
    t.text "phone_number", null: false
    t.text "telesign_reference_xid"
    t.index ["international_dial_code", "phone_number"], name: "index_user_phone_validations_on_dial_code_phone_number"
    t.check_constraint "char_length(country) <= 3", name: "check_193736da9f"
    t.check_constraint "char_length(phone_number) <= 12", name: "check_d2f31fc815"
    t.check_constraint "char_length(telesign_reference_xid) <= 255", name: "check_d7af4d3eb5"
  end

  create_table "user_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "issue_notes_filter", limit: 2, default: 0, null: false
    t.integer "merge_request_notes_filter", limit: 2, default: 0, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "epics_sort"
    t.integer "roadmap_epics_state"
    t.integer "epic_notes_filter", limit: 2, default: 0, null: false
    t.string "issues_sort"
    t.string "merge_requests_sort"
    t.string "roadmaps_sort"
    t.integer "first_day_of_week"
    t.string "timezone"
    t.boolean "time_display_relative"
    t.boolean "time_format_in_24h"
    t.string "projects_sort", limit: 64
    t.boolean "show_whitespace_in_diffs", default: true, null: false
    t.boolean "sourcegraph_enabled"
    t.boolean "setup_for_company"
    t.boolean "render_whitespace_in_code"
    t.integer "tab_width", limit: 2
    t.boolean "view_diffs_file_by_file", default: false, null: false
    t.boolean "gitpod_enabled", default: false, null: false
    t.boolean "markdown_surround_selection", default: true, null: false
    t.text "diffs_deletion_color"
    t.text "diffs_addition_color"
    t.boolean "markdown_automatic_lists", default: true, null: false
    t.boolean "use_legacy_web_ide", default: false, null: false
    t.index ["gitpod_enabled"], name: "index_user_preferences_on_gitpod_enabled"
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
    t.check_constraint "char_length(diffs_addition_color) <= 7", name: "check_d07ccd35f7"
    t.check_constraint "char_length(diffs_deletion_color) <= 7", name: "check_89bf269f41"
  end

  create_table "user_project_callouts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.integer "feature_name", limit: 2, null: false
    t.datetime_with_timezone "dismissed_at"
    t.index ["project_id"], name: "index_user_project_callouts_on_project_id"
    t.index ["user_id", "feature_name", "project_id"], name: "index_project_user_callouts_feature", unique: true
  end

  create_table "user_statuses", primary_key: "user_id", id: :serial, force: :cascade do |t|
    t.integer "cached_markdown_version"
    t.string "emoji", default: "speech_balloon", null: false
    t.string "message", limit: 100
    t.string "message_html"
    t.integer "availability", limit: 2, default: 0, null: false
    t.datetime_with_timezone "clear_status_at"
    t.index ["clear_status_at"], name: "index_user_statuses_on_clear_status_at_not_null", where: "(clear_status_at IS NOT NULL)"
    t.index ["user_id"], name: "index_user_statuses_on_user_id"
  end

  create_table "user_synced_attributes_metadata", id: :serial, force: :cascade do |t|
    t.boolean "name_synced", default: false
    t.boolean "email_synced", default: false
    t.boolean "location_synced", default: false
    t.integer "user_id", null: false
    t.string "provider"
    t.index ["user_id"], name: "index_user_synced_attributes_metadata_on_user_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.boolean "admin", default: false, null: false
    t.integer "projects_limit", null: false
    t.string "skype", default: "", null: false
    t.string "linkedin", default: "", null: false
    t.string "twitter", default: "", null: false
    t.integer "failed_attempts", default: 0
    t.datetime "locked_at"
    t.string "username"
    t.boolean "can_create_group", default: true, null: false
    t.boolean "can_create_team", default: true, null: false
    t.string "state"
    t.integer "color_scheme_id", default: 1, null: false
    t.datetime "password_expires_at"
    t.integer "created_by_id"
    t.datetime "last_credential_check_at"
    t.string "avatar"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "hide_no_ssh_key", default: false
    t.string "website_url", default: "", null: false
    t.datetime "admin_email_unsubscribed_at"
    t.string "notification_email"
    t.boolean "hide_no_password", default: false
    t.boolean "password_automatically_set", default: false
    t.string "location"
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.boolean "otp_required_for_login", default: false, null: false
    t.text "otp_backup_codes"
    t.string "public_email"
    t.integer "dashboard", default: 0
    t.integer "project_view", default: 0
    t.integer "consumed_timestep"
    t.integer "layout", default: 0
    t.boolean "hide_project_limit", default: false
    t.text "note"
    t.string "unlock_token"
    t.datetime "otp_grace_period_started_at"
    t.boolean "external", default: false
    t.string "incoming_email_token"
    t.string "organization"
    t.boolean "auditor", default: false, null: false
    t.boolean "require_two_factor_authentication_from_group", default: false, null: false
    t.integer "two_factor_grace_period", default: 48, null: false
    t.date "last_activity_on"
    t.boolean "notified_of_own_activity"
    t.string "preferred_language"
    t.boolean "email_opted_in"
    t.string "email_opted_in_ip"
    t.integer "email_opted_in_source_id"
    t.datetime "email_opted_in_at"
    t.integer "theme_id", limit: 2
    t.integer "accepted_term_id"
    t.string "feed_token"
    t.boolean "private_profile", default: false, null: false
    t.integer "roadmap_layout", limit: 2
    t.boolean "include_private_contributions"
    t.string "commit_email"
    t.integer "group_view"
    t.integer "managing_group_id"
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "static_object_token", limit: 255
    t.integer "role", limit: 2
    t.integer "user_type", limit: 2
    t.text "static_object_token_encrypted"
    t.datetime_with_timezone "otp_secret_expires_at"
    t.boolean "onboarding_in_progress", default: false, null: false
    t.index "lower((email)::text)", name: "index_on_users_lower_email"
    t.index "lower((name)::text)", name: "index_on_users_name_lower"
    t.index "lower((username)::text)", name: "index_on_users_lower_username"
    t.index ["accepted_term_id"], name: "index_users_on_accepted_term_id"
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email"], name: "index_users_on_email_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["feed_token"], name: "index_users_on_feed_token"
    t.index ["group_view"], name: "index_users_on_group_view"
    t.index ["id", "last_activity_on"], name: "index_users_on_id_and_last_activity_on_for_active_human_service", where: "(((state)::text = 'active'::text) AND ((user_type IS NULL) OR (user_type = 4)))"
    t.index ["id"], name: "active_billable_users", where: "(((state)::text = 'active'::text) AND ((user_type IS NULL) OR (user_type = ANY (ARRAY[NULL::integer, 6, 4]))) AND ((user_type IS NULL) OR (user_type <> ALL ('{2,6,1,3,7,8}'::smallint[]))))"
    t.index ["id"], name: "index_users_with_static_object_token", where: "((static_object_token IS NOT NULL) AND (static_object_token_encrypted IS NULL))"
    t.index ["id"], name: "tmp_idx_where_user_details_fields_filled", where: "(((COALESCE(linkedin, ''::character varying))::text IS DISTINCT FROM ''::text) OR ((COALESCE(twitter, ''::character varying))::text IS DISTINCT FROM ''::text) OR ((COALESCE(skype, ''::character varying))::text IS DISTINCT FROM ''::text) OR ((COALESCE(website_url, ''::character varying))::text IS DISTINCT FROM ''::text) OR ((COALESCE(location, ''::character varying))::text IS DISTINCT FROM ''::text) OR ((COALESCE(organization, ''::character varying))::text IS DISTINCT FROM ''::text))"
    t.index ["id"], name: "users_forbidden_state_idx", where: "((confirmed_at IS NOT NULL) AND ((state)::text <> ALL (ARRAY['blocked'::text, 'banned'::text, 'ldap_blocked'::text])))"
    t.index ["incoming_email_token"], name: "index_users_on_incoming_email_token"
    t.index ["managing_group_id"], name: "index_users_on_managing_group_id"
    t.index ["name"], name: "index_users_on_name"
    t.index ["name"], name: "index_users_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["public_email"], name: "index_users_on_public_email_excluding_null_and_empty", where: "(((public_email)::text <> ''::text) AND (public_email IS NOT NULL))"
    t.index ["require_two_factor_authentication_from_group"], name: "index_users_on_require_two_factor_authentication_from_group", where: "(require_two_factor_authentication_from_group = true)"
    t.index ["require_two_factor_authentication_from_group"], name: "index_users_require_two_factor_authentication_from_group_false", where: "(require_two_factor_authentication_from_group = false)"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["state", "user_type"], name: "index_users_on_state_and_user_type"
    t.index ["state"], name: "index_users_on_state"
    t.index ["static_object_token"], name: "index_users_on_static_object_token", unique: true
    t.index ["unconfirmed_email"], name: "index_users_on_unconfirmed_email", where: "(unconfirmed_email IS NOT NULL)"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["user_type", "id"], name: "index_users_on_user_type_and_id"
    t.index ["username"], name: "index_users_on_username"
    t.index ["username"], name: "index_users_on_username_trigram", opclass: :gin_trgm_ops, using: :gin
    t.check_constraint "char_length(static_object_token_encrypted) <= 255", name: "check_7bde697e8e"
  end

  create_table "users_ops_dashboard_projects", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.index ["project_id"], name: "index_users_ops_dashboard_projects_on_project_id"
    t.index ["user_id", "project_id"], name: "index_users_ops_dashboard_projects_on_user_id_and_project_id", unique: true
  end

  create_table "users_security_dashboard_projects", primary_key: ["project_id", "user_id"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.index ["user_id"], name: "index_users_security_dashboard_projects_on_user_id"
  end

  create_table "users_star_projects", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "index_users_star_projects_on_project_id"
    t.index ["user_id", "project_id"], name: "index_users_star_projects_on_user_id_and_project_id", unique: true
  end

  create_table "users_statistics", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "without_groups_and_projects", default: 0, null: false
    t.integer "with_highest_role_guest", default: 0, null: false
    t.integer "with_highest_role_reporter", default: 0, null: false
    t.integer "with_highest_role_developer", default: 0, null: false
    t.integer "with_highest_role_maintainer", default: 0, null: false
    t.integer "with_highest_role_owner", default: 0, null: false
    t.integer "bots", default: 0, null: false
    t.integer "blocked", default: 0, null: false
    t.integer "with_highest_role_minimal_access", default: 0, null: false
  end

  create_table "verification_codes", primary_key: ["created_at", "visitor_id_code", "code", "phone"], comment: "JiHu-specific table", force: :cascade do |t|
    t.datetime_with_timezone "created_at", default: -> { "now()" }, null: false
    t.text "visitor_id_code", null: false
    t.text "code", null: false
    t.text "phone", null: false
    t.index ["visitor_id_code", "phone", "created_at"], name: "index_verification_codes_on_phone_and_visitor_id_code", unique: true, comment: "JiHu-specific index"
    t.check_constraint "char_length(code) <= 8", name: "check_9b84e6aaff"
    t.check_constraint "char_length(phone) <= 50", name: "check_f5684c195b"
    t.check_constraint "char_length(visitor_id_code) <= 64", name: "check_ccc542256b"
  end

  create_table "vulnerabilities", force: :cascade do |t|
    t.bigint "milestone_id"
    t.bigint "epic_id"
    t.bigint "project_id", null: false
    t.bigint "author_id", null: false
    t.bigint "updated_by_id"
    t.bigint "last_edited_by_id"
    t.date "start_date"
    t.date "due_date"
    t.datetime_with_timezone "last_edited_at"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "title", limit: 255, null: false
    t.text "title_html"
    t.text "description"
    t.text "description_html"
    t.bigint "start_date_sourcing_milestone_id"
    t.bigint "due_date_sourcing_milestone_id"
    t.integer "state", limit: 2, default: 1, null: false
    t.integer "severity", limit: 2, null: false
    t.boolean "severity_overridden", default: false
    t.integer "confidence", limit: 2
    t.boolean "confidence_overridden", default: false
    t.bigint "resolved_by_id"
    t.datetime_with_timezone "resolved_at"
    t.integer "report_type", limit: 2, null: false
    t.integer "cached_markdown_version"
    t.bigint "confirmed_by_id"
    t.datetime_with_timezone "confirmed_at"
    t.datetime_with_timezone "dismissed_at"
    t.bigint "dismissed_by_id"
    t.boolean "resolved_on_default_branch", default: false, null: false
    t.boolean "present_on_default_branch", default: true, null: false
    t.datetime_with_timezone "detected_at", default: -> { "now()" }
    t.index ["author_id"], name: "index_vulnerabilities_on_author_id"
    t.index ["confirmed_by_id"], name: "index_vulnerabilities_on_confirmed_by_id"
    t.index ["dismissed_by_id"], name: "index_vulnerabilities_on_dismissed_by_id"
    t.index ["due_date_sourcing_milestone_id"], name: "index_vulnerabilities_on_due_date_sourcing_milestone_id"
    t.index ["epic_id"], name: "index_vulnerabilities_on_epic_id"
    t.index ["id"], name: "tmp_idx_vulnerabilities_on_id_where_report_type_7_99", where: "(report_type = ANY (ARRAY[7, 99]))"
    t.index ["id"], name: "tmp_index_on_vulnerabilities_non_dismissed", where: "(state <> 2)"
    t.index ["last_edited_by_id"], name: "index_vulnerabilities_on_last_edited_by_id"
    t.index ["milestone_id"], name: "index_vulnerabilities_on_milestone_id"
    t.index ["project_id", "created_at", "present_on_default_branch"], name: "idx_vulnerabilities_partial_devops_adoption_and_default_branch", where: "(state <> 1)"
    t.index ["project_id", "id"], name: "idx_vulnerabilities_on_project_id_and_id_active_cis_dft_branch", where: "((report_type = 7) AND (state = ANY (ARRAY[1, 4])) AND (present_on_default_branch IS TRUE))"
    t.index ["project_id", "id"], name: "index_vulnerabilities_project_id_and_id_on_default_branch", where: "(present_on_default_branch IS TRUE)"
    t.index ["project_id", "state", "report_type", "present_on_default_branch", "severity", "id"], name: "index_vulnerabilities_common_finder_query_on_default_branch"
    t.index ["project_id", "state", "severity", "present_on_default_branch"], name: "index_vulnerabilities_project_id_state_severity_default_branch"
    t.index ["project_id", "state", "severity"], name: "index_vulnerabilities_on_project_id_and_state_and_severity"
    t.index ["resolved_by_id"], name: "index_vulnerabilities_on_resolved_by_id"
    t.index ["start_date_sourcing_milestone_id"], name: "index_vulnerabilities_on_start_date_sourcing_milestone_id"
    t.index ["updated_by_id"], name: "index_vulnerabilities_on_updated_by_id"
  end

  create_table "vulnerability_advisories", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.date "created_date", null: false
    t.date "published_date", null: false
    t.text "description"
    t.text "title"
    t.text "component_name"
    t.text "solution"
    t.text "not_impacted"
    t.text "cvss_v2"
    t.text "cvss_v3"
    t.text "affected_range"
    t.text "identifiers", default: [], array: true
    t.text "fixed_versions", default: [], array: true
    t.text "urls", default: [], array: true
    t.text "links", default: [], array: true
    t.check_constraint "char_length(affected_range) <= 32", name: "check_3b57023409"
    t.check_constraint "char_length(component_name) <= 2048", name: "check_4d5cd7be9c"
    t.check_constraint "char_length(cvss_v2) <= 128", name: "check_b8a17497f3"
    t.check_constraint "char_length(cvss_v3) <= 128", name: "check_aae93955fb"
    t.check_constraint "char_length(description) <= 2048", name: "check_ff9f6483b6"
    t.check_constraint "char_length(not_impacted) <= 2048", name: "check_c05a35f418"
    t.check_constraint "char_length(solution) <= 2048", name: "check_962f256a51"
    t.check_constraint "char_length(title) <= 2048", name: "check_3ab0544d19"
  end

  create_table "vulnerability_exports", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.datetime_with_timezone "started_at"
    t.datetime_with_timezone "finished_at"
    t.string "status", limit: 255, null: false
    t.string "file", limit: 255
    t.bigint "project_id"
    t.bigint "author_id", null: false
    t.integer "file_store"
    t.integer "format", limit: 2, default: 0, null: false
    t.integer "group_id"
    t.index ["author_id"], name: "index_vulnerability_exports_on_author_id"
    t.index ["file_store"], name: "index_vulnerability_exports_on_file_store"
    t.index ["group_id"], name: "index_vulnerability_exports_on_group_id_not_null", where: "(group_id IS NOT NULL)"
    t.index ["project_id"], name: "index_vulnerability_exports_on_project_id_not_null", where: "(project_id IS NOT NULL)"
  end

  create_table "vulnerability_external_issue_links", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "author_id", null: false
    t.bigint "vulnerability_id", null: false
    t.integer "link_type", limit: 2, default: 1, null: false
    t.integer "external_type", limit: 2, default: 1, null: false
    t.text "external_project_key", null: false
    t.text "external_issue_key", null: false
    t.index ["author_id"], name: "index_vulnerability_external_issue_links_on_author_id"
    t.index ["vulnerability_id", "external_type", "external_project_key", "external_issue_key"], name: "idx_vulnerability_ext_issue_links_on_vulne_id_and_ext_issue", unique: true
    t.index ["vulnerability_id", "link_type"], name: "idx_vulnerability_ext_issue_links_on_vulne_id_and_link_type", unique: true, where: "(link_type = 1)"
    t.index ["vulnerability_id"], name: "index_vulnerability_external_issue_links_on_vulnerability_id"
    t.check_constraint "char_length(external_issue_key) <= 255", name: "check_3200604f5e"
    t.check_constraint "char_length(external_project_key) <= 255", name: "check_68cffd19b0"
  end

  create_table "vulnerability_feedback", id: :serial, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "feedback_type", limit: 2, null: false
    t.integer "category", limit: 2, null: false
    t.integer "project_id", null: false
    t.integer "author_id", null: false
    t.integer "pipeline_id"
    t.integer "issue_id"
    t.string "project_fingerprint", limit: 40, null: false
    t.integer "merge_request_id"
    t.integer "comment_author_id"
    t.text "comment"
    t.datetime_with_timezone "comment_timestamp"
    t.uuid "finding_uuid"
    t.integer "dismissal_reason", limit: 2
    t.boolean "migrated_to_state_transition", default: false
    t.index ["author_id"], name: "index_vulnerability_feedback_on_author_id"
    t.index ["comment_author_id"], name: "index_vulnerability_feedback_on_comment_author_id"
    t.index ["feedback_type", "finding_uuid"], name: "index_vulnerability_feedback_on_feedback_type_and_finding_uuid"
    t.index ["finding_uuid"], name: "index_vulnerability_feedback_finding_uuid", using: :hash
    t.index ["id"], name: "index_vulnerability_feedback_on_issue_id_not_null", where: "(issue_id IS NOT NULL)"
    t.index ["id"], name: "tmp_idx_for_feedback_comment_processing", where: "(char_length(comment) > 50000)"
    t.index ["id"], name: "tmp_idx_for_vulnerability_feedback_migration", where: "((migrated_to_state_transition = false) AND (feedback_type = 0))"
    t.index ["issue_id"], name: "index_vulnerability_feedback_on_issue_id"
    t.index ["merge_request_id"], name: "index_vulnerability_feedback_on_merge_request_id"
    t.index ["pipeline_id"], name: "index_vulnerability_feedback_on_pipeline_id"
    t.index ["project_id", "category", "feedback_type", "project_fingerprint"], name: "index_vulnerability_feedback_on_common_attributes"
  end

  create_table "vulnerability_finding_evidences", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "vulnerability_occurrence_id", null: false
    t.jsonb "data", default: {}, null: false
    t.index ["vulnerability_occurrence_id"], name: "finding_evidences_on_unique_vulnerability_occurrence_id", unique: true
  end

  create_table "vulnerability_finding_links", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "vulnerability_occurrence_id", null: false
    t.text "name"
    t.text "url", null: false
    t.index ["vulnerability_occurrence_id", "name", "url"], name: "finding_link_name_url_idx", unique: true
    t.index ["vulnerability_occurrence_id", "url"], name: "finding_link_url_idx", unique: true, where: "(name IS NULL)"
    t.index ["vulnerability_occurrence_id"], name: "finding_links_on_vulnerability_occurrence_id"
    t.check_constraint "char_length(name) <= 255", name: "check_55f0a95439"
    t.check_constraint "char_length(url) <= 2048", name: "check_b7fe886df6"
  end

  create_table "vulnerability_finding_signatures", force: :cascade do |t|
    t.bigint "finding_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "algorithm_type", limit: 2, null: false
    t.binary "signature_sha", null: false
    t.index ["finding_id", "algorithm_type", "signature_sha"], name: "idx_vuln_signatures_uniqueness_signature_sha", unique: true
    t.index ["finding_id", "signature_sha"], name: "idx_vuln_signatures_on_occurrences_id_and_signature_sha", unique: true
    t.index ["finding_id"], name: "index_vulnerability_finding_signatures_on_finding_id"
  end

  create_table "vulnerability_findings_remediations", force: :cascade do |t|
    t.bigint "vulnerability_occurrence_id"
    t.bigint "vulnerability_remediation_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["vulnerability_occurrence_id", "vulnerability_remediation_id"], name: "index_vulnerability_findings_remediations_on_unique_keys", unique: true
    t.index ["vulnerability_remediation_id"], name: "index_vulnerability_findings_remediations_on_remediation_id"
  end

  create_table "vulnerability_flags", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "vulnerability_occurrence_id", null: false
    t.integer "flag_type", limit: 2, default: 0, null: false
    t.text "origin", null: false
    t.text "description", null: false
    t.index ["vulnerability_occurrence_id", "flag_type", "origin"], name: "index_vulnerability_flags_on_unique_columns", unique: true
    t.index ["vulnerability_occurrence_id"], name: "index_vulnerability_flags_on_vulnerability_occurrence_id"
    t.check_constraint "char_length(description) <= 1024", name: "check_45e743349f"
    t.check_constraint "char_length(origin) <= 255", name: "check_49c1d00032"
  end

  create_table "vulnerability_historical_statistics", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.integer "total", default: 0, null: false
    t.integer "critical", default: 0, null: false
    t.integer "high", default: 0, null: false
    t.integer "medium", default: 0, null: false
    t.integer "low", default: 0, null: false
    t.integer "unknown", default: 0, null: false
    t.integer "info", default: 0, null: false
    t.date "date", null: false
    t.integer "letter_grade", limit: 2, null: false
    t.index ["date", "id"], name: "index_vulnerability_historical_statistics_on_date_and_id"
    t.index ["project_id", "date"], name: "index_vuln_historical_statistics_on_project_id_and_date", unique: true
  end

  create_table "vulnerability_identifiers", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "project_id", null: false
    t.binary "fingerprint", null: false
    t.string "external_type", null: false
    t.string "external_id", null: false
    t.string "name", null: false
    t.text "url"
    t.index ["project_id", "fingerprint"], name: "index_vulnerability_identifiers_on_project_id_and_fingerprint", unique: true
  end

  create_table "vulnerability_issue_links", force: :cascade do |t|
    t.bigint "vulnerability_id", null: false
    t.bigint "issue_id", null: false
    t.integer "link_type", limit: 2, default: 1, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["issue_id"], name: "index_vulnerability_issue_links_on_issue_id"
    t.index ["vulnerability_id", "issue_id"], name: "idx_vulnerability_issue_links_on_vulnerability_id_and_issue_id", unique: true
    t.index ["vulnerability_id", "link_type"], name: "idx_vulnerability_issue_links_on_vulnerability_id_and_link_type", unique: true, where: "(link_type = 2)"
  end

  create_table "vulnerability_merge_request_links", force: :cascade do |t|
    t.bigint "vulnerability_id", null: false
    t.integer "merge_request_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["merge_request_id"], name: "index_vulnerability_merge_request_links_on_merge_request_id"
    t.index ["vulnerability_id", "merge_request_id"], name: "unique_vuln_merge_request_link_vuln_id_and_mr_id", unique: true
  end

  create_table "vulnerability_occurrence_identifiers", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "occurrence_id", null: false
    t.bigint "identifier_id", null: false
    t.index ["identifier_id"], name: "index_vulnerability_occurrence_identifiers_on_identifier_id"
    t.index ["occurrence_id", "identifier_id"], name: "index_vulnerability_occurrence_identifiers_on_unique_keys", unique: true
  end

  create_table "vulnerability_occurrence_pipelines", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "occurrence_id", null: false
    t.integer "pipeline_id", null: false
    t.index ["occurrence_id", "id"], name: "index_vulnerability_occurrence_pipelines_occurrence_id_and_id", order: { id: :desc }
    t.index ["occurrence_id", "pipeline_id"], name: "vulnerability_occurrence_pipelines_on_unique_keys", unique: true
    t.index ["pipeline_id"], name: "index_vulnerability_occurrence_pipelines_on_pipeline_id"
  end

  create_table "vulnerability_occurrences", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "severity", limit: 2, null: false
    t.integer "confidence", limit: 2
    t.integer "report_type", limit: 2, null: false
    t.integer "project_id", null: false
    t.bigint "scanner_id", null: false
    t.bigint "primary_identifier_id", null: false
    t.binary "project_fingerprint", null: false
    t.binary "location_fingerprint", null: false
    t.string "uuid", limit: 36, null: false
    t.string "name", null: false
    t.string "metadata_version", null: false
    t.text "raw_metadata", null: false
    t.bigint "vulnerability_id"
    t.jsonb "details", default: {}, null: false
    t.text "description"
    t.text "message"
    t.text "solution"
    t.text "cve"
    t.jsonb "location"
    t.integer "detection_method", limit: 2, default: 0, null: false
    t.uuid "uuid_convert_string_to_uuid", default: "00000000-0000-0000-0000-000000000000", null: false
    t.index "(((location -> 'kubernetes_resource'::text) -> 'agent_id'::text))", name: "index_vulnerability_occurrences_on_location_k8s_agent_id", where: "(report_type = 7)", using: :gin
    t.index "(((location -> 'kubernetes_resource'::text) -> 'cluster_id'::text))", name: "index_vulnerability_occurrences_on_location_k8s_cluster_id", where: "(report_type = 7)", using: :gin
    t.index "((location -> 'image'::text))", name: "index_vulnerability_occurrences_on_location_image", where: "(report_type = ANY (ARRAY[2, 7]))", using: :gin
    t.index "project_id, report_type, encode(project_fingerprint, 'hex'::text)", name: "index_vulnerability_occurrences_for_issue_links_migration"
    t.index ["primary_identifier_id"], name: "index_vulnerability_occurrences_on_primary_identifier_id"
    t.index ["project_fingerprint"], name: "index_vulnerability_occurrences_on_project_fingerprint"
    t.index ["project_id", "report_type", "project_fingerprint"], name: "index_vulnerability_occurrences_deduplication"
    t.index ["scanner_id"], name: "index_vulnerability_occurrences_on_scanner_id"
    t.index ["uuid"], name: "index_vulnerability_occurrences_on_uuid", unique: true
    t.index ["vulnerability_id"], name: "index_vulnerability_occurrences_on_vulnerability_id"
    t.check_constraint "char_length(cve) <= 48400", name: "check_f602da68dd"
    t.check_constraint "char_length(description) <= 15000", name: "check_ade261da6b"
    t.check_constraint "char_length(message) <= 3000", name: "check_df6dd20219"
    t.check_constraint "char_length(solution) <= 7000", name: "check_4a3a60f2ba"
  end

  create_table "vulnerability_reads", force: :cascade do |t|
    t.bigint "vulnerability_id", null: false
    t.bigint "project_id", null: false
    t.bigint "scanner_id", null: false
    t.integer "report_type", limit: 2, null: false
    t.integer "severity", limit: 2, null: false
    t.integer "state", limit: 2, null: false
    t.boolean "has_issues", default: false, null: false
    t.boolean "resolved_on_default_branch", default: false, null: false
    t.uuid "uuid", null: false
    t.text "location_image"
    t.text "cluster_agent_id"
    t.bigint "casted_cluster_agent_id"
    t.bigint "namespace_id"
    t.index ["casted_cluster_agent_id"], name: "index_cis_vulnerability_reads_on_cluster_agent_id", where: "(report_type = 7)"
    t.index ["casted_cluster_agent_id"], name: "index_vuln_reads_on_casted_cluster_agent_id_where_it_is_null", where: "(casted_cluster_agent_id IS NOT NULL)"
    t.index ["cluster_agent_id"], name: "index_vulnerability_reads_on_cluster_agent_id", where: "(report_type = 7)"
    t.index ["id"], name: "tmp_index_cis_vulnerability_reads_on_id", where: "(report_type = 7)"
    t.index ["location_image"], name: "index_vulnerability_reads_on_location_image", where: "(report_type = ANY (ARRAY[2, 7]))"
    t.index ["namespace_id", "report_type", "severity", "vulnerability_id"], name: "index_vulnerability_reads_on_namespace_type_severity_id"
    t.index ["namespace_id", "state", "report_type", "severity", "vulnerability_id"], name: "index_group_vulnerability_reads_common_finder_query_desc", order: { severity: :desc, vulnerability_id: :desc }
    t.index ["namespace_id", "state", "report_type", "severity", "vulnerability_id"], name: "index_vulnerability_reads_common_finder_query_with_namespace_id", order: { vulnerability_id: :desc }
    t.index ["namespace_id", "state", "severity", "vulnerability_id"], name: "index_vuln_reads_on_namespace_id_state_severity_and_vuln_id", order: { vulnerability_id: :desc }
    t.index ["project_id", "location_image"], name: "index_vulnerability_reads_on_location_image_partial", where: "((report_type = ANY (ARRAY[2, 7])) AND (location_image IS NOT NULL))"
    t.index ["project_id", "state", "id"], name: "index_vuln_reads_on_resolved_on_default_branch", where: "(resolved_on_default_branch IS TRUE)"
    t.index ["project_id", "state", "report_type", "severity", "vulnerability_id"], name: "index_vulnerability_reads_common_finder_query", order: { vulnerability_id: :desc }
    t.index ["project_id", "state", "severity", "vulnerability_id"], name: "index_vuln_reads_on_project_id_state_severity_and_vuln_id", order: { vulnerability_id: :desc }
    t.index ["scanner_id"], name: "index_vulnerability_reads_on_scanner_id"
    t.index ["uuid"], name: "index_vulnerability_reads_on_uuid", unique: true
    t.index ["vulnerability_id"], name: "index_vulnerability_reads_on_vulnerability_id", unique: true
    t.check_constraint "char_length(cluster_agent_id) <= 10", name: "check_a105eb825a"
    t.check_constraint "char_length(location_image) <= 2048", name: "check_380451bdbe"
  end

  create_table "vulnerability_remediations", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "file_store", limit: 2
    t.text "summary", null: false
    t.text "file", null: false
    t.binary "checksum", null: false, comment: "Stores the SHA256 checksum of the attached diff file"
    t.bigint "project_id", null: false
    t.index ["project_id", "checksum"], name: "index_vulnerability_remediations_on_project_id_and_checksum", unique: true
    t.check_constraint "char_length(file) <= 255", name: "check_fe3325e3ba"
    t.check_constraint "char_length(summary) <= 200", name: "check_ac0ccabff3"
  end

  create_table "vulnerability_scanners", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "project_id", null: false
    t.string "external_id", null: false
    t.string "name", null: false
    t.text "vendor", default: "GitLab", null: false
    t.index ["project_id", "external_id"], name: "index_vulnerability_scanners_on_project_id_and_external_id", unique: true
    t.check_constraint "char_length(vendor) <= 255", name: "check_37608c9db5"
  end

  create_table "vulnerability_state_transitions", force: :cascade do |t|
    t.bigint "vulnerability_id", null: false
    t.integer "to_state", limit: 2, null: false
    t.integer "from_state", limit: 2, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "author_id"
    t.text "comment"
    t.integer "dismissal_reason", limit: 2
    t.index ["author_id"], name: "index_vulnerability_state_transitions_on_author_id"
    t.index ["vulnerability_id", "id"], name: "index_vulnerability_state_transitions_id_and_vulnerability_id"
    t.check_constraint "char_length(comment) <= 50000", name: "check_fe2eb6a0f3"
    t.check_constraint "from_state <> to_state", name: "check_d1ca8ec043"
  end

  create_table "vulnerability_statistics", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.integer "total", default: 0, null: false
    t.integer "critical", default: 0, null: false
    t.integer "high", default: 0, null: false
    t.integer "medium", default: 0, null: false
    t.integer "low", default: 0, null: false
    t.integer "unknown", default: 0, null: false
    t.integer "info", default: 0, null: false
    t.integer "letter_grade", limit: 2, null: false
    t.bigint "latest_pipeline_id"
    t.index ["latest_pipeline_id"], name: "index_vulnerability_statistics_on_latest_pipeline_id"
    t.index ["letter_grade"], name: "index_vulnerability_statistics_on_letter_grade"
    t.index ["project_id"], name: "index_vulnerability_statistics_on_unique_project_id", unique: true
  end

  create_table "vulnerability_user_mentions", force: :cascade do |t|
    t.bigint "vulnerability_id", null: false
    t.integer "note_id"
    t.integer "mentioned_users_ids", array: true
    t.integer "mentioned_projects_ids", array: true
    t.integer "mentioned_groups_ids", array: true
    t.index ["note_id"], name: "index_vulnerability_user_mentions_on_note_id", unique: true, where: "(note_id IS NOT NULL)"
    t.index ["vulnerability_id", "note_id"], name: "index_vulns_user_mentions_on_vulnerability_id_and_note_id", unique: true
    t.index ["vulnerability_id"], name: "index_vulns_user_mentions_on_vulnerability_id", unique: true, where: "(note_id IS NULL)"
  end

  create_table "web_hook_logs", primary_key: ["id", "created_at"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.integer "web_hook_id", null: false
    t.string "trigger"
    t.string "url"
    t.text "request_headers"
    t.text "request_data"
    t.text "response_headers"
    t.text "response_body"
    t.string "response_status"
    t.float "execution_duration"
    t.string "internal_error_message"
    t.datetime "updated_at", null: false
    t.datetime "created_at", null: false
    t.index ["created_at", "web_hook_id"], name: "index_web_hook_logs_part_on_created_at_and_web_hook_id"
    t.index ["web_hook_id"], name: "index_web_hook_logs_part_on_web_hook_id"
  end

  create_table "web_hooks", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type", default: "ProjectHook"
    t.boolean "push_events", default: true, null: false
    t.boolean "issues_events", default: false, null: false
    t.boolean "merge_requests_events", default: false, null: false
    t.boolean "tag_push_events", default: false
    t.integer "group_id"
    t.boolean "note_events", default: false, null: false
    t.boolean "enable_ssl_verification", default: true
    t.boolean "wiki_page_events", default: false, null: false
    t.boolean "pipeline_events", default: false, null: false
    t.boolean "confidential_issues_events", default: false, null: false
    t.boolean "repository_update_events", default: false, null: false
    t.boolean "job_events", default: false, null: false
    t.boolean "confidential_note_events"
    t.text "push_events_branch_filter"
    t.string "encrypted_token"
    t.string "encrypted_token_iv"
    t.string "encrypted_url"
    t.string "encrypted_url_iv"
    t.boolean "deployment_events", default: false, null: false
    t.boolean "releases_events", default: false, null: false
    t.boolean "feature_flag_events", default: false, null: false
    t.boolean "member_events", default: false, null: false
    t.boolean "subgroup_events", default: false, null: false
    t.integer "recent_failures", limit: 2, default: 0, null: false
    t.integer "backoff_count", limit: 2, default: 0, null: false
    t.datetime_with_timezone "disabled_until"
    t.binary "encrypted_url_variables"
    t.binary "encrypted_url_variables_iv"
    t.integer "integration_id"
    t.integer "branch_filter_strategy", limit: 2, default: 0, null: false
    t.index ["group_id"], name: "index_on_group_id_on_webhooks"
    t.index ["group_id"], name: "index_web_hooks_on_group_id", where: "((type)::text = 'GroupHook'::text)"
    t.index ["integration_id"], name: "index_web_hooks_on_integration_id"
    t.index ["project_id", "recent_failures"], name: "index_web_hooks_on_project_id_recent_failures"
    t.index ["project_id"], name: "index_web_hooks_on_project_id"
    t.index ["type"], name: "index_web_hooks_on_type"
  end

  create_table "webauthn_registrations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "counter", default: 0, null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.text "credential_xid", null: false
    t.text "name", null: false
    t.text "public_key", null: false
    t.integer "u2f_registration_id"
    t.index ["credential_xid"], name: "index_webauthn_registrations_on_credential_xid", unique: true
    t.index ["u2f_registration_id"], name: "index_webauthn_registrations_on_u2f_registration_id", where: "(u2f_registration_id IS NOT NULL)"
    t.index ["user_id"], name: "index_webauthn_registrations_on_user_id"
    t.check_constraint "char_length(credential_xid) <= 1364", name: "check_f5ab2b551a"
    t.check_constraint "char_length(name) <= 255", name: "check_2f02e74321"
  end

  create_table "wiki_page_meta", id: :serial, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "title", limit: 255, null: false
    t.index ["project_id"], name: "index_wiki_page_meta_on_project_id"
  end

  create_table "wiki_page_slugs", id: :serial, force: :cascade do |t|
    t.boolean "canonical", default: false, null: false
    t.bigint "wiki_page_meta_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "slug", limit: 2048, null: false
    t.index ["slug", "wiki_page_meta_id"], name: "index_wiki_page_slugs_on_slug_and_wiki_page_meta_id", unique: true
    t.index ["wiki_page_meta_id"], name: "index_wiki_page_slugs_on_wiki_page_meta_id"
    t.index ["wiki_page_meta_id"], name: "one_canonical_wiki_page_slug_per_metadata", unique: true, where: "(canonical = true)"
  end

  create_table "work_item_hierarchy_restrictions", force: :cascade do |t|
    t.bigint "parent_type_id", null: false
    t.bigint "child_type_id", null: false
    t.integer "maximum_depth", limit: 2
    t.index ["child_type_id"], name: "index_work_item_hierarchy_restrictions_on_child_type_id"
    t.index ["parent_type_id", "child_type_id"], name: "index_work_item_hierarchy_restrictions_on_parent_and_child", unique: true
    t.index ["parent_type_id"], name: "index_work_item_hierarchy_restrictions_on_parent_type_id"
  end

  create_table "work_item_parent_links", force: :cascade do |t|
    t.bigint "work_item_id", null: false
    t.bigint "work_item_parent_id", null: false
    t.integer "relative_position"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index ["work_item_id"], name: "index_work_item_parent_links_on_work_item_id", unique: true
    t.index ["work_item_parent_id"], name: "index_work_item_parent_links_on_work_item_parent_id"
  end

  create_table "work_item_progresses", primary_key: "issue_id", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "progress", limit: 2, default: 0, null: false
  end

  create_table "work_item_types", force: :cascade do |t|
    t.integer "base_type", limit: 2, default: 0, null: false
    t.integer "cached_markdown_version"
    t.text "name", null: false
    t.text "description"
    t.text "description_html"
    t.text "icon_name"
    t.bigint "namespace_id"
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.index "btrim(lower(name)), ((namespace_id IS NULL))", name: "idx_work_item_types_on_namespace_id_and_name_null_namespace", unique: true, where: "(namespace_id IS NULL)"
    t.index "namespace_id, btrim(lower(name))", name: "work_item_types_namespace_id_and_name_unique", unique: true
    t.check_constraint "char_length(icon_name) <= 255", name: "check_fecb3a98d1"
    t.check_constraint "char_length(name) <= 255", name: "check_104d2410f6"
  end

  create_table "x509_certificates", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "subject_key_identifier", limit: 255, null: false
    t.string "subject", limit: 512, null: false
    t.string "email", limit: 255, null: false
    t.binary "serial_number", null: false
    t.integer "certificate_status", limit: 2, default: 0, null: false
    t.bigint "x509_issuer_id", null: false
    t.index ["subject_key_identifier"], name: "index_x509_certificates_on_subject_key_identifier"
    t.index ["x509_issuer_id"], name: "index_x509_certificates_on_x509_issuer_id"
  end

  create_table "x509_commit_signatures", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.bigint "project_id", null: false
    t.bigint "x509_certificate_id", null: false
    t.binary "commit_sha", null: false
    t.integer "verification_status", limit: 2, default: 0, null: false
    t.index ["commit_sha"], name: "index_x509_commit_signatures_on_commit_sha"
    t.index ["project_id"], name: "index_x509_commit_signatures_on_project_id"
    t.index ["x509_certificate_id"], name: "index_x509_commit_signatures_on_x509_certificate_id"
  end

  create_table "x509_issuers", force: :cascade do |t|
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.string "subject_key_identifier", limit: 255, null: false
    t.string "subject", limit: 255, null: false
    t.string "crl_url", limit: 255, null: false
    t.index ["subject_key_identifier"], name: "index_x509_issuers_on_subject_key_identifier"
  end

  create_table "zentao_tracker_data", force: :cascade do |t|
    t.bigint "integration_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.binary "encrypted_url"
    t.binary "encrypted_url_iv"
    t.binary "encrypted_api_url"
    t.binary "encrypted_api_url_iv"
    t.binary "encrypted_zentao_product_xid"
    t.binary "encrypted_zentao_product_xid_iv"
    t.binary "encrypted_api_token"
    t.binary "encrypted_api_token_iv"
    t.index ["integration_id"], name: "index_zentao_tracker_data_on_integration_id"
  end

  create_table "zoom_meetings", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "issue_id", null: false
    t.datetime_with_timezone "created_at", null: false
    t.datetime_with_timezone "updated_at", null: false
    t.integer "issue_status", limit: 2, default: 1, null: false
    t.string "url", limit: 255
    t.index ["issue_id", "issue_status"], name: "index_zoom_meetings_on_issue_id_and_issue_status", unique: true, where: "(issue_status = 1)"
    t.index ["issue_id"], name: "index_zoom_meetings_on_issue_id"
    t.index ["issue_status"], name: "index_zoom_meetings_on_issue_status"
    t.index ["project_id"], name: "index_zoom_meetings_on_project_id"
  end

  add_foreign_key "agent_activity_events", "cluster_agent_tokens", column: "agent_token_id", name: "fk_c8b006d40f", on_delete: :nullify
  add_foreign_key "agent_activity_events", "cluster_agents", column: "agent_id", name: "fk_c815368376", on_delete: :cascade
  add_foreign_key "agent_activity_events", "merge_requests", name: "fk_3af186389b", on_delete: :nullify
  add_foreign_key "agent_activity_events", "projects", name: "fk_256c631779", on_delete: :nullify
  add_foreign_key "agent_activity_events", "users", name: "fk_d6f785c9fc", on_delete: :nullify
  add_foreign_key "agent_group_authorizations", "cluster_agents", column: "agent_id", name: "fk_fb70782616", on_delete: :cascade
  add_foreign_key "agent_group_authorizations", "namespaces", column: "group_id", name: "fk_2c9f941965", on_delete: :cascade
  add_foreign_key "agent_project_authorizations", "cluster_agents", column: "agent_id", name: "fk_b7fe9b4777", on_delete: :cascade
  add_foreign_key "agent_project_authorizations", "projects", name: "fk_1d30bb4987", on_delete: :cascade
  add_foreign_key "alert_management_alert_assignees", "alert_management_alerts", column: "alert_id", on_delete: :cascade
  add_foreign_key "alert_management_alert_assignees", "users", on_delete: :cascade
  add_foreign_key "alert_management_alert_metric_images", "alert_management_alerts", column: "alert_id", on_delete: :cascade
  add_foreign_key "alert_management_alert_user_mentions", "alert_management_alerts", on_delete: :cascade
  add_foreign_key "alert_management_alert_user_mentions", "notes", on_delete: :cascade
  add_foreign_key "alert_management_alerts", "environments", name: "fk_aad61aedca", on_delete: :nullify
  add_foreign_key "alert_management_alerts", "issues", name: "fk_2358b75436", on_delete: :nullify
  add_foreign_key "alert_management_alerts", "projects", name: "fk_9e49e5c2b7", on_delete: :cascade
  add_foreign_key "alert_management_alerts", "prometheus_alerts", name: "fk_51ab4b6089", on_delete: :cascade
  add_foreign_key "alert_management_http_integrations", "projects", on_delete: :cascade
  add_foreign_key "allowed_email_domains", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_aggregations", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_group_stages", "analytics_cycle_analytics_group_value_streams", column: "group_value_stream_id", name: "fk_analytics_cycle_analytics_group_stages_group_value_stream_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_group_stages", "analytics_cycle_analytics_stage_event_hashes", column: "stage_event_hash_id", name: "fk_3078345d6d", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_group_stages", "labels", column: "end_event_label_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_group_stages", "labels", column: "start_event_label_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_group_stages", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_group_value_streams", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_project_stages", "analytics_cycle_analytics_project_value_streams", column: "project_value_stream_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_project_stages", "analytics_cycle_analytics_stage_event_hashes", column: "stage_event_hash_id", name: "fk_c3339bdfc9", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_project_stages", "labels", column: "end_event_label_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_project_stages", "labels", column: "start_event_label_id", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_project_stages", "projects", on_delete: :cascade
  add_foreign_key "analytics_cycle_analytics_project_value_streams", "projects", on_delete: :cascade
  add_foreign_key "analytics_devops_adoption_segments", "namespaces", column: "display_namespace_id", name: "fk_190a24754d", on_delete: :cascade
  add_foreign_key "analytics_devops_adoption_segments", "namespaces", name: "fk_f5aa768998", on_delete: :cascade
  add_foreign_key "analytics_devops_adoption_snapshots", "namespaces", name: "fk_78c9eac821", on_delete: :cascade
  add_foreign_key "analytics_language_trend_repository_languages", "programming_languages", on_delete: :cascade
  add_foreign_key "analytics_language_trend_repository_languages", "projects", on_delete: :cascade
  add_foreign_key "application_settings", "namespaces", column: "custom_project_templates_group_id", on_delete: :nullify
  add_foreign_key "application_settings", "namespaces", column: "instance_administrators_group_id", name: "fk_e8a145f3a7", on_delete: :nullify
  add_foreign_key "application_settings", "projects", column: "file_template_project_id", name: "fk_ec757bd087", on_delete: :nullify
  add_foreign_key "application_settings", "projects", column: "instance_administration_project_id", on_delete: :nullify
  add_foreign_key "application_settings", "push_rules", name: "fk_693b8795e4", on_delete: :nullify
  add_foreign_key "application_settings", "users", column: "usage_stats_set_by_user_id", name: "fk_964370041d", on_delete: :nullify
  add_foreign_key "approval_merge_request_rule_sources", "approval_merge_request_rules", on_delete: :cascade
  add_foreign_key "approval_merge_request_rule_sources", "approval_project_rules", on_delete: :cascade
  add_foreign_key "approval_merge_request_rules", "merge_requests", on_delete: :cascade
  add_foreign_key "approval_merge_request_rules", "security_orchestration_policy_configurations", name: "fk_5822f009ea", on_delete: :cascade
  add_foreign_key "approval_merge_request_rules_approved_approvers", "approval_merge_request_rules", on_delete: :cascade
  add_foreign_key "approval_merge_request_rules_approved_approvers", "users", on_delete: :cascade
  add_foreign_key "approval_merge_request_rules_groups", "approval_merge_request_rules", on_delete: :cascade
  add_foreign_key "approval_merge_request_rules_groups", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "approval_merge_request_rules_users", "approval_merge_request_rules", on_delete: :cascade
  add_foreign_key "approval_merge_request_rules_users", "users", on_delete: :cascade
  add_foreign_key "approval_project_rules", "projects", on_delete: :cascade
  add_foreign_key "approval_project_rules", "security_orchestration_policy_configurations", name: "fk_efa5a1e3fb", on_delete: :cascade
  add_foreign_key "approval_project_rules_groups", "approval_project_rules", on_delete: :cascade
  add_foreign_key "approval_project_rules_groups", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "approval_project_rules_protected_branches", "approval_project_rules", on_delete: :cascade
  add_foreign_key "approval_project_rules_protected_branches", "protected_branches", on_delete: :cascade
  add_foreign_key "approval_project_rules_users", "approval_project_rules", on_delete: :cascade
  add_foreign_key "approval_project_rules_users", "users", on_delete: :cascade
  add_foreign_key "approvals", "merge_requests", name: "fk_310d714958", on_delete: :cascade
  add_foreign_key "approver_groups", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "atlassian_identities", "users", on_delete: :cascade
  add_foreign_key "audit_events_external_audit_event_destinations", "namespaces", on_delete: :cascade
  add_foreign_key "audit_events_streaming_event_type_filters", "audit_events_external_audit_event_destinations", column: "external_audit_event_destination_id", on_delete: :cascade
  add_foreign_key "audit_events_streaming_headers", "audit_events_external_audit_event_destinations", column: "external_audit_event_destination_id", on_delete: :cascade
  add_foreign_key "authentication_events", "users", on_delete: :nullify
  add_foreign_key "aws_roles", "users", on_delete: :cascade
  add_foreign_key "badges", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "badges", "projects", on_delete: :cascade
  add_foreign_key "banned_users", "users", on_delete: :cascade
  add_foreign_key "batched_background_migration_job_transition_logs", "batched_background_migration_jobs", on_delete: :cascade
  add_foreign_key "batched_background_migration_jobs", "batched_background_migrations", on_delete: :cascade
  add_foreign_key "board_assignees", "boards", on_delete: :cascade
  add_foreign_key "board_assignees", "users", column: "assignee_id", on_delete: :cascade
  add_foreign_key "board_group_recent_visits", "boards", on_delete: :cascade
  add_foreign_key "board_group_recent_visits", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "board_group_recent_visits", "users", on_delete: :cascade
  add_foreign_key "board_labels", "boards", on_delete: :cascade
  add_foreign_key "board_labels", "labels", on_delete: :cascade
  add_foreign_key "board_project_recent_visits", "boards", on_delete: :cascade
  add_foreign_key "board_project_recent_visits", "projects", on_delete: :cascade
  add_foreign_key "board_project_recent_visits", "users", on_delete: :cascade
  add_foreign_key "board_user_preferences", "boards", on_delete: :cascade
  add_foreign_key "board_user_preferences", "users", on_delete: :cascade
  add_foreign_key "boards", "iterations_cadences", column: "iteration_cadence_id", name: "fk_ab0a250ff6", on_delete: :cascade
  add_foreign_key "boards", "namespaces", column: "group_id", name: "fk_1e9a074a35", on_delete: :cascade
  add_foreign_key "boards", "projects", name: "fk_f15266b5f9", on_delete: :cascade
  add_foreign_key "boards_epic_board_labels", "boards_epic_boards", column: "epic_board_id", on_delete: :cascade
  add_foreign_key "boards_epic_board_labels", "labels", on_delete: :cascade
  add_foreign_key "boards_epic_board_positions", "boards_epic_boards", column: "epic_board_id", on_delete: :cascade
  add_foreign_key "boards_epic_board_positions", "epics", on_delete: :cascade
  add_foreign_key "boards_epic_board_recent_visits", "boards_epic_boards", column: "epic_board_id", on_delete: :cascade
  add_foreign_key "boards_epic_board_recent_visits", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "boards_epic_board_recent_visits", "users", on_delete: :cascade
  add_foreign_key "boards_epic_boards", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "boards_epic_list_user_preferences", "boards_epic_lists", column: "epic_list_id", name: "fk_95eac55851", on_delete: :cascade
  add_foreign_key "boards_epic_list_user_preferences", "users", name: "fk_f5f2fe5c1f", on_delete: :cascade
  add_foreign_key "boards_epic_lists", "boards_epic_boards", column: "epic_board_id", on_delete: :cascade
  add_foreign_key "boards_epic_lists", "labels", on_delete: :cascade
  add_foreign_key "boards_epic_user_preferences", "boards", on_delete: :cascade
  add_foreign_key "boards_epic_user_preferences", "epics", on_delete: :cascade
  add_foreign_key "boards_epic_user_preferences", "users", on_delete: :cascade
  add_foreign_key "broadcast_messages", "namespaces", name: "fk_7bf2ec43da", on_delete: :cascade
  add_foreign_key "bulk_import_configurations", "bulk_imports", on_delete: :cascade
  add_foreign_key "bulk_import_entities", "bulk_import_entities", column: "parent_id", name: "fk_a44ff95be5", on_delete: :cascade
  add_foreign_key "bulk_import_entities", "bulk_imports", name: "fk_b69fa2b2df", on_delete: :cascade
  add_foreign_key "bulk_import_entities", "namespaces", name: "fk_88c725229f", on_delete: :cascade
  add_foreign_key "bulk_import_entities", "projects", name: "fk_d06d023c30", on_delete: :cascade
  add_foreign_key "bulk_import_export_uploads", "bulk_import_exports", column: "export_id", on_delete: :cascade
  add_foreign_key "bulk_import_exports", "namespaces", column: "group_id", name: "fk_8c6f33cebe", on_delete: :cascade
  add_foreign_key "bulk_import_exports", "projects", name: "fk_39c726d3b5", on_delete: :cascade
  add_foreign_key "bulk_import_failures", "bulk_import_entities", on_delete: :cascade
  add_foreign_key "bulk_import_trackers", "bulk_import_entities", on_delete: :cascade
  add_foreign_key "bulk_imports", "users", on_delete: :cascade
  add_foreign_key "chat_names", "integrations", name: "fk_99a1348daf", on_delete: :cascade
  add_foreign_key "chat_teams", "namespaces", on_delete: :cascade
  add_foreign_key "ci_build_needs", "ci_builds", column: "build_id", on_delete: :cascade
  add_foreign_key "ci_build_pending_states", "ci_builds", column: "build_id", on_delete: :cascade
  add_foreign_key "ci_build_report_results", "ci_builds", column: "build_id", on_delete: :cascade
  add_foreign_key "ci_build_trace_chunks", "ci_builds", column: "build_id", on_delete: :cascade
  add_foreign_key "ci_build_trace_metadata", "ci_builds", column: "build_id", on_delete: :cascade
  add_foreign_key "ci_build_trace_metadata", "ci_job_artifacts", column: "trace_artifact_id", name: "fk_21d25cac1a", on_delete: :cascade
  add_foreign_key "ci_builds", "ci_pipelines", column: "auto_canceled_by_id", name: "fk_a2141b1522", on_delete: :nullify
  add_foreign_key "ci_builds", "ci_pipelines", column: "commit_id", name: "fk_d3130c9a7f", on_delete: :cascade
  add_foreign_key "ci_builds", "ci_pipelines", column: "upstream_pipeline_id", name: "fk_87f4cefcda", on_delete: :cascade
  add_foreign_key "ci_builds", "ci_resource_groups", column: "resource_group_id", name: "fk_6661f4f0e8", on_delete: :nullify
  add_foreign_key "ci_builds", "ci_stages", column: "stage_id", name: "fk_3a9eaa254d", on_delete: :cascade
  add_foreign_key "ci_builds_metadata", "ci_builds", column: "build_id", name: "fk_e20479742e", on_delete: :cascade
  add_foreign_key "ci_builds_runner_session", "ci_builds", column: "build_id", on_delete: :cascade
  add_foreign_key "ci_daily_build_group_report_results", "ci_pipelines", column: "last_pipeline_id", on_delete: :cascade
  add_foreign_key "ci_job_artifact_states", "ci_job_artifacts", column: "job_artifact_id", on_delete: :cascade
  add_foreign_key "ci_job_artifacts", "ci_builds", column: "job_id", on_delete: :cascade
  add_foreign_key "ci_job_variables", "ci_builds", column: "job_id", on_delete: :cascade
  add_foreign_key "ci_pending_builds", "ci_builds", column: "build_id", on_delete: :cascade
  add_foreign_key "ci_pipeline_artifacts", "ci_pipelines", column: "pipeline_id", on_delete: :cascade
  add_foreign_key "ci_pipeline_chat_data", "ci_pipelines", column: "pipeline_id", on_delete: :cascade
  add_foreign_key "ci_pipeline_messages", "ci_pipelines", column: "pipeline_id", on_delete: :cascade
  add_foreign_key "ci_pipeline_metadata", "ci_pipelines", column: "pipeline_id", on_delete: :cascade
  add_foreign_key "ci_pipeline_schedule_variables", "ci_pipeline_schedules", column: "pipeline_schedule_id", name: "fk_41c35fda51", on_delete: :cascade
  add_foreign_key "ci_pipeline_variables", "ci_pipelines", column: "pipeline_id", name: "fk_f29c5f4380", on_delete: :cascade
  add_foreign_key "ci_pipelines", "ci_pipeline_schedules", column: "pipeline_schedule_id", name: "fk_3d34ab2e06", on_delete: :nullify
  add_foreign_key "ci_pipelines", "ci_pipelines", column: "auto_canceled_by_id", name: "fk_262d4c2d19", on_delete: :nullify
  add_foreign_key "ci_pipelines", "ci_refs", name: "fk_d80e161c54", on_delete: :nullify
  add_foreign_key "ci_pipelines", "external_pull_requests", name: "fk_190998ef09", on_delete: :nullify
  add_foreign_key "ci_pipelines_config", "ci_pipelines", column: "pipeline_id", on_delete: :cascade
  add_foreign_key "ci_resources", "ci_builds", column: "build_id", name: "fk_e169a8e3d5", on_delete: :nullify
  add_foreign_key "ci_resources", "ci_resource_groups", column: "resource_group_id", on_delete: :cascade
  add_foreign_key "ci_runner_namespaces", "ci_runners", column: "runner_id", on_delete: :cascade
  add_foreign_key "ci_running_builds", "ci_builds", column: "build_id", on_delete: :cascade
  add_foreign_key "ci_running_builds", "ci_runners", column: "runner_id", on_delete: :cascade
  add_foreign_key "ci_secure_file_states", "ci_secure_files", on_delete: :cascade
  add_foreign_key "ci_sources_pipelines", "ci_builds", column: "source_job_id", name: "fk_be5624bf37", on_delete: :cascade
  add_foreign_key "ci_sources_pipelines", "ci_pipelines", column: "pipeline_id", name: "fk_e1bad85861", on_delete: :cascade
  add_foreign_key "ci_sources_pipelines", "ci_pipelines", column: "source_pipeline_id", name: "fk_d4e29af7d7", on_delete: :cascade
  add_foreign_key "ci_sources_projects", "ci_pipelines", column: "pipeline_id", on_delete: :cascade
  add_foreign_key "ci_stages", "ci_pipelines", column: "pipeline_id", name: "fk_fb57e6cc56", on_delete: :cascade
  add_foreign_key "ci_trigger_requests", "ci_triggers", column: "trigger_id", name: "fk_b8ec8b7245", on_delete: :cascade
  add_foreign_key "ci_unit_test_failures", "ci_builds", column: "build_id", name: "fk_0f09856e1f", on_delete: :cascade
  add_foreign_key "ci_unit_test_failures", "ci_unit_tests", column: "unit_test_id", on_delete: :cascade
  add_foreign_key "cluster_agent_tokens", "cluster_agents", column: "agent_id", on_delete: :cascade
  add_foreign_key "cluster_agent_tokens", "users", column: "created_by_user_id", name: "fk_75008f3553", on_delete: :nullify
  add_foreign_key "cluster_agents", "projects", on_delete: :cascade
  add_foreign_key "cluster_agents", "users", column: "created_by_user_id", name: "fk_f7d43dee13", on_delete: :nullify
  add_foreign_key "cluster_enabled_grants", "namespaces", on_delete: :cascade
  add_foreign_key "cluster_groups", "clusters", on_delete: :cascade
  add_foreign_key "cluster_groups", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "cluster_platforms_kubernetes", "clusters", on_delete: :cascade
  add_foreign_key "cluster_projects", "clusters", on_delete: :cascade
  add_foreign_key "cluster_projects", "projects", on_delete: :cascade
  add_foreign_key "cluster_providers_aws", "clusters", on_delete: :cascade
  add_foreign_key "cluster_providers_gcp", "clusters", on_delete: :cascade
  add_foreign_key "clusters", "projects", column: "management_project_id", name: "fk_f05c5e5a42", on_delete: :nullify
  add_foreign_key "clusters", "users", on_delete: :nullify
  add_foreign_key "clusters_applications_cert_managers", "clusters", on_delete: :cascade
  add_foreign_key "clusters_applications_cilium", "clusters", on_delete: :cascade
  add_foreign_key "clusters_applications_crossplane", "clusters", on_delete: :cascade
  add_foreign_key "clusters_applications_helm", "clusters", on_delete: :cascade
  add_foreign_key "clusters_applications_ingress", "clusters", on_delete: :cascade
  add_foreign_key "clusters_applications_jupyter", "clusters", on_delete: :cascade
  add_foreign_key "clusters_applications_jupyter", "oauth_applications", on_delete: :nullify
  add_foreign_key "clusters_applications_knative", "clusters", on_delete: :cascade
  add_foreign_key "clusters_applications_prometheus", "clusters", name: "fk_557e773639", on_delete: :cascade
  add_foreign_key "clusters_applications_runners", "clusters", on_delete: :cascade
  add_foreign_key "clusters_integration_prometheus", "clusters", on_delete: :cascade
  add_foreign_key "clusters_kubernetes_namespaces", "cluster_projects", on_delete: :nullify
  add_foreign_key "clusters_kubernetes_namespaces", "clusters", on_delete: :cascade
  add_foreign_key "clusters_kubernetes_namespaces", "environments", on_delete: :nullify
  add_foreign_key "clusters_kubernetes_namespaces", "projects", on_delete: :nullify
  add_foreign_key "commit_user_mentions", "notes", on_delete: :cascade
  add_foreign_key "compliance_management_frameworks", "namespaces", name: "fk_b74c45b71f", on_delete: :cascade
  add_foreign_key "container_expiration_policies", "projects", on_delete: :cascade
  add_foreign_key "container_repositories", "projects"
  add_foreign_key "coverage_fuzzing_corpuses", "packages_packages", column: "package_id", name: "fk_ef5ebf339f", on_delete: :cascade
  add_foreign_key "coverage_fuzzing_corpuses", "projects", name: "fk_204d40056a", on_delete: :cascade
  add_foreign_key "coverage_fuzzing_corpuses", "users", name: "fk_29f6f15f82", on_delete: :cascade
  add_foreign_key "csv_issue_imports", "projects", name: "fk_e71c0ae362", on_delete: :cascade
  add_foreign_key "csv_issue_imports", "users", name: "fk_5e1572387c", on_delete: :cascade
  add_foreign_key "custom_emoji", "namespaces", on_delete: :cascade
  add_foreign_key "custom_emoji", "users", column: "creator_id", name: "fk_custom_emoji_creator_id", on_delete: :cascade
  add_foreign_key "customer_relations_contacts", "customer_relations_organizations", column: "organization_id", on_delete: :cascade
  add_foreign_key "customer_relations_contacts", "namespaces", column: "group_id", name: "fk_b91ddd9345", on_delete: :cascade
  add_foreign_key "customer_relations_organizations", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "dast_pre_scan_verifications", "dast_profiles", on_delete: :cascade
  add_foreign_key "dast_profile_schedules", "dast_profiles", name: "fk_61d52aa0e7", on_delete: :cascade
  add_foreign_key "dast_profile_schedules", "projects", name: "fk_6cca0d8800", on_delete: :cascade
  add_foreign_key "dast_profile_schedules", "users", name: "fk_aef03d62e5", on_delete: :nullify
  add_foreign_key "dast_profiles", "dast_scanner_profiles", on_delete: :cascade
  add_foreign_key "dast_profiles", "dast_site_profiles", on_delete: :cascade
  add_foreign_key "dast_profiles", "projects", name: "fk_aa76ef30e9", on_delete: :cascade
  add_foreign_key "dast_profiles_pipelines", "dast_profiles", name: "fk_cc206a8c13", on_delete: :cascade
  add_foreign_key "dast_scanner_profiles", "projects", on_delete: :cascade
  add_foreign_key "dast_scanner_profiles_builds", "dast_scanner_profiles", name: "fk_5d46286ad3", on_delete: :cascade
  add_foreign_key "dast_site_profile_secret_variables", "dast_site_profiles", on_delete: :cascade
  add_foreign_key "dast_site_profiles", "dast_sites", on_delete: :cascade
  add_foreign_key "dast_site_profiles", "projects", on_delete: :cascade
  add_foreign_key "dast_site_profiles_builds", "dast_site_profiles", name: "fk_94e80df60e", on_delete: :cascade
  add_foreign_key "dast_site_profiles_pipelines", "dast_site_profiles", name: "fk_cf05cf8fe1", on_delete: :cascade
  add_foreign_key "dast_site_tokens", "projects", on_delete: :cascade
  add_foreign_key "dast_site_validations", "dast_site_tokens", on_delete: :cascade
  add_foreign_key "dast_sites", "dast_site_validations", name: "fk_0a57f2271b", on_delete: :nullify
  add_foreign_key "dast_sites", "projects", on_delete: :cascade
  add_foreign_key "dependency_list_exports", "projects", name: "fk_d871d74675", on_delete: :cascade
  add_foreign_key "dependency_list_exports", "users", name: "fk_5b3d11e1ef", on_delete: :nullify
  add_foreign_key "dependency_proxy_blob_states", "dependency_proxy_blobs", on_delete: :cascade
  add_foreign_key "dependency_proxy_blobs", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "dependency_proxy_group_settings", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "dependency_proxy_image_ttl_group_policies", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "dependency_proxy_manifest_states", "dependency_proxy_manifests", on_delete: :cascade
  add_foreign_key "dependency_proxy_manifests", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "deploy_keys_projects", "projects", name: "fk_58a901ca7e", on_delete: :cascade
  add_foreign_key "deploy_tokens", "users", column: "creator_id", name: "fk_7082f8a288", on_delete: :nullify
  add_foreign_key "deployment_approvals", "deployments", name: "fk_2d060dfc73", on_delete: :cascade
  add_foreign_key "deployment_approvals", "protected_environment_approval_rules", column: "approval_rule_id", name: "fk_61cdbdc5b9", on_delete: :nullify
  add_foreign_key "deployment_approvals", "users", name: "fk_0f58311058", on_delete: :cascade
  add_foreign_key "deployment_clusters", "deployments", on_delete: :cascade
  add_foreign_key "deployment_merge_requests", "deployments", on_delete: :cascade
  add_foreign_key "deployment_merge_requests", "environments", name: "fk_a064ff4453", on_delete: :cascade
  add_foreign_key "deployment_merge_requests", "merge_requests", on_delete: :cascade
  add_foreign_key "deployments", "environments", name: "fk_009fd21147", on_delete: :cascade
  add_foreign_key "deployments", "projects", name: "fk_b9a3851b82", on_delete: :cascade
  add_foreign_key "description_versions", "epics", on_delete: :cascade
  add_foreign_key "description_versions", "issues", on_delete: :cascade
  add_foreign_key "description_versions", "merge_requests", on_delete: :cascade
  add_foreign_key "design_management_designs", "issues", on_delete: :cascade
  add_foreign_key "design_management_designs", "projects", on_delete: :cascade
  add_foreign_key "design_management_designs_versions", "design_management_designs", column: "design_id", name: "fk_03c671965c", on_delete: :cascade
  add_foreign_key "design_management_designs_versions", "design_management_versions", column: "version_id", name: "fk_f4d25ba00c", on_delete: :cascade
  add_foreign_key "design_management_versions", "issues", on_delete: :cascade
  add_foreign_key "design_management_versions", "users", column: "author_id", name: "fk_c1440b4896", on_delete: :nullify
  add_foreign_key "design_user_mentions", "design_management_designs", column: "design_id", on_delete: :cascade
  add_foreign_key "design_user_mentions", "notes", on_delete: :cascade
  add_foreign_key "diff_note_positions", "notes", on_delete: :cascade
  add_foreign_key "dingtalk_tracker_data", "integrations", on_delete: :cascade
  add_foreign_key "dora_configurations", "projects", on_delete: :cascade
  add_foreign_key "dora_daily_metrics", "environments", on_delete: :cascade
  add_foreign_key "draft_notes", "merge_requests", on_delete: :cascade
  add_foreign_key "draft_notes", "users", column: "author_id", on_delete: :cascade
  add_foreign_key "elastic_reindexing_slices", "elastic_reindexing_subtasks", on_delete: :cascade
  add_foreign_key "elastic_reindexing_subtasks", "elastic_reindexing_tasks", on_delete: :cascade
  add_foreign_key "elasticsearch_indexed_namespaces", "namespaces", on_delete: :cascade
  add_foreign_key "elasticsearch_indexed_projects", "projects", on_delete: :cascade
  add_foreign_key "emails", "users", name: "fk_emails_user_id", on_delete: :cascade
  add_foreign_key "environments", "merge_requests", name: "fk_01a033a308", on_delete: :nullify
  add_foreign_key "environments", "projects", name: "fk_d1c8c1da6a", on_delete: :cascade
  add_foreign_key "epic_issues", "epics", on_delete: :cascade
  add_foreign_key "epic_issues", "issues", on_delete: :cascade
  add_foreign_key "epic_metrics", "epics", on_delete: :cascade
  add_foreign_key "epic_user_mentions", "epics", on_delete: :cascade
  add_foreign_key "epic_user_mentions", "notes", on_delete: :cascade
  add_foreign_key "epics", "epics", column: "due_date_sourcing_epic_id", name: "fk_013c9f36ca", on_delete: :nullify
  add_foreign_key "epics", "epics", column: "parent_id", name: "fk_25b99c1be3", on_delete: :cascade
  add_foreign_key "epics", "epics", column: "start_date_sourcing_epic_id", name: "fk_9d480c64b2", on_delete: :nullify
  add_foreign_key "epics", "milestones", column: "due_date_sourcing_milestone_id", name: "fk_3c1fd1cccc", on_delete: :nullify
  add_foreign_key "epics", "milestones", column: "start_date_sourcing_milestone_id", name: "fk_1fbed67632", on_delete: :nullify
  add_foreign_key "epics", "namespaces", column: "group_id", name: "fk_f081aa4489", on_delete: :cascade
  add_foreign_key "epics", "users", column: "assignee_id", name: "fk_dccd3f98fc", on_delete: :nullify
  add_foreign_key "epics", "users", column: "author_id", name: "fk_3654b61b03", on_delete: :cascade
  add_foreign_key "epics", "users", column: "closed_by_id", name: "fk_aa5798e761", on_delete: :nullify
  add_foreign_key "error_tracking_client_keys", "projects", on_delete: :cascade
  add_foreign_key "error_tracking_error_events", "error_tracking_errors", column: "error_id", on_delete: :cascade
  add_foreign_key "error_tracking_errors", "projects", on_delete: :cascade
  add_foreign_key "events", "namespaces", column: "group_id", name: "fk_61fbf6ca48", on_delete: :cascade
  add_foreign_key "events", "projects", on_delete: :cascade
  add_foreign_key "events", "users", column: "author_id", name: "fk_edfd187b6f", on_delete: :cascade
  add_foreign_key "evidences", "releases", on_delete: :cascade
  add_foreign_key "external_approval_rules", "projects", on_delete: :cascade
  add_foreign_key "external_approval_rules_protected_branches", "external_approval_rules", name: "fk_c9a037a926", on_delete: :cascade
  add_foreign_key "external_approval_rules_protected_branches", "protected_branches", name: "fk_ca2ffb55e6", on_delete: :cascade
  add_foreign_key "external_status_checks", "projects", on_delete: :cascade
  add_foreign_key "external_status_checks_protected_branches", "external_status_checks", name: "fk_cc0dcc36d1", on_delete: :cascade
  add_foreign_key "external_status_checks_protected_branches", "protected_branches", name: "fk_b7d788e813", on_delete: :cascade
  add_foreign_key "fork_network_members", "fork_networks", on_delete: :cascade
  add_foreign_key "fork_network_members", "projects", column: "forked_from_project_id", name: "fk_b01280dae4", on_delete: :nullify
  add_foreign_key "fork_network_members", "projects", on_delete: :cascade
  add_foreign_key "fork_networks", "projects", column: "root_project_id", name: "fk_e7b436b2b5", on_delete: :nullify
  add_foreign_key "geo_container_repository_updated_events", "container_repositories", name: "fk_212c89c706", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_cache_invalidation_events", column: "cache_invalidation_event_id", name: "fk_42c3b54bed", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_container_repository_updated_events", column: "container_repository_updated_event_id", name: "fk_6ada82d42a", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_events", name: "fk_geo_event_log_on_geo_event_id", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_hashed_storage_migrated_events", column: "hashed_storage_migrated_event_id", name: "fk_27548c6db3", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_repositories_changed_events", column: "repositories_changed_event_id", name: "fk_4a99ebfd60", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_repository_created_events", column: "repository_created_event_id", name: "fk_9b9afb1916", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_repository_deleted_events", column: "repository_deleted_event_id", name: "fk_c4b1c1f66e", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_repository_renamed_events", column: "repository_renamed_event_id", name: "fk_86c84214ec", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_repository_updated_events", column: "repository_updated_event_id", name: "fk_78a6492f68", on_delete: :cascade
  add_foreign_key "geo_event_log", "geo_reset_checksum_events", column: "reset_checksum_event_id", name: "fk_cff7185ad2", on_delete: :cascade
  add_foreign_key "geo_hashed_storage_attachments_events", "projects", on_delete: :cascade
  add_foreign_key "geo_hashed_storage_migrated_events", "projects", on_delete: :cascade
  add_foreign_key "geo_node_namespace_links", "geo_nodes", on_delete: :cascade
  add_foreign_key "geo_node_namespace_links", "namespaces", on_delete: :cascade
  add_foreign_key "geo_node_statuses", "geo_nodes", on_delete: :cascade
  add_foreign_key "geo_repositories_changed_events", "geo_nodes", on_delete: :cascade
  add_foreign_key "geo_repository_created_events", "projects", on_delete: :cascade
  add_foreign_key "geo_repository_renamed_events", "projects", on_delete: :cascade
  add_foreign_key "geo_repository_updated_events", "projects", on_delete: :cascade
  add_foreign_key "geo_reset_checksum_events", "projects", on_delete: :cascade
  add_foreign_key "ghost_user_migrations", "users", name: "fk_202e642a2f", on_delete: :cascade
  add_foreign_key "gitlab_subscriptions", "namespaces", name: "fk_e2595d00a1", on_delete: :cascade
  add_foreign_key "gitlab_subscriptions", "plans", column: "hosted_plan_id", name: "fk_bd0c4019c3", on_delete: :cascade
  add_foreign_key "gpg_key_subkeys", "gpg_keys", on_delete: :cascade
  add_foreign_key "gpg_keys", "users", on_delete: :cascade
  add_foreign_key "gpg_signatures", "gpg_key_subkeys", on_delete: :nullify
  add_foreign_key "gpg_signatures", "gpg_keys", on_delete: :nullify
  add_foreign_key "gpg_signatures", "projects", on_delete: :cascade
  add_foreign_key "grafana_integrations", "projects", on_delete: :cascade
  add_foreign_key "group_crm_settings", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_custom_attributes", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_deletion_schedules", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_deletion_schedules", "users", name: "fk_11e3ebfcdd", on_delete: :cascade
  add_foreign_key "group_deploy_keys", "users", on_delete: :restrict
  add_foreign_key "group_deploy_keys_groups", "group_deploy_keys", on_delete: :cascade
  add_foreign_key "group_deploy_keys_groups", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_deploy_tokens", "deploy_tokens", on_delete: :cascade
  add_foreign_key "group_deploy_tokens", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_features", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_group_links", "namespaces", column: "shared_group_id", on_delete: :cascade
  add_foreign_key "group_group_links", "namespaces", column: "shared_with_group_id", on_delete: :cascade
  add_foreign_key "group_import_states", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_import_states", "users", name: "fk_8053b3ebd6", on_delete: :cascade
  add_foreign_key "group_merge_request_approval_settings", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_repository_storage_moves", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_wiki_repositories", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "group_wiki_repositories", "shards", on_delete: :restrict
  add_foreign_key "identities", "saml_providers", name: "fk_aade90f0fc", on_delete: :cascade
  add_foreign_key "import_export_uploads", "namespaces", column: "group_id", name: "fk_83319d9721", on_delete: :cascade
  add_foreign_key "import_export_uploads", "projects", on_delete: :cascade
  add_foreign_key "import_failures", "namespaces", column: "group_id", name: "fk_24b824da43", on_delete: :cascade
  add_foreign_key "in_product_marketing_emails", "users", name: "fk_35c9101b63", on_delete: :cascade
  add_foreign_key "incident_management_escalation_policies", "projects", on_delete: :cascade
  add_foreign_key "incident_management_escalation_rules", "incident_management_escalation_policies", column: "policy_id", on_delete: :cascade
  add_foreign_key "incident_management_escalation_rules", "incident_management_oncall_schedules", column: "oncall_schedule_id", on_delete: :cascade
  add_foreign_key "incident_management_escalation_rules", "users", name: "fk_0314ee86eb", on_delete: :cascade
  add_foreign_key "incident_management_issuable_escalation_statuses", "incident_management_escalation_policies", column: "policy_id", on_delete: :nullify
  add_foreign_key "incident_management_issuable_escalation_statuses", "issues", on_delete: :cascade
  add_foreign_key "incident_management_oncall_participants", "incident_management_oncall_rotations", column: "oncall_rotation_id", on_delete: :cascade
  add_foreign_key "incident_management_oncall_participants", "users", on_delete: :cascade
  add_foreign_key "incident_management_oncall_rotations", "incident_management_oncall_schedules", column: "oncall_schedule_id", on_delete: :cascade
  add_foreign_key "incident_management_oncall_schedules", "projects", on_delete: :cascade
  add_foreign_key "incident_management_oncall_shifts", "incident_management_oncall_participants", column: "participant_id", on_delete: :cascade
  add_foreign_key "incident_management_oncall_shifts", "incident_management_oncall_rotations", column: "rotation_id", on_delete: :cascade
  add_foreign_key "incident_management_pending_alert_escalations", "alert_management_alerts", column: "alert_id", on_delete: :cascade
  add_foreign_key "incident_management_pending_alert_escalations", "incident_management_escalation_rules", column: "rule_id", on_delete: :cascade
  add_foreign_key "incident_management_pending_issue_escalations", "incident_management_escalation_rules", column: "rule_id", on_delete: :cascade
  add_foreign_key "incident_management_pending_issue_escalations", "issues", on_delete: :cascade
  add_foreign_key "incident_management_timeline_event_tag_links", "incident_management_timeline_event_tags", column: "timeline_event_tag_id", on_delete: :cascade
  add_foreign_key "incident_management_timeline_event_tag_links", "incident_management_timeline_events", column: "timeline_event_id", on_delete: :cascade
  add_foreign_key "incident_management_timeline_event_tags", "projects", on_delete: :cascade
  add_foreign_key "incident_management_timeline_events", "issues", name: "fk_17a5fafbd4", on_delete: :cascade
  add_foreign_key "incident_management_timeline_events", "notes", column: "promoted_from_note_id", name: "fk_d606a2a890", on_delete: :nullify
  add_foreign_key "incident_management_timeline_events", "projects", name: "fk_4432fc4d78", on_delete: :cascade
  add_foreign_key "incident_management_timeline_events", "users", column: "author_id", name: "fk_1800597ef9", on_delete: :nullify
  add_foreign_key "incident_management_timeline_events", "users", column: "updated_by_user_id", name: "fk_38a74279df", on_delete: :nullify
  add_foreign_key "index_statuses", "projects", name: "fk_74b2492545", on_delete: :cascade
  add_foreign_key "insights", "namespaces", on_delete: :cascade
  add_foreign_key "insights", "projects", on_delete: :cascade
  add_foreign_key "integrations", "integrations", column: "inherit_from_id", name: "fk_services_inherit_from_id", on_delete: :cascade
  add_foreign_key "integrations", "namespaces", column: "group_id", name: "fk_e8fe908a34", on_delete: :cascade
  add_foreign_key "integrations", "projects", name: "fk_71cce407f9", on_delete: :cascade
  add_foreign_key "internal_ids", "namespaces", name: "fk_162941d509", on_delete: :cascade
  add_foreign_key "internal_ids", "projects", on_delete: :cascade
  add_foreign_key "ip_restrictions", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "issuable_metric_images", "issues", on_delete: :cascade
  add_foreign_key "issuable_resource_links", "issues", on_delete: :cascade
  add_foreign_key "issuable_severities", "issues", on_delete: :cascade
  add_foreign_key "issuable_slas", "issues", on_delete: :cascade
  add_foreign_key "issue_assignees", "issues", name: "fk_b7d881734a", on_delete: :cascade
  add_foreign_key "issue_assignees", "users", name: "fk_5e0c8d9154", on_delete: :cascade
  add_foreign_key "issue_customer_relations_contacts", "customer_relations_contacts", column: "contact_id", name: "fk_7b92f835bb", on_delete: :cascade
  add_foreign_key "issue_customer_relations_contacts", "issues", name: "fk_0c0037f723", on_delete: :cascade
  add_foreign_key "issue_email_participants", "issues", on_delete: :cascade
  add_foreign_key "issue_emails", "issues", on_delete: :cascade
  add_foreign_key "issue_links", "issues", column: "source_id", name: "fk_c900194ff2", on_delete: :cascade
  add_foreign_key "issue_links", "issues", column: "target_id", name: "fk_e71bb44f1f", on_delete: :cascade
  add_foreign_key "issue_metrics", "issues", on_delete: :cascade
  add_foreign_key "issue_search_data", "issues", name: "issue_search_data_issue_id_fkey", on_delete: :cascade
  add_foreign_key "issue_search_data", "projects", name: "issue_search_data_project_id_fkey", on_delete: :cascade
  add_foreign_key "issue_tracker_data", "integrations", name: "fk_33921c0ee1", on_delete: :cascade
  add_foreign_key "issue_user_mentions", "issues", on_delete: :cascade
  add_foreign_key "issue_user_mentions", "notes", on_delete: :cascade
  add_foreign_key "issues", "epics", column: "promoted_to_epic_id", name: "fk_df75a7c8b8", on_delete: :nullify
  add_foreign_key "issues", "issues", column: "duplicated_to_id", name: "fk_9c4516d665", on_delete: :nullify
  add_foreign_key "issues", "issues", column: "moved_to_id", name: "fk_a194299be1", on_delete: :nullify
  add_foreign_key "issues", "milestones", name: "fk_96b1dd429c", on_delete: :nullify
  add_foreign_key "issues", "namespaces", name: "fk_c78fbacd64", on_delete: :cascade
  add_foreign_key "issues", "projects", name: "fk_899c8f3231", on_delete: :cascade
  add_foreign_key "issues", "sprints", name: "fk_3b8c72ea56", on_delete: :nullify
  add_foreign_key "issues", "users", column: "author_id", name: "fk_05f1e72feb", on_delete: :nullify
  add_foreign_key "issues", "users", column: "closed_by_id", name: "fk_c63cbf6c25", on_delete: :nullify
  add_foreign_key "issues", "users", column: "updated_by_id", name: "fk_ffed080f01", on_delete: :nullify
  add_foreign_key "issues", "work_item_types", name: "fk_b37be69be6"
  add_foreign_key "issues_prometheus_alert_events", "issues", on_delete: :cascade
  add_foreign_key "issues_prometheus_alert_events", "prometheus_alert_events", on_delete: :cascade
  add_foreign_key "issues_self_managed_prometheus_alert_events", "issues", on_delete: :cascade
  add_foreign_key "issues_self_managed_prometheus_alert_events", "self_managed_prometheus_alert_events", on_delete: :cascade
  add_foreign_key "iterations_cadences", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "jira_connect_subscriptions", "jira_connect_installations", on_delete: :cascade
  add_foreign_key "jira_connect_subscriptions", "namespaces", on_delete: :cascade
  add_foreign_key "jira_imports", "labels", on_delete: :nullify
  add_foreign_key "jira_imports", "projects", on_delete: :cascade
  add_foreign_key "jira_imports", "users", on_delete: :nullify
  add_foreign_key "jira_tracker_data", "integrations", name: "fk_c98abcd54c", on_delete: :cascade
  add_foreign_key "label_links", "labels", name: "fk_d97dd08678", on_delete: :cascade
  add_foreign_key "label_priorities", "labels", on_delete: :cascade
  add_foreign_key "label_priorities", "projects", on_delete: :cascade
  add_foreign_key "labels", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "labels", "projects", name: "fk_7de4989a69", on_delete: :cascade
  add_foreign_key "lfs_file_locks", "projects", on_delete: :cascade
  add_foreign_key "lfs_file_locks", "users", on_delete: :cascade
  add_foreign_key "lfs_object_states", "lfs_objects", on_delete: :cascade
  add_foreign_key "lfs_objects_projects", "lfs_objects", name: "fk_a56e02279c", on_delete: :restrict
  add_foreign_key "lfs_objects_projects", "projects", name: "fk_2eb33f7a78", on_delete: :cascade
  add_foreign_key "list_user_preferences", "lists", on_delete: :cascade
  add_foreign_key "list_user_preferences", "users", on_delete: :cascade
  add_foreign_key "lists", "boards", name: "fk_0d3f677137", on_delete: :cascade
  add_foreign_key "lists", "labels", name: "fk_7a5553d60f", on_delete: :cascade
  add_foreign_key "lists", "milestones", on_delete: :cascade
  add_foreign_key "lists", "sprints", column: "iteration_id", name: "fk_30f2a831f4", on_delete: :cascade
  add_foreign_key "lists", "users", name: "fk_d6cf4279f7", on_delete: :cascade
  add_foreign_key "member_roles", "namespaces", on_delete: :cascade
  add_foreign_key "member_tasks", "members", name: "fk_12816d4bbb", on_delete: :cascade
  add_foreign_key "member_tasks", "projects", name: "fk_ab636303dd", on_delete: :cascade
  add_foreign_key "members", "member_roles", name: "fk_5e12d50db3", on_delete: :cascade
  add_foreign_key "members", "namespaces", column: "member_namespace_id", name: "fk_2f85abf8f1", on_delete: :cascade
  add_foreign_key "members", "users", name: "fk_2e88fb7ce9", on_delete: :cascade
  add_foreign_key "merge_request_assignees", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_request_assignees", "users", on_delete: :cascade
  add_foreign_key "merge_request_blocks", "merge_requests", column: "blocked_merge_request_id", on_delete: :cascade
  add_foreign_key "merge_request_blocks", "merge_requests", column: "blocking_merge_request_id", on_delete: :cascade
  add_foreign_key "merge_request_cleanup_schedules", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_request_context_commit_diff_files", "merge_request_context_commits", on_delete: :cascade
  add_foreign_key "merge_request_context_commits", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_request_diff_commits", "merge_request_diffs", on_delete: :cascade
  add_foreign_key "merge_request_diff_details", "merge_request_diffs", on_delete: :cascade
  add_foreign_key "merge_request_diff_files", "merge_request_diffs", on_delete: :cascade
  add_foreign_key "merge_request_diffs", "merge_requests", name: "fk_8483f3258f", on_delete: :cascade
  add_foreign_key "merge_request_metrics", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_request_metrics", "projects", column: "target_project_id", name: "fk_56067dcb44", on_delete: :cascade
  add_foreign_key "merge_request_metrics", "users", column: "latest_closed_by_id", name: "fk_ae440388cc", on_delete: :nullify
  add_foreign_key "merge_request_metrics", "users", column: "merged_by_id", name: "fk_7f28d925f3", on_delete: :nullify
  add_foreign_key "merge_request_predictions", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_request_reviewers", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_request_reviewers", "users", on_delete: :cascade
  add_foreign_key "merge_request_user_mentions", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_request_user_mentions", "notes", on_delete: :cascade
  add_foreign_key "merge_requests", "merge_request_diffs", column: "latest_merge_request_diff_id", name: "fk_06067f5644", on_delete: :nullify
  add_foreign_key "merge_requests", "milestones", name: "fk_6a5165a692", on_delete: :nullify
  add_foreign_key "merge_requests", "projects", column: "source_project_id", name: "fk_source_project", on_delete: :nullify
  add_foreign_key "merge_requests", "projects", column: "target_project_id", name: "fk_a6963e8447", on_delete: :cascade
  add_foreign_key "merge_requests", "sprints", name: "fk_7e85395a64", on_delete: :nullify
  add_foreign_key "merge_requests", "users", column: "assignee_id", name: "fk_6149611a04", on_delete: :nullify
  add_foreign_key "merge_requests", "users", column: "author_id", name: "fk_e719a85f8a", on_delete: :nullify
  add_foreign_key "merge_requests", "users", column: "merge_user_id", name: "fk_ad525e1f87", on_delete: :nullify
  add_foreign_key "merge_requests", "users", column: "updated_by_id", name: "fk_641731faff", on_delete: :nullify
  add_foreign_key "merge_requests_closing_issues", "issues", on_delete: :cascade
  add_foreign_key "merge_requests_closing_issues", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_requests_compliance_violations", "merge_requests", name: "fk_290ec1ab02", on_delete: :cascade
  add_foreign_key "merge_requests_compliance_violations", "users", column: "violating_user_id", name: "fk_ec881c1c6f", on_delete: :cascade
  add_foreign_key "merge_trains", "merge_requests", on_delete: :cascade
  add_foreign_key "merge_trains", "projects", column: "target_project_id", on_delete: :cascade
  add_foreign_key "merge_trains", "users", on_delete: :cascade
  add_foreign_key "metrics_dashboard_annotations", "clusters", on_delete: :cascade
  add_foreign_key "metrics_dashboard_annotations", "environments", on_delete: :cascade
  add_foreign_key "metrics_users_starred_dashboards", "projects", name: "fk_d76a2b9a8c", on_delete: :cascade
  add_foreign_key "metrics_users_starred_dashboards", "users", name: "fk_bd6ae32fac", on_delete: :cascade
  add_foreign_key "milestone_releases", "milestones", on_delete: :cascade
  add_foreign_key "milestone_releases", "releases", on_delete: :cascade
  add_foreign_key "milestones", "namespaces", column: "group_id", name: "fk_95650a40d4", on_delete: :cascade
  add_foreign_key "milestones", "projects", name: "fk_9bd0a0c791", on_delete: :cascade
  add_foreign_key "ml_candidate_metadata", "ml_candidates", column: "candidate_id", on_delete: :cascade
  add_foreign_key "ml_candidate_metrics", "ml_candidates", column: "candidate_id"
  add_foreign_key "ml_candidate_params", "ml_candidates", column: "candidate_id"
  add_foreign_key "ml_candidates", "ml_experiments", column: "experiment_id", name: "fk_56d6ed4d3d", on_delete: :cascade
  add_foreign_key "ml_candidates", "users"
  add_foreign_key "ml_experiment_metadata", "ml_experiments", column: "experiment_id", on_delete: :cascade
  add_foreign_key "ml_experiments", "projects", name: "fk_ad89c59858", on_delete: :cascade
  add_foreign_key "ml_experiments", "users"
  add_foreign_key "namespace_admin_notes", "namespaces", on_delete: :cascade
  add_foreign_key "namespace_aggregation_schedules", "namespaces", on_delete: :cascade
  add_foreign_key "namespace_bans", "namespaces", name: "fk_bcc024eef2", on_delete: :cascade
  add_foreign_key "namespace_bans", "users", name: "fk_4275fbb1d7", on_delete: :cascade
  add_foreign_key "namespace_ci_cd_settings", "namespaces", on_delete: :cascade
  add_foreign_key "namespace_commit_emails", "emails", name: "fk_b8d89d555e", on_delete: :cascade
  add_foreign_key "namespace_commit_emails", "namespaces", name: "fk_4d6ba63ba5", on_delete: :cascade
  add_foreign_key "namespace_commit_emails", "users", on_delete: :cascade
  add_foreign_key "namespace_details", "namespaces", on_delete: :cascade
  add_foreign_key "namespace_limits", "namespaces", on_delete: :cascade
  add_foreign_key "namespace_package_settings", "namespaces", on_delete: :cascade
  add_foreign_key "namespace_root_storage_statistics", "namespaces", on_delete: :cascade
  add_foreign_key "namespace_settings", "compliance_management_frameworks", column: "default_compliance_framework_id", name: "fk_20cf0eb2f9", on_delete: :nullify
  add_foreign_key "namespace_settings", "namespaces", on_delete: :cascade
  add_foreign_key "namespace_statistics", "namespaces", on_delete: :cascade
  add_foreign_key "namespaces", "namespaces", column: "custom_project_templates_group_id", name: "fk_e7a0b20a6b", on_delete: :nullify
  add_foreign_key "namespaces", "projects", column: "file_template_project_id", name: "fk_319256d87a", on_delete: :nullify
  add_foreign_key "namespaces", "push_rules", name: "fk_3448c97865", on_delete: :nullify
  add_foreign_key "namespaces_sync_events", "namespaces", on_delete: :cascade
  add_foreign_key "note_diff_files", "notes", column: "diff_note_id", on_delete: :cascade
  add_foreign_key "notes", "projects", name: "fk_99e097b079", on_delete: :cascade
  add_foreign_key "notes", "reviews", name: "fk_2e82291620", on_delete: :nullify
  add_foreign_key "notification_settings", "users", name: "fk_0c95e91db7", on_delete: :cascade
  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id", name: "fk_77114b3b09", on_delete: :cascade
  add_foreign_key "onboarding_progresses", "namespaces", on_delete: :cascade
  add_foreign_key "operations_feature_flag_scopes", "operations_feature_flags", column: "feature_flag_id", on_delete: :cascade
  add_foreign_key "operations_feature_flags", "projects", on_delete: :cascade
  add_foreign_key "operations_feature_flags_clients", "projects", on_delete: :cascade
  add_foreign_key "operations_feature_flags_issues", "issues", on_delete: :cascade
  add_foreign_key "operations_feature_flags_issues", "operations_feature_flags", column: "feature_flag_id", on_delete: :cascade
  add_foreign_key "operations_scopes", "operations_strategies", column: "strategy_id", on_delete: :cascade
  add_foreign_key "operations_strategies", "operations_feature_flags", column: "feature_flag_id", on_delete: :cascade
  add_foreign_key "operations_strategies_user_lists", "operations_strategies", column: "strategy_id", on_delete: :cascade
  add_foreign_key "operations_strategies_user_lists", "operations_user_lists", column: "user_list_id", on_delete: :cascade
  add_foreign_key "operations_user_lists", "projects", on_delete: :cascade
  add_foreign_key "p_ci_builds_metadata", "ci_builds", column: "build_id", name: "fk_e20479742e", on_delete: :cascade
  add_foreign_key "packages_build_infos", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_cleanup_policies", "projects", on_delete: :cascade
  add_foreign_key "packages_composer_cache_files", "namespaces", on_delete: :nullify
  add_foreign_key "packages_composer_metadata", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_conan_file_metadata", "packages_package_files", column: "package_file_id", on_delete: :cascade
  add_foreign_key "packages_conan_metadata", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_debian_file_metadata", "packages_package_files", column: "package_file_id", on_delete: :cascade
  add_foreign_key "packages_debian_group_architectures", "packages_debian_group_distributions", column: "distribution_id", on_delete: :cascade
  add_foreign_key "packages_debian_group_component_files", "packages_debian_group_architectures", column: "architecture_id", on_delete: :restrict
  add_foreign_key "packages_debian_group_component_files", "packages_debian_group_components", column: "component_id", on_delete: :restrict
  add_foreign_key "packages_debian_group_components", "packages_debian_group_distributions", column: "distribution_id", on_delete: :cascade
  add_foreign_key "packages_debian_group_distribution_keys", "packages_debian_group_distributions", column: "distribution_id", on_delete: :cascade
  add_foreign_key "packages_debian_group_distributions", "namespaces", column: "group_id", on_delete: :restrict
  add_foreign_key "packages_debian_group_distributions", "users", column: "creator_id", on_delete: :nullify
  add_foreign_key "packages_debian_project_architectures", "packages_debian_project_distributions", column: "distribution_id", on_delete: :cascade
  add_foreign_key "packages_debian_project_component_files", "packages_debian_project_architectures", column: "architecture_id", on_delete: :restrict
  add_foreign_key "packages_debian_project_component_files", "packages_debian_project_components", column: "component_id", on_delete: :restrict
  add_foreign_key "packages_debian_project_components", "packages_debian_project_distributions", column: "distribution_id", on_delete: :cascade
  add_foreign_key "packages_debian_project_distribution_keys", "packages_debian_project_distributions", column: "distribution_id", on_delete: :cascade
  add_foreign_key "packages_debian_project_distributions", "projects", on_delete: :restrict
  add_foreign_key "packages_debian_project_distributions", "users", column: "creator_id", on_delete: :nullify
  add_foreign_key "packages_debian_publications", "packages_debian_project_distributions", column: "distribution_id", on_delete: :cascade
  add_foreign_key "packages_debian_publications", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_dependency_links", "packages_dependencies", column: "dependency_id", on_delete: :cascade
  add_foreign_key "packages_dependency_links", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_events", "packages_packages", column: "package_id", on_delete: :nullify
  add_foreign_key "packages_helm_file_metadata", "packages_package_files", column: "package_file_id", on_delete: :cascade
  add_foreign_key "packages_maven_metadata", "packages_packages", column: "package_id", name: "fk_be88aed360", on_delete: :cascade
  add_foreign_key "packages_npm_metadata", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_nuget_dependency_link_metadata", "packages_dependency_links", column: "dependency_link_id", on_delete: :cascade
  add_foreign_key "packages_nuget_metadata", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_package_file_build_infos", "packages_package_files", column: "package_file_id", on_delete: :cascade
  add_foreign_key "packages_package_files", "packages_packages", column: "package_id", name: "fk_86f0f182f8", on_delete: :cascade
  add_foreign_key "packages_packages", "projects", on_delete: :cascade
  add_foreign_key "packages_packages", "users", column: "creator_id", name: "fk_c188f0dba4", on_delete: :nullify
  add_foreign_key "packages_pypi_metadata", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_rpm_metadata", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_rpm_repository_files", "projects", on_delete: :cascade
  add_foreign_key "packages_rubygems_metadata", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "packages_tags", "packages_packages", column: "package_id", on_delete: :cascade
  add_foreign_key "pages_deployment_states", "pages_deployments", on_delete: :cascade
  add_foreign_key "pages_deployments", "projects", on_delete: :cascade
  add_foreign_key "pages_domain_acme_orders", "pages_domains", on_delete: :cascade
  add_foreign_key "pages_domains", "projects", name: "fk_ea2f6dfc6f", on_delete: :cascade
  add_foreign_key "path_locks", "projects", name: "fk_5265c98f24", on_delete: :cascade
  add_foreign_key "path_locks", "users", name: "fk_path_locks_user_id", on_delete: :cascade
  add_foreign_key "personal_access_tokens", "users", name: "fk_personal_access_tokens_user_id", on_delete: :cascade
  add_foreign_key "plan_limits", "plans", on_delete: :cascade
  add_foreign_key "pm_package_version_licenses", "pm_licenses", on_delete: :cascade
  add_foreign_key "pm_package_version_licenses", "pm_package_versions", on_delete: :cascade
  add_foreign_key "pm_package_versions", "pm_packages", on_delete: :cascade
  add_foreign_key "pool_repositories", "projects", column: "source_project_id", on_delete: :nullify
  add_foreign_key "pool_repositories", "shards", on_delete: :restrict
  add_foreign_key "product_analytics_events_experimental", "projects", name: "product_analytics_events_experimental_project_id_fkey", on_delete: :cascade
  add_foreign_key "project_access_tokens", "personal_access_tokens", name: "fk_5f7e8450e1", on_delete: :cascade
  add_foreign_key "project_access_tokens", "projects", name: "fk_b27801bfbf", on_delete: :cascade
  add_foreign_key "project_alerting_settings", "projects", on_delete: :cascade
  add_foreign_key "project_aliases", "projects", on_delete: :cascade
  add_foreign_key "project_authorizations", "projects", on_delete: :cascade
  add_foreign_key "project_authorizations", "users", on_delete: :cascade
  add_foreign_key "project_auto_devops", "projects", on_delete: :cascade
  add_foreign_key "project_build_artifacts_size_refreshes", "projects", on_delete: :cascade
  add_foreign_key "project_ci_cd_settings", "projects", name: "fk_24c15d2f2e", on_delete: :cascade
  add_foreign_key "project_ci_feature_usages", "projects", on_delete: :cascade
  add_foreign_key "project_compliance_framework_settings", "compliance_management_frameworks", column: "framework_id", name: "fk_be413374a9", on_delete: :cascade
  add_foreign_key "project_compliance_framework_settings", "projects", on_delete: :cascade
  add_foreign_key "project_custom_attributes", "projects", on_delete: :cascade
  add_foreign_key "project_daily_statistics", "projects", on_delete: :cascade
  add_foreign_key "project_deploy_tokens", "deploy_tokens", on_delete: :cascade
  add_foreign_key "project_deploy_tokens", "projects", on_delete: :cascade
  add_foreign_key "project_error_tracking_settings", "projects", on_delete: :cascade
  add_foreign_key "project_export_jobs", "projects", on_delete: :cascade
  add_foreign_key "project_feature_usages", "projects", on_delete: :cascade
  add_foreign_key "project_features", "projects", name: "fk_18513d9b92", on_delete: :cascade
  add_foreign_key "project_group_links", "projects", name: "fk_daa8cee94c", on_delete: :cascade
  add_foreign_key "project_import_data", "projects", name: "fk_ffb9ee3a10", on_delete: :cascade
  add_foreign_key "project_incident_management_settings", "projects", on_delete: :cascade
  add_foreign_key "project_metrics_settings", "projects", on_delete: :cascade
  add_foreign_key "project_mirror_data", "projects", name: "fk_d1aad367d7", on_delete: :cascade
  add_foreign_key "project_pages_metadata", "pages_deployments", name: "fk_0fd5b22688", on_delete: :nullify
  add_foreign_key "project_pages_metadata", "projects", on_delete: :cascade
  add_foreign_key "project_relation_export_uploads", "project_relation_exports", on_delete: :cascade
  add_foreign_key "project_relation_exports", "project_export_jobs", on_delete: :cascade
  add_foreign_key "project_repositories", "projects", on_delete: :cascade
  add_foreign_key "project_repositories", "shards", on_delete: :restrict
  add_foreign_key "project_repository_states", "projects", on_delete: :cascade
  add_foreign_key "project_repository_storage_moves", "projects", on_delete: :cascade
  add_foreign_key "project_security_settings", "projects", on_delete: :cascade
  add_foreign_key "project_settings", "projects", on_delete: :cascade
  add_foreign_key "project_settings", "push_rules", name: "fk_project_settings_push_rule_id", on_delete: :nullify
  add_foreign_key "project_statistics", "projects", on_delete: :cascade
  add_foreign_key "project_topics", "projects", name: "fk_db13576296", on_delete: :cascade
  add_foreign_key "project_topics", "topics", name: "fk_34af9ab07a", on_delete: :cascade
  add_foreign_key "project_wiki_repositories", "projects", on_delete: :cascade
  add_foreign_key "project_wiki_repository_states", "project_wiki_repositories", name: "fk_6951681c70", on_delete: :cascade
  add_foreign_key "project_wiki_repository_states", "projects", on_delete: :cascade
  add_foreign_key "projects", "namespaces", column: "project_namespace_id", name: "fk_6ca23af0a3", on_delete: :cascade
  add_foreign_key "projects", "namespaces", name: "fk_projects_namespace_id", on_delete: :restrict
  add_foreign_key "projects", "pool_repositories", name: "fk_6e5c14658a", on_delete: :nullify
  add_foreign_key "projects", "users", column: "marked_for_deletion_by_user_id", name: "fk_25d8780d11", on_delete: :nullify
  add_foreign_key "projects_sync_events", "projects", on_delete: :cascade
  add_foreign_key "prometheus_alert_events", "projects", on_delete: :cascade
  add_foreign_key "prometheus_alert_events", "prometheus_alerts", on_delete: :cascade
  add_foreign_key "prometheus_alerts", "environments", on_delete: :cascade
  add_foreign_key "prometheus_alerts", "projects", on_delete: :cascade
  add_foreign_key "prometheus_alerts", "prometheus_metrics", on_delete: :cascade
  add_foreign_key "prometheus_metrics", "projects", on_delete: :cascade
  add_foreign_key "protected_branch_merge_access_levels", "namespaces", column: "group_id", name: "fk_98f3d044fe", on_delete: :cascade
  add_foreign_key "protected_branch_merge_access_levels", "protected_branches", name: "fk_8a3072ccb3", on_delete: :cascade
  add_foreign_key "protected_branch_merge_access_levels", "users", name: "fk_protected_branch_merge_access_levels_user_id", on_delete: :cascade
  add_foreign_key "protected_branch_push_access_levels", "keys", column: "deploy_key_id", name: "fk_15d2a7a4ae", on_delete: :cascade
  add_foreign_key "protected_branch_push_access_levels", "namespaces", column: "group_id", name: "fk_7111b68cdb", on_delete: :cascade
  add_foreign_key "protected_branch_push_access_levels", "protected_branches", name: "fk_9ffc86a3d9", on_delete: :cascade
  add_foreign_key "protected_branch_push_access_levels", "users", name: "fk_protected_branch_push_access_levels_user_id", on_delete: :cascade
  add_foreign_key "protected_branch_unprotect_access_levels", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "protected_branch_unprotect_access_levels", "protected_branches", on_delete: :cascade
  add_foreign_key "protected_branch_unprotect_access_levels", "users", on_delete: :cascade
  add_foreign_key "protected_branches", "namespaces", name: "fk_de9216e774", on_delete: :cascade
  add_foreign_key "protected_branches", "projects", name: "fk_7a9c6d93e7", on_delete: :cascade
  add_foreign_key "protected_environment_approval_rules", "namespaces", column: "group_id", name: "fk_405568b491", on_delete: :cascade
  add_foreign_key "protected_environment_approval_rules", "protected_environments", on_delete: :cascade
  add_foreign_key "protected_environment_approval_rules", "users", name: "fk_6ee8249821", on_delete: :cascade
  add_foreign_key "protected_environment_deploy_access_levels", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "protected_environment_deploy_access_levels", "protected_environments", on_delete: :cascade
  add_foreign_key "protected_environment_deploy_access_levels", "users", on_delete: :cascade
  add_foreign_key "protected_environments", "namespaces", column: "group_id", name: "fk_9e112565b7", on_delete: :cascade
  add_foreign_key "protected_environments", "projects", on_delete: :cascade
  add_foreign_key "protected_tag_create_access_levels", "namespaces", column: "group_id", name: "fk_b4eb82fe3c", on_delete: :cascade
  add_foreign_key "protected_tag_create_access_levels", "protected_tags", name: "fk_f7dfda8c51", on_delete: :cascade
  add_foreign_key "protected_tag_create_access_levels", "users", name: "fk_protected_tag_create_access_levels_user_id", on_delete: :cascade
  add_foreign_key "protected_tags", "projects", name: "fk_8e4af87648", on_delete: :cascade
  add_foreign_key "push_event_payloads", "events", name: "fk_36c74129da", on_delete: :cascade
  add_foreign_key "push_rules", "projects", name: "fk_83b29894de", on_delete: :cascade
  add_foreign_key "related_epic_links", "epics", column: "source_id", on_delete: :cascade
  add_foreign_key "related_epic_links", "epics", column: "target_id", on_delete: :cascade
  add_foreign_key "release_links", "releases", on_delete: :cascade
  add_foreign_key "releases", "projects", name: "fk_47fe2a0596", on_delete: :cascade
  add_foreign_key "releases", "users", column: "author_id", name: "fk_8e4456f90f", on_delete: :nullify
  add_foreign_key "remote_mirrors", "projects", name: "fk_43a9aa4ca8", on_delete: :cascade
  add_foreign_key "repository_languages", "projects", on_delete: :cascade
  add_foreign_key "required_code_owners_sections", "protected_branches", on_delete: :cascade
  add_foreign_key "requirements", "issues", name: "fk_85044baef0", on_delete: :cascade
  add_foreign_key "requirements", "projects", on_delete: :cascade
  add_foreign_key "requirements", "users", column: "author_id", on_delete: :nullify
  add_foreign_key "requirements_management_test_reports", "issues", name: "fk_88f30752fc", on_delete: :cascade
  add_foreign_key "requirements_management_test_reports", "users", column: "author_id", on_delete: :nullify
  add_foreign_key "resource_iteration_events", "issues", on_delete: :cascade
  add_foreign_key "resource_iteration_events", "merge_requests", on_delete: :cascade
  add_foreign_key "resource_iteration_events", "sprints", column: "iteration_id", on_delete: :cascade
  add_foreign_key "resource_iteration_events", "users", on_delete: :nullify
  add_foreign_key "resource_label_events", "epics", on_delete: :cascade
  add_foreign_key "resource_label_events", "issues", on_delete: :cascade
  add_foreign_key "resource_label_events", "labels", on_delete: :nullify
  add_foreign_key "resource_label_events", "merge_requests", on_delete: :cascade
  add_foreign_key "resource_label_events", "users", on_delete: :nullify
  add_foreign_key "resource_milestone_events", "issues", on_delete: :cascade
  add_foreign_key "resource_milestone_events", "merge_requests", on_delete: :cascade
  add_foreign_key "resource_milestone_events", "milestones", on_delete: :cascade
  add_foreign_key "resource_milestone_events", "users", on_delete: :nullify
  add_foreign_key "resource_state_events", "epics", on_delete: :cascade
  add_foreign_key "resource_state_events", "issues", on_delete: :cascade
  add_foreign_key "resource_state_events", "merge_requests", column: "source_merge_request_id", on_delete: :nullify
  add_foreign_key "resource_state_events", "merge_requests", on_delete: :cascade
  add_foreign_key "resource_state_events", "users", on_delete: :nullify
  add_foreign_key "resource_weight_events", "issues", on_delete: :cascade
  add_foreign_key "resource_weight_events", "users", on_delete: :nullify
  add_foreign_key "reviews", "merge_requests", on_delete: :cascade
  add_foreign_key "reviews", "projects", on_delete: :cascade
  add_foreign_key "reviews", "users", column: "author_id", on_delete: :nullify
  add_foreign_key "routes", "namespaces", name: "fk_bb2e5b8968", on_delete: :cascade
  add_foreign_key "saml_group_links", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "saml_providers", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "saved_replies", "users", on_delete: :cascade
  add_foreign_key "sbom_component_versions", "sbom_components", column: "component_id", on_delete: :cascade
  add_foreign_key "sbom_occurrences", "projects", name: "fk_157506c0e2", on_delete: :cascade
  add_foreign_key "sbom_occurrences", "sbom_component_versions", column: "component_version_id", name: "fk_4b88e5b255", on_delete: :cascade
  add_foreign_key "sbom_occurrences", "sbom_components", column: "component_id", name: "fk_d857c6edc1", on_delete: :cascade
  add_foreign_key "sbom_occurrences", "sbom_sources", column: "source_id", name: "fk_c2a5562923", on_delete: :cascade
  add_foreign_key "sbom_vulnerable_component_versions", "sbom_component_versions", name: "fk_8a2a1197f9", on_delete: :cascade
  add_foreign_key "sbom_vulnerable_component_versions", "vulnerability_advisories", name: "fk_d720a1959a", on_delete: :cascade
  add_foreign_key "scim_identities", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "scim_identities", "users", on_delete: :cascade
  add_foreign_key "scim_oauth_access_tokens", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "security_findings", "security_scans", column: "scan_id", on_delete: :cascade
  add_foreign_key "security_findings", "vulnerability_scanners", column: "scanner_id", on_delete: :cascade
  add_foreign_key "security_orchestration_policy_configurations", "namespaces", name: "fk_a50430b375", on_delete: :cascade
  add_foreign_key "security_orchestration_policy_configurations", "projects", column: "security_policy_management_project_id", name: "fk_security_policy_configurations_management_project_id", on_delete: :cascade
  add_foreign_key "security_orchestration_policy_configurations", "projects", on_delete: :cascade
  add_foreign_key "security_orchestration_policy_rule_schedules", "security_orchestration_policy_configurations", on_delete: :cascade
  add_foreign_key "security_orchestration_policy_rule_schedules", "users", on_delete: :cascade
  add_foreign_key "security_scans", "projects", name: "fk_dbc89265b9", on_delete: :cascade
  add_foreign_key "security_trainings", "projects", on_delete: :cascade
  add_foreign_key "security_trainings", "security_training_providers", column: "provider_id", on_delete: :cascade
  add_foreign_key "self_managed_prometheus_alert_events", "environments", on_delete: :cascade
  add_foreign_key "self_managed_prometheus_alert_events", "projects", on_delete: :cascade
  add_foreign_key "sentry_issues", "issues", on_delete: :cascade
  add_foreign_key "serverless_domain_cluster", "clusters_applications_knative", on_delete: :cascade
  add_foreign_key "serverless_domain_cluster", "pages_domains", on_delete: :cascade
  add_foreign_key "serverless_domain_cluster", "users", column: "creator_id", on_delete: :nullify
  add_foreign_key "service_desk_settings", "projects", column: "file_template_project_id", name: "fk_03afb71f06", on_delete: :nullify
  add_foreign_key "service_desk_settings", "projects", on_delete: :cascade
  add_foreign_key "slack_integrations", "integrations", name: "fk_cbe270434e", on_delete: :cascade
  add_foreign_key "smartcard_identities", "users", on_delete: :cascade
  add_foreign_key "snippet_repositories", "shards", on_delete: :restrict
  add_foreign_key "snippet_repositories", "snippets", on_delete: :cascade
  add_foreign_key "snippet_repository_storage_moves", "snippets", on_delete: :cascade
  add_foreign_key "snippet_statistics", "snippets", on_delete: :cascade
  add_foreign_key "snippet_user_mentions", "notes", on_delete: :cascade
  add_foreign_key "snippet_user_mentions", "snippets", on_delete: :cascade
  add_foreign_key "snippets", "projects", name: "fk_be41fd4bb7", on_delete: :cascade
  add_foreign_key "software_license_policies", "projects", on_delete: :cascade
  add_foreign_key "software_license_policies", "software_licenses", on_delete: :cascade
  add_foreign_key "sprints", "iterations_cadences", name: "fk_365d1db505", on_delete: :cascade
  add_foreign_key "sprints", "namespaces", column: "group_id", name: "fk_80aa8a1f95", on_delete: :cascade
  add_foreign_key "ssh_signatures", "keys", name: "fk_f177ea6aa5", on_delete: :cascade
  add_foreign_key "ssh_signatures", "projects", name: "fk_7d2f93996c", on_delete: :cascade
  add_foreign_key "status_check_responses", "external_status_checks", name: "fk_55bd2abc83", on_delete: :cascade
  add_foreign_key "status_check_responses", "merge_requests", name: "fk_f3953d86c6", on_delete: :cascade
  add_foreign_key "status_page_published_incidents", "issues", on_delete: :cascade
  add_foreign_key "status_page_settings", "projects", on_delete: :cascade
  add_foreign_key "subscriptions", "projects", on_delete: :cascade
  add_foreign_key "suggestions", "notes", on_delete: :cascade
  add_foreign_key "system_note_metadata", "description_versions", name: "fk_fbd87415c9", on_delete: :nullify
  add_foreign_key "system_note_metadata", "notes", name: "fk_d83a918cb1", on_delete: :cascade
  add_foreign_key "term_agreements", "application_setting_terms", column: "term_id"
  add_foreign_key "term_agreements", "users", on_delete: :cascade
  add_foreign_key "terraform_state_versions", "terraform_states", on_delete: :cascade
  add_foreign_key "terraform_state_versions", "users", column: "created_by_user_id", name: "fk_6e81384d7f", on_delete: :nullify
  add_foreign_key "terraform_states", "projects", on_delete: :cascade
  add_foreign_key "terraform_states", "users", column: "locked_by_user_id", name: "fk_558901b030", on_delete: :nullify
  add_foreign_key "timelog_categories", "namespaces", on_delete: :cascade
  add_foreign_key "timelogs", "issues", name: "fk_timelogs_issues_issue_id", on_delete: :cascade
  add_foreign_key "timelogs", "merge_requests", name: "fk_timelogs_merge_requests_merge_request_id", on_delete: :cascade
  add_foreign_key "timelogs", "notes", name: "fk_timelogs_note_id", on_delete: :nullify
  add_foreign_key "timelogs", "projects", name: "fk_c49c83dd77", on_delete: :cascade
  add_foreign_key "todos", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "todos", "notes", name: "fk_91d1f47b13", on_delete: :cascade
  add_foreign_key "todos", "projects", name: "fk_45054f9c45", on_delete: :cascade
  add_foreign_key "todos", "users", column: "author_id", name: "fk_ccf0373936", on_delete: :cascade
  add_foreign_key "todos", "users", name: "fk_d94154aa95", on_delete: :cascade
  add_foreign_key "trending_projects", "projects", on_delete: :cascade
  add_foreign_key "u2f_registrations", "users", name: "fk_u2f_registrations_user_id", on_delete: :cascade
  add_foreign_key "upcoming_reconciliations", "namespaces", on_delete: :cascade
  add_foreign_key "upload_states", "uploads", on_delete: :cascade
  add_foreign_key "user_callouts", "users", on_delete: :cascade
  add_foreign_key "user_canonical_emails", "users", on_delete: :cascade
  add_foreign_key "user_credit_card_validations", "users", on_delete: :cascade
  add_foreign_key "user_custom_attributes", "users", on_delete: :cascade
  add_foreign_key "user_details", "namespaces", column: "provisioned_by_group_id", name: "fk_190e4fcc88", on_delete: :nullify
  add_foreign_key "user_details", "users", on_delete: :cascade
  add_foreign_key "user_follow_users", "users", column: "followee_id", name: "user_follow_users_followee_id_fkey", on_delete: :cascade
  add_foreign_key "user_follow_users", "users", column: "follower_id", name: "user_follow_users_follower_id_fkey", on_delete: :cascade
  add_foreign_key "user_group_callouts", "namespaces", column: "group_id", name: "fk_9dc8b9d4b2", on_delete: :cascade
  add_foreign_key "user_group_callouts", "users", name: "fk_c366e12ec3", on_delete: :cascade
  add_foreign_key "user_highest_roles", "users", on_delete: :cascade
  add_foreign_key "user_interacted_projects", "projects", name: "fk_722ceba4f7", on_delete: :cascade
  add_foreign_key "user_interacted_projects", "users", name: "fk_0894651f08", on_delete: :cascade
  add_foreign_key "user_namespace_callouts", "namespaces", name: "fk_27a69fd1bd", on_delete: :cascade
  add_foreign_key "user_namespace_callouts", "users", name: "fk_4b1257f385", on_delete: :cascade
  add_foreign_key "user_permission_export_uploads", "users", on_delete: :cascade
  add_foreign_key "user_phone_number_validations", "users", on_delete: :cascade
  add_foreign_key "user_preferences", "users", on_delete: :cascade
  add_foreign_key "user_project_callouts", "projects", name: "fk_33b4814f6b", on_delete: :cascade
  add_foreign_key "user_project_callouts", "users", name: "fk_f62dd11a33", on_delete: :cascade
  add_foreign_key "user_statuses", "users", on_delete: :cascade
  add_foreign_key "user_synced_attributes_metadata", "users", on_delete: :cascade
  add_foreign_key "users", "application_setting_terms", column: "accepted_term_id", name: "fk_789cd90b35", on_delete: :cascade
  add_foreign_key "users", "namespaces", column: "managing_group_id", name: "fk_a4b8fefe3e", on_delete: :nullify
  add_foreign_key "users_ops_dashboard_projects", "projects", on_delete: :cascade
  add_foreign_key "users_ops_dashboard_projects", "users", on_delete: :cascade
  add_foreign_key "users_security_dashboard_projects", "projects", on_delete: :cascade
  add_foreign_key "users_security_dashboard_projects", "users", on_delete: :cascade
  add_foreign_key "users_star_projects", "projects", name: "fk_22cd27ddfc", on_delete: :cascade
  add_foreign_key "vulnerabilities", "epics", name: "fk_1d37cddf91", on_delete: :nullify
  add_foreign_key "vulnerabilities", "milestones", column: "due_date_sourcing_milestone_id", name: "fk_7c5bb22a22", on_delete: :nullify
  add_foreign_key "vulnerabilities", "milestones", column: "start_date_sourcing_milestone_id", name: "fk_88b4d546ef", on_delete: :nullify
  add_foreign_key "vulnerabilities", "milestones", name: "fk_131d289c65", on_delete: :nullify
  add_foreign_key "vulnerabilities", "projects", name: "fk_efb96ab1e2", on_delete: :cascade
  add_foreign_key "vulnerabilities", "users", column: "author_id", name: "fk_b1de915a15", on_delete: :nullify
  add_foreign_key "vulnerabilities", "users", column: "confirmed_by_id", name: "fk_959d40ad0a", on_delete: :nullify
  add_foreign_key "vulnerabilities", "users", column: "dismissed_by_id", name: "fk_725465b774", on_delete: :nullify
  add_foreign_key "vulnerabilities", "users", column: "last_edited_by_id", name: "fk_1302949740", on_delete: :nullify
  add_foreign_key "vulnerabilities", "users", column: "resolved_by_id", name: "fk_76bc5f5455", on_delete: :nullify
  add_foreign_key "vulnerabilities", "users", column: "updated_by_id", name: "fk_7ac31eacb9", on_delete: :nullify
  add_foreign_key "vulnerability_exports", "namespaces", column: "group_id", name: "fk_c3d3cb5d0f", on_delete: :cascade
  add_foreign_key "vulnerability_exports", "projects", on_delete: :cascade
  add_foreign_key "vulnerability_exports", "users", column: "author_id", on_delete: :cascade
  add_foreign_key "vulnerability_external_issue_links", "users", column: "author_id", on_delete: :nullify
  add_foreign_key "vulnerability_external_issue_links", "vulnerabilities", name: "fk_f07bb8233d", on_delete: :cascade
  add_foreign_key "vulnerability_feedback", "issues", on_delete: :nullify
  add_foreign_key "vulnerability_feedback", "merge_requests", name: "fk_563ff1912e", on_delete: :nullify
  add_foreign_key "vulnerability_feedback", "projects", on_delete: :cascade
  add_foreign_key "vulnerability_feedback", "users", column: "author_id", on_delete: :cascade
  add_foreign_key "vulnerability_feedback", "users", column: "comment_author_id", name: "fk_94f7c8a81e", on_delete: :nullify
  add_foreign_key "vulnerability_finding_evidences", "vulnerability_occurrences", on_delete: :cascade
  add_foreign_key "vulnerability_finding_links", "vulnerability_occurrences", on_delete: :cascade
  add_foreign_key "vulnerability_finding_signatures", "vulnerability_occurrences", column: "finding_id", on_delete: :cascade
  add_foreign_key "vulnerability_findings_remediations", "vulnerability_occurrences", on_delete: :cascade
  add_foreign_key "vulnerability_findings_remediations", "vulnerability_remediations", on_delete: :cascade
  add_foreign_key "vulnerability_flags", "vulnerability_occurrences", on_delete: :cascade
  add_foreign_key "vulnerability_historical_statistics", "projects", on_delete: :cascade
  add_foreign_key "vulnerability_identifiers", "projects", on_delete: :cascade
  add_foreign_key "vulnerability_issue_links", "issues", on_delete: :cascade
  add_foreign_key "vulnerability_issue_links", "vulnerabilities", on_delete: :cascade
  add_foreign_key "vulnerability_merge_request_links", "merge_requests", name: "fk_6d7aa8796e", on_delete: :cascade
  add_foreign_key "vulnerability_merge_request_links", "vulnerabilities", name: "fk_2ef3954596", on_delete: :cascade
  add_foreign_key "vulnerability_occurrence_identifiers", "vulnerability_identifiers", column: "identifier_id", on_delete: :cascade
  add_foreign_key "vulnerability_occurrence_identifiers", "vulnerability_occurrences", column: "occurrence_id", on_delete: :cascade
  add_foreign_key "vulnerability_occurrence_pipelines", "vulnerability_occurrences", column: "occurrence_id", on_delete: :cascade
  add_foreign_key "vulnerability_occurrences", "projects", on_delete: :cascade
  add_foreign_key "vulnerability_occurrences", "vulnerabilities", name: "fk_97ffe77653", on_delete: :nullify
  add_foreign_key "vulnerability_occurrences", "vulnerability_identifiers", column: "primary_identifier_id", on_delete: :cascade
  add_foreign_key "vulnerability_occurrences", "vulnerability_scanners", column: "scanner_id", on_delete: :cascade
  add_foreign_key "vulnerability_reads", "cluster_agents", column: "casted_cluster_agent_id", name: "fk_aee839e611", on_delete: :nullify
  add_foreign_key "vulnerability_reads", "namespaces", name: "fk_4f593f6c62", on_delete: :cascade
  add_foreign_key "vulnerability_reads", "projects", name: "fk_5001652292", on_delete: :cascade
  add_foreign_key "vulnerability_reads", "vulnerabilities", name: "fk_62736f638f", on_delete: :cascade
  add_foreign_key "vulnerability_reads", "vulnerability_scanners", column: "scanner_id", name: "fk_b28c28abf1", on_delete: :cascade
  add_foreign_key "vulnerability_remediations", "projects", name: "fk_fc61a535a0", on_delete: :cascade
  add_foreign_key "vulnerability_scanners", "projects", on_delete: :cascade
  add_foreign_key "vulnerability_state_transitions", "users", column: "author_id", name: "fk_e719dc63df", on_delete: :nullify
  add_foreign_key "vulnerability_state_transitions", "vulnerabilities", on_delete: :cascade
  add_foreign_key "vulnerability_statistics", "projects", on_delete: :cascade
  add_foreign_key "vulnerability_user_mentions", "notes", on_delete: :cascade
  add_foreign_key "vulnerability_user_mentions", "vulnerabilities", on_delete: :cascade
  add_foreign_key "web_hooks", "integrations", name: "fk_db1ea5699b", on_delete: :cascade
  add_foreign_key "web_hooks", "namespaces", column: "group_id", on_delete: :cascade
  add_foreign_key "web_hooks", "projects", name: "fk_0c8ca6d9d1", on_delete: :cascade
  add_foreign_key "webauthn_registrations", "u2f_registrations", name: "fk_13e04d719a", on_delete: :cascade
  add_foreign_key "webauthn_registrations", "users", on_delete: :cascade
  add_foreign_key "wiki_page_meta", "projects", on_delete: :cascade
  add_foreign_key "wiki_page_slugs", "wiki_page_meta", column: "wiki_page_meta_id", on_delete: :cascade
  add_foreign_key "work_item_hierarchy_restrictions", "work_item_types", column: "child_type_id", on_delete: :cascade
  add_foreign_key "work_item_hierarchy_restrictions", "work_item_types", column: "parent_type_id", on_delete: :cascade
  add_foreign_key "work_item_parent_links", "issues", column: "work_item_id", on_delete: :cascade
  add_foreign_key "work_item_parent_links", "issues", column: "work_item_parent_id", on_delete: :cascade
  add_foreign_key "work_item_progresses", "issues", on_delete: :cascade
  add_foreign_key "work_item_types", "namespaces", on_delete: :cascade
  add_foreign_key "x509_certificates", "x509_issuers", on_delete: :cascade
  add_foreign_key "x509_commit_signatures", "projects", on_delete: :cascade
  add_foreign_key "x509_commit_signatures", "x509_certificates", on_delete: :cascade
  add_foreign_key "zentao_tracker_data", "integrations", on_delete: :cascade
  add_foreign_key "zoom_meetings", "issues", on_delete: :cascade
  add_foreign_key "zoom_meetings", "projects", on_delete: :cascade
end
