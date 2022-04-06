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

ActiveRecord::Schema.define(version: 2021_08_02_114054) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "announcements", id: :serial, force: :cascade do |t|
    t.text "text"
    t.date "show_until"
    t.boolean "active", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["show_until", "active"], name: "index_announcements_on_show_until_and_active"
  end

  create_table "attachable_journals", id: :serial, force: :cascade do |t|
    t.integer "journal_id", null: false
    t.integer "attachment_id", null: false
    t.string "filename", default: "", null: false
    t.index ["attachment_id"], name: "index_attachable_journals_on_attachment_id"
    t.index ["journal_id"], name: "index_attachable_journals_on_journal_id"
  end

  create_table "attachment_journals", id: :serial, force: :cascade do |t|
    t.integer "container_id"
    t.string "container_type", limit: 30
    t.string "filename", default: "", null: false
    t.string "disk_filename", default: "", null: false
    t.bigint "filesize", default: 0, null: false
    t.string "content_type", default: ""
    t.string "digest", limit: 40, default: "", null: false
    t.integer "downloads", default: 0, null: false
    t.integer "author_id", default: 0, null: false
    t.text "description"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.integer "container_id"
    t.string "container_type", limit: 30
    t.string "filename", default: "", null: false
    t.string "disk_filename", default: "", null: false
    t.bigint "filesize", default: 0, null: false
    t.string "content_type", default: ""
    t.string "digest", limit: 40, default: "", null: false
    t.integer "downloads", default: 0, null: false
    t.integer "author_id", default: 0, null: false
    t.datetime "created_at"
    t.string "description"
    t.string "file"
    t.text "fulltext"
    t.tsvector "fulltext_tsv"
    t.tsvector "file_tsv"
    t.datetime "updated_at"
    t.index ["author_id"], name: "index_attachments_on_author_id"
    t.index ["container_id", "container_type"], name: "index_attachments_on_container_id_and_container_type"
    t.index ["created_at"], name: "index_attachments_on_created_at"
    t.index ["file_tsv"], name: "index_attachments_on_file_tsv", using: :gin
    t.index ["fulltext_tsv"], name: "index_attachments_on_fulltext_tsv", using: :gin
  end

  create_table "attribute_help_texts", id: :serial, force: :cascade do |t|
    t.text "help_text", null: false
    t.string "type", null: false
    t.string "attribute_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "auth_sources", id: :serial, force: :cascade do |t|
    t.string "type", limit: 30, default: "", null: false
    t.string "name", limit: 60, default: "", null: false
    t.string "host", limit: 60
    t.integer "port"
    t.string "account"
    t.string "account_password", default: ""
    t.string "base_dn"
    t.string "attr_login", limit: 30
    t.string "attr_firstname", limit: 30
    t.string "attr_lastname", limit: 30
    t.string "attr_mail", limit: 30
    t.boolean "onthefly_register", default: false, null: false
    t.string "attr_admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tls_mode", default: 0, null: false
    t.text "filter_string"
    t.index ["id", "type"], name: "index_auth_sources_on_id_and_type"
  end

  create_table "bcf_comments", force: :cascade do |t|
    t.text "uuid"
    t.bigint "journal_id"
    t.bigint "issue_id"
    t.bigint "viewpoint_id"
    t.index ["issue_id"], name: "index_bcf_comments_on_issue_id"
    t.index ["journal_id"], name: "index_bcf_comments_on_journal_id"
    t.index ["uuid", "issue_id"], name: "index_bcf_comments_on_uuid_and_issue_id", unique: true
    t.index ["uuid"], name: "index_bcf_comments_on_uuid"
    t.index ["viewpoint_id"], name: "index_bcf_comments_on_viewpoint_id"
  end

  create_table "bcf_issues", force: :cascade do |t|
    t.text "uuid"
    t.xml "markup"
    t.bigint "work_package_id"
    t.string "stage"
    t.integer "index"
    t.text "labels", default: [], array: true
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["uuid"], name: "index_bcf_issues_on_uuid", unique: true
    t.index ["work_package_id"], name: "index_bcf_issues_on_work_package_id", unique: true
  end

  create_table "bcf_viewpoints", force: :cascade do |t|
    t.text "uuid"
    t.text "viewpoint_name"
    t.bigint "issue_id"
    t.jsonb "json_viewpoint"
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["issue_id"], name: "index_bcf_viewpoints_on_issue_id"
    t.index ["uuid", "issue_id"], name: "index_bcf_viewpoints_on_uuid_and_issue_id", unique: true
    t.index ["uuid"], name: "index_bcf_viewpoints_on_uuid"
  end

  create_table "budget_journals", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "author_id", null: false
    t.string "subject", null: false
    t.text "description"
    t.date "fixed_date", null: false
  end

  create_table "budgets", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "author_id", null: false
    t.string "subject", null: false
    t.text "description", null: false
    t.date "fixed_date", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id", "updated_at"], name: "index_budgets_on_project_id_and_updated_at"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.integer "project_id", default: 0, null: false
    t.string "name", limit: 256, default: "", null: false
    t.integer "assigned_to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_categories_on_assigned_to_id"
    t.index ["project_id"], name: "issue_categories_project_id"
  end

  create_table "changes", id: :serial, force: :cascade do |t|
    t.integer "changeset_id", null: false
    t.string "action", limit: 1, default: "", null: false
    t.text "path", null: false
    t.text "from_path"
    t.string "from_revision"
    t.string "revision"
    t.string "branch"
    t.index ["changeset_id"], name: "changesets_changeset_id"
  end

  create_table "changeset_journals", id: :serial, force: :cascade do |t|
    t.integer "repository_id", null: false
    t.string "revision", null: false
    t.string "committer"
    t.datetime "committed_on", null: false
    t.text "comments"
    t.date "commit_date"
    t.string "scmid"
    t.integer "user_id"
  end

  create_table "changesets", id: :serial, force: :cascade do |t|
    t.integer "repository_id", null: false
    t.string "revision", null: false
    t.string "committer"
    t.datetime "committed_on", null: false
    t.text "comments"
    t.date "commit_date"
    t.string "scmid"
    t.integer "user_id"
    t.index ["committed_on"], name: "index_changesets_on_committed_on"
    t.index ["repository_id", "committed_on"], name: "index_changesets_on_repository_id_and_committed_on"
    t.index ["repository_id", "revision"], name: "changesets_repos_rev", unique: true
    t.index ["repository_id", "scmid"], name: "changesets_repos_scmid"
    t.index ["repository_id"], name: "index_changesets_on_repository_id"
    t.index ["user_id"], name: "index_changesets_on_user_id"
  end

  create_table "changesets_work_packages", id: false, force: :cascade do |t|
    t.integer "changeset_id", null: false
    t.integer "work_package_id", null: false
    t.index ["changeset_id", "work_package_id"], name: "changesets_work_packages_ids", unique: true
  end

  create_table "colors", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "hexcode", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.string "commented_type", limit: 30, default: "", null: false
    t.integer "commented_id", default: 0, null: false
    t.integer "author_id", default: 0, null: false
    t.text "comments"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["commented_id", "commented_type"], name: "index_comments_on_commented_id_and_commented_type"
  end

  create_table "cost_entries", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.integer "work_package_id", null: false
    t.integer "cost_type_id", null: false
    t.float "units", null: false
    t.date "spent_on", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "comments", null: false
    t.boolean "blocked", default: false, null: false
    t.decimal "overridden_costs", precision: 15, scale: 4
    t.decimal "costs", precision: 15, scale: 4
    t.integer "rate_id"
    t.integer "tyear", null: false
    t.integer "tmonth", null: false
    t.integer "tweek", null: false
  end

  create_table "cost_queries", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id"
    t.string "name", null: false
    t.boolean "is_public", default: false, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "serialized", limit: 2000, null: false
  end

  create_table "cost_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "unit", null: false
    t.string "unit_plural", null: false
    t.boolean "default", default: false, null: false
    t.datetime "deleted_at"
  end

  create_table "custom_actions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "actions"
    t.text "description"
    t.integer "position"
  end

  create_table "custom_actions_projects", id: :serial, force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "custom_action_id"
    t.index ["custom_action_id"], name: "index_custom_actions_projects_on_custom_action_id"
    t.index ["project_id"], name: "index_custom_actions_projects_on_project_id"
  end

  create_table "custom_actions_roles", id: :serial, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "custom_action_id"
    t.index ["custom_action_id"], name: "index_custom_actions_roles_on_custom_action_id"
    t.index ["role_id"], name: "index_custom_actions_roles_on_role_id"
  end

  create_table "custom_actions_statuses", id: :serial, force: :cascade do |t|
    t.bigint "status_id"
    t.bigint "custom_action_id"
    t.index ["custom_action_id"], name: "index_custom_actions_statuses_on_custom_action_id"
    t.index ["status_id"], name: "index_custom_actions_statuses_on_status_id"
  end

  create_table "custom_actions_types", id: :serial, force: :cascade do |t|
    t.bigint "type_id"
    t.bigint "custom_action_id"
    t.index ["custom_action_id"], name: "index_custom_actions_types_on_custom_action_id"
    t.index ["type_id"], name: "index_custom_actions_types_on_type_id"
  end

  create_table "custom_fields", id: :serial, force: :cascade do |t|
    t.string "type", limit: 30, default: "", null: false
    t.string "field_format", limit: 30, default: "", null: false
    t.string "regexp", default: ""
    t.integer "min_length", default: 0, null: false
    t.integer "max_length", default: 0, null: false
    t.boolean "is_required", default: false, null: false
    t.boolean "is_for_all", default: false, null: false
    t.boolean "is_filter", default: false, null: false
    t.integer "position", default: 1
    t.boolean "searchable", default: false
    t.boolean "editable", default: true
    t.boolean "visible", default: true, null: false
    t.boolean "multi_value", default: false
    t.text "default_value"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "content_right_to_left", default: false
    t.index ["id", "type"], name: "index_custom_fields_on_id_and_type"
  end

  create_table "custom_fields_projects", id: false, force: :cascade do |t|
    t.integer "custom_field_id", default: 0, null: false
    t.integer "project_id", default: 0, null: false
    t.index ["custom_field_id", "project_id"], name: "index_custom_fields_projects_on_custom_field_id_and_project_id"
  end

  create_table "custom_fields_types", id: false, force: :cascade do |t|
    t.integer "custom_field_id", default: 0, null: false
    t.integer "type_id", default: 0, null: false
    t.index ["custom_field_id", "type_id"], name: "custom_fields_types_unique", unique: true
  end

  create_table "custom_options", id: :serial, force: :cascade do |t|
    t.integer "custom_field_id"
    t.integer "position"
    t.boolean "default_value"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_styles", id: :serial, force: :cascade do |t|
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "favicon"
    t.string "touch_icon"
    t.string "theme", default: "OpenProject"
    t.string "theme_logo"
  end

  create_table "custom_values", id: :serial, force: :cascade do |t|
    t.string "customized_type", limit: 30, default: "", null: false
    t.integer "customized_id", default: 0, null: false
    t.integer "custom_field_id", default: 0, null: false
    t.text "value"
    t.index ["custom_field_id"], name: "index_custom_values_on_custom_field_id"
    t.index ["customized_type", "customized_id"], name: "custom_values_customized"
  end

  create_table "customizable_journals", id: :serial, force: :cascade do |t|
    t.integer "journal_id", null: false
    t.integer "custom_field_id", null: false
    t.text "value"
    t.index ["custom_field_id"], name: "index_customizable_journals_on_custom_field_id"
    t.index ["journal_id"], name: "index_customizable_journals_on_journal_id"
  end

# Could not dump table "delayed_job_statuses" because of following StandardError
#   Unknown type 'delayed_job_status' for column 'status'

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "queue"
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "design_colors", id: :serial, force: :cascade do |t|
    t.string "variable"
    t.string "hexcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["variable"], name: "index_design_colors_on_variable", unique: true
  end

  create_table "document_journals", id: :serial, force: :cascade do |t|
    t.integer "project_id", default: 0, null: false
    t.integer "category_id", default: 0, null: false
    t.string "title", limit: 60, default: "", null: false
    t.text "description"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.integer "project_id", default: 0, null: false
    t.integer "category_id", default: 0, null: false
    t.string "title", limit: 60, default: "", null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_id"], name: "index_documents_on_category_id"
    t.index ["created_at"], name: "index_documents_on_created_at"
    t.index ["project_id"], name: "documents_project_id"
  end

  create_table "done_statuses_for_project", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "status_id"
  end

  create_table "enabled_modules", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "name", null: false
    t.index ["name"], name: "index_enabled_modules_on_name"
    t.index ["project_id"], name: "enabled_modules_project_id"
  end

  create_table "enterprise_tokens", id: :serial, force: :cascade do |t|
    t.text "encoded_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enumerations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 30, default: "", null: false
    t.integer "position", default: 1
    t.boolean "is_default", default: false, null: false
    t.string "type"
    t.boolean "active", default: true, null: false
    t.integer "project_id"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "color_id"
    t.index ["color_id"], name: "index_enumerations_on_color_id"
    t.index ["id", "type"], name: "index_enumerations_on_id_and_type"
    t.index ["project_id"], name: "index_enumerations_on_project_id"
  end

  create_table "export_card_configurations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "per_page"
    t.string "page_size"
    t.string "orientation"
    t.text "rows"
    t.boolean "active", default: true
    t.text "description"
  end

  create_table "exports", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
  end

  create_table "forums", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", default: "", null: false
    t.string "description"
    t.integer "position", default: 1
    t.integer "topics_count", default: 0, null: false
    t.integer "messages_count", default: 0, null: false
    t.integer "last_message_id"
    t.index ["last_message_id"], name: "index_forums_on_last_message_id"
    t.index ["project_id"], name: "forums_project_id"
  end

  create_table "github_check_runs", force: :cascade do |t|
    t.bigint "github_pull_request_id", null: false
    t.bigint "github_id", null: false
    t.string "github_html_url", null: false
    t.bigint "app_id", null: false
    t.string "github_app_owner_avatar_url", null: false
    t.string "status", null: false
    t.string "name", null: false
    t.string "conclusion"
    t.string "output_title"
    t.string "output_summary"
    t.string "details_url"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["github_pull_request_id"], name: "index_github_check_runs_on_github_pull_request_id"
  end

  create_table "github_pull_requests", force: :cascade do |t|
    t.bigint "github_user_id"
    t.bigint "merged_by_id"
    t.bigint "github_id"
    t.integer "number", null: false
    t.string "github_html_url", null: false
    t.string "state", null: false
    t.string "repository", null: false
    t.datetime "github_updated_at"
    t.string "title"
    t.text "body"
    t.boolean "draft"
    t.boolean "merged"
    t.datetime "merged_at"
    t.integer "comments_count"
    t.integer "review_comments_count"
    t.integer "additions_count"
    t.integer "deletions_count"
    t.integer "changed_files_count"
    t.json "labels"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["github_user_id"], name: "index_github_pull_requests_on_github_user_id"
    t.index ["merged_by_id"], name: "index_github_pull_requests_on_merged_by_id"
  end

  create_table "github_pull_requests_work_packages", id: false, force: :cascade do |t|
    t.bigint "github_pull_request_id", null: false
    t.bigint "work_package_id", null: false
    t.index ["github_pull_request_id", "work_package_id"], name: "unique_index_gh_prs_wps_on_gh_pr_id_and_wp_id", unique: true
    t.index ["github_pull_request_id"], name: "github_pr_wp_pr_id"
  end

  create_table "github_users", force: :cascade do |t|
    t.bigint "github_id", null: false
    t.string "github_login", null: false
    t.string "github_html_url", null: false
    t.string "github_avatar_url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "grid_widgets", force: :cascade do |t|
    t.integer "start_row", null: false
    t.integer "end_row", null: false
    t.integer "start_column", null: false
    t.integer "end_column", null: false
    t.string "identifier"
    t.text "options"
    t.bigint "grid_id"
    t.index ["grid_id"], name: "index_grid_widgets_on_grid_id"
  end

  create_table "grids", force: :cascade do |t|
    t.integer "row_count", null: false
    t.integer "column_count", null: false
    t.string "type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id"
    t.text "name"
    t.text "options"
    t.index ["project_id"], name: "index_grids_on_project_id"
    t.index ["user_id"], name: "index_grids_on_user_id"
  end

  create_table "group_users", force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id", null: false
    t.index ["group_id", "user_id"], name: "group_user_ids", unique: true
    t.index ["user_id", "group_id"], name: "index_group_users_on_user_id_and_group_id", unique: true
  end

  create_table "ifc_models", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id"
    t.bigint "uploader_id"
    t.boolean "is_default", default: false, null: false
    t.index ["is_default"], name: "index_ifc_models_on_is_default"
    t.index ["project_id"], name: "index_ifc_models_on_project_id"
    t.index ["uploader_id"], name: "index_ifc_models_on_uploader_id"
  end

  create_table "journals", id: :serial, force: :cascade do |t|
    t.string "journable_type"
    t.integer "journable_id"
    t.integer "user_id", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.integer "version", default: 0, null: false
    t.string "activity_type"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.string "data_type"
    t.bigint "data_id"
    t.index ["activity_type"], name: "index_journals_on_activity_type"
    t.index ["created_at"], name: "index_journals_on_created_at"
    t.index ["data_id", "data_type"], name: "index_journals_on_data_id_and_data_type", unique: true
    t.index ["journable_id"], name: "index_journals_on_journable_id"
    t.index ["journable_type", "journable_id", "version"], name: "index_journals_on_journable_type_and_journable_id_and_version", unique: true
    t.index ["journable_type"], name: "index_journals_on_journable_type"
    t.index ["user_id"], name: "index_journals_on_user_id"
  end

  create_table "labor_budget_items", id: :serial, force: :cascade do |t|
    t.integer "budget_id", null: false
    t.float "hours", null: false
    t.integer "user_id"
    t.string "comments", default: "", null: false
    t.decimal "amount", precision: 15, scale: 4
  end

  create_table "ldap_groups_memberships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["group_id"], name: "index_ldap_groups_memberships_on_group_id"
    t.index ["user_id"], name: "index_ldap_groups_memberships_on_user_id"
  end

  create_table "ldap_groups_synchronized_filters", force: :cascade do |t|
    t.string "name"
    t.string "group_name_attribute"
    t.string "filter_string"
    t.bigint "auth_source_id"
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "base_dn"
    t.boolean "sync_users", default: false, null: false
    t.index ["auth_source_id"], name: "index_ldap_groups_synchronized_filters_on_auth_source_id"
  end

  create_table "ldap_groups_synchronized_groups", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "auth_source_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "dn"
    t.integer "users_count", default: 0, null: false
    t.bigint "filter_id"
    t.boolean "sync_users", default: false, null: false
    t.index ["auth_source_id"], name: "index_ldap_groups_synchronized_groups_on_auth_source_id"
    t.index ["filter_id"], name: "index_ldap_groups_synchronized_groups_on_filter_id"
    t.index ["group_id"], name: "index_ldap_groups_synchronized_groups_on_group_id"
  end

  create_table "material_budget_items", id: :serial, force: :cascade do |t|
    t.integer "budget_id", null: false
    t.float "units", null: false
    t.integer "cost_type_id"
    t.string "comments", default: "", null: false
    t.decimal "amount", precision: 15, scale: 4
  end

  create_table "meeting_content_journals", id: :serial, force: :cascade do |t|
    t.integer "meeting_id"
    t.integer "author_id"
    t.text "text"
    t.boolean "locked"
  end

  create_table "meeting_contents", id: :serial, force: :cascade do |t|
    t.string "type"
    t.integer "meeting_id"
    t.integer "author_id"
    t.text "text"
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked", default: false
  end

  create_table "meeting_journals", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "author_id"
    t.integer "project_id"
    t.string "location"
    t.datetime "start_time"
    t.float "duration"
  end

  create_table "meeting_participants", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "meeting_id"
    t.string "email"
    t.string "name"
    t.boolean "invited"
    t.boolean "attended"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meetings", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "author_id"
    t.integer "project_id"
    t.string "location"
    t.datetime "start_time"
    t.float "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "updated_at"], name: "index_meetings_on_project_id_and_updated_at"
  end

  create_table "member_roles", id: :serial, force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "role_id", null: false
    t.integer "inherited_from"
    t.index ["inherited_from"], name: "index_member_roles_on_inherited_from"
    t.index ["member_id", "role_id", "inherited_from"], name: "unique_inherited_role", unique: true
    t.index ["member_id"], name: "index_member_roles_on_member_id"
    t.index ["role_id"], name: "index_member_roles_on_role_id"
  end

  create_table "members", id: :serial, force: :cascade do |t|
    t.integer "user_id", default: 0, null: false
    t.integer "project_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["project_id"], name: "index_members_on_project_id"
    t.index ["user_id", "project_id"], name: "index_members_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "menu_items", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.integer "parent_id"
    t.text "options"
    t.integer "navigatable_id"
    t.string "type"
    t.index ["navigatable_id", "title"], name: "index_menu_items_on_navigatable_id_and_title"
    t.index ["parent_id"], name: "index_menu_items_on_parent_id"
  end

  create_table "message_journals", id: :serial, force: :cascade do |t|
    t.integer "forum_id", null: false
    t.integer "parent_id"
    t.string "subject", default: "", null: false
    t.text "content"
    t.integer "author_id"
    t.boolean "locked", default: false
    t.integer "sticky", default: 0
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "forum_id", null: false
    t.integer "parent_id"
    t.string "subject", default: "", null: false
    t.text "content"
    t.integer "author_id"
    t.integer "replies_count", default: 0, null: false
    t.integer "last_reply_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "locked", default: false
    t.integer "sticky", default: 0
    t.datetime "sticked_on"
    t.index ["author_id"], name: "index_messages_on_author_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["forum_id", "updated_at"], name: "index_messages_on_forum_id_and_updated_at"
    t.index ["forum_id"], name: "messages_board_id"
    t.index ["last_reply_id"], name: "index_messages_on_last_reply_id"
    t.index ["parent_id"], name: "messages_parent_id"
  end

  create_table "news", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "title", limit: 60, default: "", null: false
    t.string "summary", default: ""
    t.text "description"
    t.integer "author_id", default: 0, null: false
    t.datetime "created_at"
    t.integer "comments_count", default: 0, null: false
    t.datetime "updated_at"
    t.index ["author_id"], name: "index_news_on_author_id"
    t.index ["created_at"], name: "index_news_on_created_at"
    t.index ["project_id", "created_at"], name: "index_news_on_project_id_and_created_at"
    t.index ["project_id"], name: "news_project_id"
  end

  create_table "news_journals", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "title", limit: 60, default: "", null: false
    t.string "summary", default: ""
    t.text "description"
    t.integer "author_id", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
  end

  create_table "notification_settings", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id", null: false
    t.integer "channel", limit: 2
    t.boolean "watched", default: false
    t.boolean "involved", default: false
    t.boolean "mentioned", default: false
    t.boolean "all", default: false
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "work_package_commented", default: false
    t.boolean "work_package_created", default: false
    t.boolean "work_package_processed", default: false
    t.boolean "work_package_prioritized", default: false
    t.boolean "work_package_scheduled", default: false
    t.index ["all"], name: "index_notification_settings_on_all"
    t.index ["project_id"], name: "index_notification_settings_on_project_id"
    t.index ["user_id", "channel"], name: "index_notification_settings_unique_project_null", unique: true, where: "(project_id IS NULL)"
    t.index ["user_id", "project_id", "channel"], name: "index_notification_settings_unique_project", unique: true, where: "(project_id IS NOT NULL)"
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
    t.index ["work_package_commented"], name: "index_notification_settings_on_work_package_commented"
    t.index ["work_package_created"], name: "index_notification_settings_on_work_package_created"
    t.index ["work_package_prioritized"], name: "index_notification_settings_on_work_package_prioritized"
    t.index ["work_package_processed"], name: "index_notification_settings_on_work_package_processed"
    t.index ["work_package_scheduled"], name: "index_notification_settings_on_work_package_scheduled"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "subject"
    t.boolean "read_ian", default: false
    t.boolean "read_mail", default: false
    t.integer "reason_ian", limit: 2
    t.bigint "recipient_id", null: false
    t.bigint "actor_id"
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.bigint "project_id"
    t.bigint "journal_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "read_mail_digest", default: false
    t.integer "reason_mail", limit: 2
    t.integer "reason_mail_digest", limit: 2
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["project_id"], name: "index_notifications_on_project_id"
    t.index ["read_ian"], name: "index_notifications_on_read_ian"
    t.index ["read_mail"], name: "index_notifications_on_read_mail"
    t.index ["read_mail_digest"], name: "index_notifications_on_read_mail_digest"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["resource_type", "resource_id"], name: "index_notifications_on_resource"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.string "owner_type"
    t.integer "owner_id"
    t.integer "client_credentials_user_id"
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "ordered_work_packages", force: :cascade do |t|
    t.integer "position", null: false
    t.integer "query_id"
    t.integer "work_package_id"
    t.index ["position"], name: "index_ordered_work_packages_on_position"
    t.index ["query_id"], name: "index_ordered_work_packages_on_query_id"
    t.index ["work_package_id"], name: "index_ordered_work_packages_on_work_package_id"
  end

  create_table "plaintext_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id", default: 0, null: false
    t.string "action", limit: 30, default: "", null: false
    t.string "value", limit: 40, default: "", null: false
    t.datetime "created_on", null: false
    t.index ["user_id"], name: "index_plaintext_tokens_on_user_id"
  end

  create_table "project_associations", id: :serial, force: :cascade do |t|
    t.integer "project_a_id"
    t.integer "project_b_id"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_a_id"], name: "index_project_associations_on_project_a_id"
    t.index ["project_b_id"], name: "index_project_associations_on_project_b_id"
  end

  create_table "project_statuses", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.text "explanation"
    t.integer "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_project_statuses_on_project_id", unique: true
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.text "description"
    t.boolean "public", default: true, null: false
    t.integer "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "identifier"
    t.integer "lft"
    t.integer "rgt"
    t.boolean "active", default: true, null: false
    t.boolean "templated", default: false, null: false
    t.index ["identifier"], name: "index_projects_on_identifier", unique: true
    t.index ["lft"], name: "index_projects_on_lft"
    t.index ["rgt"], name: "index_projects_on_rgt"
  end

  create_table "projects_types", id: false, force: :cascade do |t|
    t.integer "project_id", default: 0, null: false
    t.integer "type_id", default: 0, null: false
    t.index ["project_id", "type_id"], name: "projects_types_unique", unique: true
    t.index ["project_id"], name: "projects_types_project_id"
  end

  create_table "queries", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "name", default: "", null: false
    t.text "filters"
    t.integer "user_id", default: 0, null: false
    t.boolean "is_public", default: false, null: false
    t.text "column_names"
    t.text "sort_criteria"
    t.string "group_by"
    t.boolean "display_sums", default: false, null: false
    t.boolean "timeline_visible", default: false
    t.boolean "show_hierarchies", default: false
    t.integer "timeline_zoom_level", default: 5
    t.text "timeline_labels"
    t.text "highlighting_mode"
    t.text "highlighted_attributes"
    t.boolean "hidden", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "display_representation"
    t.index ["project_id"], name: "index_queries_on_project_id"
    t.index ["updated_at"], name: "index_queries_on_updated_at"
    t.index ["user_id"], name: "index_queries_on_user_id"
  end

  create_table "rates", id: :serial, force: :cascade do |t|
    t.date "valid_from", null: false
    t.decimal "rate", precision: 15, scale: 4, null: false
    t.string "type", null: false
    t.integer "project_id"
    t.integer "user_id"
    t.integer "cost_type_id"
  end

  create_table "recaptcha_entries", id: :serial, force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "version", null: false
    t.index ["user_id"], name: "index_recaptcha_entries_on_user_id"
  end

  create_table "relations", id: :serial, force: :cascade do |t|
    t.integer "from_id", null: false
    t.integer "to_id", null: false
    t.integer "delay"
    t.text "description"
    t.integer "hierarchy", default: 0, null: false
    t.integer "relates", default: 0, null: false
    t.integer "duplicates", default: 0, null: false
    t.integer "blocks", default: 0, null: false
    t.integer "follows", default: 0, null: false
    t.integer "includes", default: 0, null: false
    t.integer "requires", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.index ["count"], name: "index_relations_on_count", where: "(count = 0)"
    t.index ["from_id", "to_id", "hierarchy", "relates", "duplicates", "blocks", "follows", "includes", "requires"], name: "index_relations_on_type_columns", unique: true
    t.index ["from_id", "to_id", "hierarchy"], name: "index_relations_only_hierarchy", where: "((relates = 0) AND (duplicates = 0) AND (follows = 0) AND (blocks = 0) AND (includes = 0) AND (requires = 0))"
    t.index ["from_id"], name: "index_relations_direct_non_hierarchy", where: "((((((((hierarchy + relates) + duplicates) + follows) + blocks) + includes) + requires) = 1) AND (hierarchy = 0))"
    t.index ["from_id"], name: "index_relations_on_from_id"
    t.index ["to_id", "follows", "from_id"], name: "index_relations_to_from_only_follows", where: "((hierarchy = 0) AND (relates = 0) AND (duplicates = 0) AND (blocks = 0) AND (includes = 0) AND (requires = 0))"
    t.index ["to_id", "hierarchy", "follows", "from_id"], name: "index_relations_hierarchy_follows_scheduling", where: "((relates = 0) AND (duplicates = 0) AND (blocks = 0) AND (includes = 0) AND (requires = 0) AND (((((((hierarchy + relates) + duplicates) + follows) + blocks) + includes) + requires) > 0))"
    t.index ["to_id"], name: "index_relations_on_to_id"
  end

  create_table "repositories", id: :serial, force: :cascade do |t|
    t.integer "project_id", default: 0, null: false
    t.string "url", default: "", null: false
    t.string "login", limit: 60, default: ""
    t.string "password", default: ""
    t.string "root_url", default: ""
    t.string "type"
    t.string "path_encoding", limit: 64
    t.string "log_encoding", limit: 64
    t.string "scm_type", null: false
    t.bigint "required_storage_bytes", default: 0, null: false
    t.datetime "storage_updated_at"
    t.index ["project_id"], name: "index_repositories_on_project_id"
  end

  create_table "role_permissions", id: :serial, force: :cascade do |t|
    t.string "permission"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 30, default: "", null: false
    t.integer "position", default: 1
    t.boolean "assignable", default: true
    t.integer "builtin", default: 0, null: false
    t.string "type", limit: 30, default: "Role"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.text "value"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["name"], name: "index_settings_on_name"
  end

  create_table "statuses", id: :serial, force: :cascade do |t|
    t.string "name", limit: 30, default: "", null: false
    t.boolean "is_closed", default: false, null: false
    t.boolean "is_default", default: false, null: false
    t.integer "position", default: 1
    t.integer "default_done_ratio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "color_id"
    t.boolean "is_readonly", default: false
    t.index ["color_id"], name: "index_statuses_on_color_id"
    t.index ["is_closed"], name: "index_statuses_on_is_closed"
    t.index ["is_default"], name: "index_statuses_on_is_default"
    t.index ["position"], name: "index_statuses_on_position"
  end

  create_table "time_entries", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.integer "work_package_id"
    t.float "hours", null: false
    t.string "comments"
    t.integer "activity_id", null: false
    t.date "spent_on", null: false
    t.integer "tyear", null: false
    t.integer "tmonth", null: false
    t.integer "tweek", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.decimal "overridden_costs", precision: 15, scale: 4
    t.decimal "costs", precision: 15, scale: 4
    t.integer "rate_id"
    t.index ["activity_id"], name: "index_time_entries_on_activity_id"
    t.index ["created_at"], name: "index_time_entries_on_created_at"
    t.index ["project_id", "updated_at"], name: "index_time_entries_on_project_id_and_updated_at"
    t.index ["project_id"], name: "time_entries_project_id"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
    t.index ["work_package_id"], name: "time_entries_issue_id"
  end

  create_table "time_entry_activities_projects", force: :cascade do |t|
    t.bigint "activity_id", null: false
    t.bigint "project_id", null: false
    t.boolean "active", default: true
    t.index ["active"], name: "index_time_entry_activities_projects_on_active"
    t.index ["activity_id"], name: "index_time_entry_activities_projects_on_activity_id"
    t.index ["project_id", "activity_id"], name: "index_teap_on_project_id_and_activity_id", unique: true
    t.index ["project_id"], name: "index_time_entry_activities_projects_on_project_id"
  end

  create_table "time_entry_journals", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.integer "work_package_id"
    t.float "hours", null: false
    t.string "comments"
    t.integer "activity_id", null: false
    t.date "spent_on", null: false
    t.integer "tyear", null: false
    t.integer "tmonth", null: false
    t.integer "tweek", null: false
    t.decimal "overridden_costs", precision: 15, scale: 2
    t.decimal "costs", precision: 15, scale: 2
    t.integer "rate_id"
  end

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.bigint "user_id"
    t.string "type"
    t.string "value", limit: 128, default: "", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "expires_on"
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "two_factor_authentication_devices", id: :serial, force: :cascade do |t|
    t.string "type"
    t.boolean "default", default: false, null: false
    t.boolean "active", default: false, null: false
    t.string "channel", null: false
    t.string "phone_number"
    t.string "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "last_used_at"
    t.text "otp_secret"
    t.integer "user_id"
    t.index ["user_id"], name: "index_two_factor_authentication_devices_on_user_id"
  end

  create_table "types", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "position", default: 1
    t.boolean "is_in_roadmap", default: true, null: false
    t.boolean "is_milestone", default: false, null: false
    t.boolean "is_default", default: false, null: false
    t.integer "color_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_standard", default: false, null: false
    t.text "attribute_groups"
    t.text "description"
    t.index ["color_id"], name: "index_types_on_color_id"
  end

  create_table "user_passwords", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "hashed_password", limit: 128, null: false
    t.string "salt", limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type", null: false
    t.index ["user_id"], name: "index_user_passwords_on_user_id"
  end

  create_table "user_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id", default: 0, null: false
    t.text "others"
    t.boolean "hide_mail", default: true
    t.string "time_zone"
    t.index ["user_id"], name: "index_user_preferences_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login", limit: 256, default: "", null: false
    t.string "firstname", default: "", null: false
    t.string "lastname", default: "", null: false
    t.string "mail", default: "", null: false
    t.boolean "admin", default: false, null: false
    t.integer "status", default: 1, null: false
    t.datetime "last_login_on"
    t.string "language", limit: 5, default: ""
    t.integer "auth_source_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.string "type"
    t.string "identity_url"
    t.string "mail_notification", default: "", null: false
    t.boolean "first_login", default: true, null: false
    t.boolean "force_password_change", default: false
    t.integer "failed_login_count", default: 0
    t.datetime "last_failed_login_on"
    t.datetime "consented_at"
    t.index ["auth_source_id"], name: "index_users_on_auth_source_id"
    t.index ["id", "type"], name: "index_users_on_id_and_type"
    t.index ["lastname", "type"], name: "unique_lastname_for_groups_and_placeholder_users", unique: true, where: "(((type)::text = 'Group'::text) OR ((type)::text = 'PlaceholderUser'::text))"
    t.index ["type", "login"], name: "index_users_on_type_and_login"
    t.index ["type", "status"], name: "index_users_on_type_and_status"
    t.index ["type"], name: "index_users_on_type"
  end

  create_table "version_settings", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "version_id"
    t.integer "display"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "version_id"], name: "index_version_settings_on_project_id_and_version_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.integer "project_id", default: 0, null: false
    t.string "name", default: "", null: false
    t.string "description", default: ""
    t.date "effective_date"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.string "wiki_page_title"
    t.string "status", default: "open"
    t.string "sharing", default: "none", null: false
    t.date "start_date"
    t.index ["project_id"], name: "versions_project_id"
    t.index ["sharing"], name: "index_versions_on_sharing"
  end

  create_table "watchers", id: :serial, force: :cascade do |t|
    t.string "watchable_type", default: "", null: false
    t.integer "watchable_id", default: 0, null: false
    t.integer "user_id"
    t.index ["user_id", "watchable_type"], name: "watchers_user_id_type"
    t.index ["user_id"], name: "index_watchers_on_user_id"
    t.index ["watchable_id", "watchable_type"], name: "index_watchers_on_watchable_id_and_watchable_type"
  end

  create_table "webhooks_events", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "webhooks_webhook_id"
    t.index ["webhooks_webhook_id"], name: "index_webhooks_events_on_webhooks_webhook_id"
  end

  create_table "webhooks_logs", id: :serial, force: :cascade do |t|
    t.integer "webhooks_webhook_id"
    t.string "event_name"
    t.string "url"
    t.text "request_headers"
    t.text "request_body"
    t.integer "response_code"
    t.text "response_headers"
    t.text "response_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["webhooks_webhook_id"], name: "index_webhooks_logs_on_webhooks_webhook_id"
  end

  create_table "webhooks_projects", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "webhooks_webhook_id"
    t.index ["project_id"], name: "index_webhooks_projects_on_project_id"
    t.index ["webhooks_webhook_id"], name: "index_webhooks_projects_on_webhooks_webhook_id"
  end

  create_table "webhooks_webhooks", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.text "description", null: false
    t.string "secret"
    t.boolean "enabled", null: false
    t.boolean "all_projects", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wiki_content_journals", id: :serial, force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "author_id"
    t.text "text"
  end

  create_table "wiki_contents", id: :serial, force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "author_id"
    t.text "text"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "lock_version", null: false
    t.index ["author_id"], name: "index_wiki_contents_on_author_id"
    t.index ["page_id", "updated_at"], name: "index_wiki_contents_on_page_id_and_updated_at"
    t.index ["page_id"], name: "wiki_contents_page_id"
  end

  create_table "wiki_pages", id: :serial, force: :cascade do |t|
    t.integer "wiki_id", null: false
    t.string "title", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "protected", default: false, null: false
    t.integer "parent_id"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_wiki_pages_on_parent_id"
    t.index ["wiki_id", "slug"], name: "wiki_pages_wiki_id_slug", unique: true
    t.index ["wiki_id", "title"], name: "wiki_pages_wiki_id_title"
    t.index ["wiki_id"], name: "index_wiki_pages_on_wiki_id"
  end

  create_table "wiki_redirects", id: :serial, force: :cascade do |t|
    t.integer "wiki_id", null: false
    t.string "title"
    t.string "redirects_to"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["wiki_id", "title"], name: "wiki_redirects_wiki_id_title"
    t.index ["wiki_id"], name: "index_wiki_redirects_on_wiki_id"
  end

  create_table "wikis", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "start_page", null: false
    t.integer "status", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "wikis_project_id"
  end

  create_table "work_package_journals", id: :serial, force: :cascade do |t|
    t.integer "type_id", default: 0, null: false
    t.integer "project_id", default: 0, null: false
    t.string "subject", default: "", null: false
    t.text "description"
    t.date "due_date"
    t.integer "category_id"
    t.integer "status_id", default: 0, null: false
    t.integer "assigned_to_id"
    t.integer "priority_id", default: 0, null: false
    t.integer "version_id"
    t.integer "author_id", default: 0, null: false
    t.integer "done_ratio", default: 0, null: false
    t.float "estimated_hours"
    t.date "start_date"
    t.integer "parent_id"
    t.integer "responsible_id"
    t.integer "budget_id"
    t.integer "story_points"
    t.float "remaining_hours"
    t.float "derived_estimated_hours"
    t.boolean "schedule_manually", default: false
    t.index ["version_id", "status_id", "project_id", "type_id"], name: "work_package_journal_on_burndown_attributes"
  end

  create_table "work_packages", id: :serial, force: :cascade do |t|
    t.integer "type_id", default: 0, null: false
    t.integer "project_id", default: 0, null: false
    t.string "subject", default: "", null: false
    t.text "description"
    t.date "due_date"
    t.integer "category_id"
    t.integer "status_id", default: 0, null: false
    t.integer "assigned_to_id"
    t.integer "priority_id", default: 0
    t.integer "version_id"
    t.integer "author_id", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.integer "done_ratio", default: 0, null: false
    t.float "estimated_hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "start_date"
    t.integer "responsible_id"
    t.integer "budget_id"
    t.integer "position"
    t.integer "story_points"
    t.float "remaining_hours"
    t.float "derived_estimated_hours"
    t.boolean "schedule_manually", default: false
    t.index ["assigned_to_id"], name: "index_work_packages_on_assigned_to_id"
    t.index ["author_id"], name: "index_work_packages_on_author_id"
    t.index ["category_id"], name: "index_work_packages_on_category_id"
    t.index ["created_at"], name: "index_work_packages_on_created_at"
    t.index ["project_id", "updated_at"], name: "index_work_packages_on_project_id_and_updated_at"
    t.index ["project_id"], name: "index_work_packages_on_project_id"
    t.index ["responsible_id"], name: "index_work_packages_on_responsible_id"
    t.index ["schedule_manually"], name: "index_work_packages_on_schedule_manually", where: "schedule_manually"
    t.index ["status_id"], name: "index_work_packages_on_status_id"
    t.index ["type_id"], name: "index_work_packages_on_type_id"
    t.index ["updated_at"], name: "index_work_packages_on_updated_at"
    t.index ["version_id"], name: "index_work_packages_on_version_id"
  end

  create_table "workflows", id: :serial, force: :cascade do |t|
    t.integer "type_id", default: 0, null: false
    t.integer "old_status_id", default: 0, null: false
    t.integer "new_status_id", default: 0, null: false
    t.integer "role_id", default: 0, null: false
    t.boolean "assignee", default: false, null: false
    t.boolean "author", default: false, null: false
    t.index ["new_status_id"], name: "index_workflows_on_new_status_id"
    t.index ["old_status_id"], name: "index_workflows_on_old_status_id"
    t.index ["role_id", "type_id", "old_status_id"], name: "wkfs_role_type_old_status"
    t.index ["role_id"], name: "index_workflows_on_role_id"
  end

  add_foreign_key "bcf_comments", "bcf_issues", column: "issue_id", on_delete: :cascade
  add_foreign_key "bcf_comments", "bcf_viewpoints", column: "viewpoint_id", on_delete: :nullify
  add_foreign_key "bcf_issues", "work_packages", on_delete: :cascade
  add_foreign_key "bcf_viewpoints", "bcf_issues", column: "issue_id", on_delete: :cascade
  add_foreign_key "ifc_models", "projects", on_delete: :cascade
  add_foreign_key "ldap_groups_synchronized_groups", "ldap_groups_synchronized_filters", column: "filter_id"
  add_foreign_key "notification_settings", "projects"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_applications", "users", column: "client_credentials_user_id", on_delete: :nullify
  add_foreign_key "oauth_applications", "users", column: "owner_id", on_delete: :nullify
  add_foreign_key "ordered_work_packages", "queries", on_delete: :cascade
  add_foreign_key "ordered_work_packages", "work_packages", on_delete: :cascade
  add_foreign_key "project_statuses", "projects"
  add_foreign_key "recaptcha_entries", "users", on_delete: :cascade
  add_foreign_key "time_entry_activities_projects", "enumerations", column: "activity_id"
  add_foreign_key "time_entry_activities_projects", "projects"
  add_foreign_key "two_factor_authentication_devices", "users"
  add_foreign_key "webhooks_events", "webhooks_webhooks"
  add_foreign_key "webhooks_logs", "webhooks_webhooks", on_delete: :cascade
  add_foreign_key "webhooks_projects", "projects"
  add_foreign_key "webhooks_projects", "webhooks_webhooks"
end
