# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_03_231700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_deletions", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.datetime "completed_at"
    t.index ["person_id"], name: "index_account_deletions_on_person_id", unique: true
  end

  create_table "account_migrations", force: :cascade do |t|
    t.integer "old_person_id", null: false
    t.integer "new_person_id", null: false
    t.datetime "completed_at"
    t.index ["old_person_id", "new_person_id"], name: "index_account_migrations_on_old_person_id_and_new_person_id", unique: true
    t.index ["old_person_id"], name: "index_account_migrations_on_old_person_id", unique: true
  end

  create_table "aspect_memberships", id: :serial, force: :cascade do |t|
    t.integer "aspect_id", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aspect_id", "contact_id"], name: "index_aspect_memberships_on_aspect_id_and_contact_id", unique: true
    t.index ["aspect_id"], name: "index_aspect_memberships_on_aspect_id"
    t.index ["contact_id"], name: "index_aspect_memberships_on_contact_id"
  end

  create_table "aspect_visibilities", id: :serial, force: :cascade do |t|
    t.integer "shareable_id", null: false
    t.integer "aspect_id", null: false
    t.string "shareable_type", default: "Post", null: false
    t.index ["aspect_id"], name: "index_aspect_visibilities_on_aspect_id"
    t.index ["shareable_id", "shareable_type", "aspect_id"], name: "index_aspect_visibilities_on_shareable_and_aspect_id", unique: true
    t.index ["shareable_id", "shareable_type"], name: "index_aspect_visibilities_on_shareable_id_and_shareable_type"
  end

  create_table "aspects", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_id"
    t.boolean "chat_enabled", default: false
    t.boolean "post_default", default: true
    t.index ["user_id", "name"], name: "index_aspects_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_aspects_on_user_id"
  end

  create_table "authorizations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "o_auth_application_id"
    t.string "refresh_token"
    t.string "code"
    t.string "redirect_uri"
    t.string "nonce"
    t.string "scopes"
    t.boolean "code_used", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["o_auth_application_id"], name: "index_authorizations_on_o_auth_application_id"
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "blocks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "person_id"
    t.index ["user_id", "person_id"], name: "index_blocks_on_user_id_and_person_id", unique: true
  end

  create_table "chat_contacts", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "jid", null: false
    t.string "name", limit: 255
    t.string "ask", limit: 128
    t.string "subscription", limit: 128, null: false
    t.index ["user_id", "jid"], name: "index_chat_contacts_on_user_id_and_jid", unique: true
  end

  create_table "chat_fragments", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "root", limit: 256, null: false
    t.string "namespace", limit: 256, null: false
    t.text "xml", null: false
    t.index ["user_id"], name: "index_chat_fragments_on_user_id", unique: true
  end

  create_table "chat_offline_messages", id: :serial, force: :cascade do |t|
    t.string "from", null: false
    t.string "to", null: false
    t.text "message", null: false
    t.datetime "created_at", null: false
  end

  create_table "comment_signatures", id: false, force: :cascade do |t|
    t.integer "comment_id", null: false
    t.text "author_signature", null: false
    t.integer "signature_order_id", null: false
    t.text "additional_data"
    t.index ["comment_id"], name: "index_comment_signatures_on_comment_id", unique: true
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "text", null: false
    t.integer "commentable_id", null: false
    t.integer "author_id", null: false
    t.string "guid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.string "commentable_type", limit: 60, default: "Post", null: false
    t.index ["author_id"], name: "index_comments_on_person_id"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["guid"], name: "index_comments_on_guid", unique: true
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sharing", default: false, null: false
    t.boolean "receiving", default: false, null: false
    t.index ["person_id"], name: "index_contacts_on_person_id"
    t.index ["user_id", "person_id"], name: "index_contacts_on_user_id_and_person_id", unique: true
  end

  create_table "conversation_visibilities", id: :serial, force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "person_id", null: false
    t.integer "unread", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "person_id"], name: "index_conversation_visibilities_usefully", unique: true
    t.index ["conversation_id"], name: "index_conversation_visibilities_on_conversation_id"
    t.index ["person_id"], name: "index_conversation_visibilities_on_person_id"
  end

  create_table "conversations", id: :serial, force: :cascade do |t|
    t.string "subject"
    t.string "guid", null: false
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "conversations_author_id_fk"
    t.index ["guid"], name: "index_conversations_on_guid", unique: true
  end

  create_table "invitation_codes", id: :serial, force: :cascade do |t|
    t.string "token"
    t.integer "user_id"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "like_signatures", id: false, force: :cascade do |t|
    t.integer "like_id", null: false
    t.text "author_signature", null: false
    t.integer "signature_order_id", null: false
    t.text "additional_data"
    t.index ["like_id"], name: "index_like_signatures_on_like_id", unique: true
  end

  create_table "likes", id: :serial, force: :cascade do |t|
    t.boolean "positive", default: true
    t.integer "target_id"
    t.integer "author_id"
    t.string "guid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "target_type", limit: 60, null: false
    t.index ["author_id"], name: "likes_author_id_fk"
    t.index ["guid"], name: "index_likes_on_guid", unique: true
    t.index ["target_id", "author_id", "target_type"], name: "index_likes_on_target_id_and_author_id_and_target_type", unique: true
    t.index ["target_id"], name: "index_likes_on_post_id"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "address"
    t.string "lat"
    t.string "lng"
    t.integer "status_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status_message_id"], name: "index_locations_on_status_message_id"
  end

  create_table "mentions", id: :serial, force: :cascade do |t|
    t.integer "mentions_container_id", null: false
    t.integer "person_id", null: false
    t.string "mentions_container_type", null: false
    t.index ["mentions_container_id", "mentions_container_type"], name: "index_mentions_on_mc_id_and_mc_type"
    t.index ["person_id", "mentions_container_id", "mentions_container_type"], name: "index_mentions_on_person_and_mc_id_and_mc_type", unique: true
    t.index ["person_id"], name: "index_mentions_on_person_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "author_id", null: false
    t.string "guid", null: false
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_messages_on_author_id"
    t.index ["conversation_id"], name: "messages_conversation_id_fk"
    t.index ["guid"], name: "index_messages_on_guid", unique: true
  end

  create_table "notification_actors", id: :serial, force: :cascade do |t|
    t.integer "notification_id"
    t.integer "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id", "person_id"], name: "index_notification_actors_on_notification_id_and_person_id", unique: true
    t.index ["notification_id"], name: "index_notification_actors_on_notification_id"
    t.index ["person_id"], name: "index_notification_actors_on_person_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "target_type"
    t.integer "target_id"
    t.integer "recipient_id", null: false
    t.boolean "unread", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["target_id"], name: "index_notifications_on_target_id"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id"
  end

  create_table "o_auth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "authorization_id"
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_id"], name: "index_o_auth_access_tokens_on_authorization_id"
    t.index ["token"], name: "index_o_auth_access_tokens_on_token", unique: true
  end

  create_table "o_auth_applications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "client_id"
    t.string "client_secret"
    t.string "client_name"
    t.text "redirect_uris"
    t.string "response_types"
    t.string "grant_types"
    t.string "application_type", default: "web"
    t.string "contacts"
    t.string "logo_uri"
    t.string "client_uri"
    t.string "policy_uri"
    t.string "tos_uri"
    t.string "sector_identifier_uri"
    t.string "token_endpoint_auth_method"
    t.text "jwks"
    t.string "jwks_uri"
    t.boolean "ppid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_o_auth_applications_on_client_id", unique: true
    t.index ["user_id"], name: "index_o_auth_applications_on_user_id"
  end

  create_table "o_embed_caches", id: :serial, force: :cascade do |t|
    t.string "url", limit: 1024, null: false
    t.text "data", null: false
    t.index ["url"], name: "index_o_embed_caches_on_url"
  end

  create_table "open_graph_caches", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "ob_type"
    t.text "image"
    t.text "url"
    t.text "description"
    t.text "video_url"
  end

  create_table "participations", id: :serial, force: :cascade do |t|
    t.string "guid"
    t.integer "target_id"
    t.string "target_type", limit: 60, null: false
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "count", default: 1, null: false
    t.index ["author_id"], name: "index_participations_on_author_id"
    t.index ["guid"], name: "index_participations_on_guid"
    t.index ["target_id", "target_type", "author_id"], name: "index_participations_on_target_id_and_target_type_and_author_id", unique: true
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "guid", null: false
    t.string "diaspora_handle", null: false
    t.text "serialized_public_key", null: false
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "closed_account", default: false
    t.integer "fetch_status", default: 0
    t.integer "pod_id"
    t.index ["diaspora_handle"], name: "index_people_on_diaspora_handle", unique: true
    t.index ["guid"], name: "index_people_on_guid", unique: true
    t.index ["owner_id"], name: "index_people_on_owner_id", unique: true
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.integer "author_id", null: false
    t.boolean "public", default: false, null: false
    t.string "guid", null: false
    t.boolean "pending", default: false, null: false
    t.text "text"
    t.text "remote_photo_path"
    t.string "remote_photo_name"
    t.string "random_string"
    t.string "processed_image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "unprocessed_image"
    t.string "status_message_guid"
    t.integer "comments_count"
    t.integer "height"
    t.integer "width"
    t.index ["author_id"], name: "index_photos_on_author_id"
    t.index ["guid"], name: "index_photos_on_guid", unique: true
    t.index ["status_message_guid"], name: "index_photos_on_status_message_guid"
  end

  create_table "pods", id: :serial, force: :cascade do |t|
    t.string "host", null: false
    t.boolean "ssl"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.datetime "checked_at", default: "1970-01-01 00:00:00"
    t.datetime "offline_since"
    t.integer "response_time", default: -1
    t.string "software"
    t.string "error"
    t.integer "port"
    t.boolean "blocked", default: false
    t.boolean "scheduled_check", default: false, null: false
    t.index ["checked_at"], name: "index_pods_on_checked_at"
    t.index ["host", "port"], name: "index_pods_on_host_and_port", unique: true
    t.index ["offline_since"], name: "index_pods_on_offline_since"
    t.index ["status"], name: "index_pods_on_status"
  end

  create_table "poll_answers", id: :serial, force: :cascade do |t|
    t.string "answer", null: false
    t.integer "poll_id", null: false
    t.string "guid"
    t.integer "vote_count", default: 0
    t.index ["guid"], name: "index_poll_answers_on_guid", unique: true
    t.index ["poll_id"], name: "index_poll_answers_on_poll_id"
  end

  create_table "poll_participation_signatures", id: false, force: :cascade do |t|
    t.integer "poll_participation_id", null: false
    t.text "author_signature", null: false
    t.integer "signature_order_id", null: false
    t.text "additional_data"
    t.index ["poll_participation_id"], name: "index_poll_participation_signatures_on_poll_participation_id", unique: true
  end

  create_table "poll_participations", id: :serial, force: :cascade do |t|
    t.integer "poll_answer_id", null: false
    t.integer "author_id", null: false
    t.integer "poll_id", null: false
    t.string "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["guid"], name: "index_poll_participations_on_guid", unique: true
    t.index ["poll_id", "author_id"], name: "index_poll_participations_on_poll_id_and_author_id", unique: true
  end

  create_table "polls", id: :serial, force: :cascade do |t|
    t.string "question", null: false
    t.integer "status_message_id", null: false
    t.boolean "status"
    t.string "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["guid"], name: "index_polls_on_guid", unique: true
    t.index ["status_message_id"], name: "index_polls_on_status_message_id"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.integer "author_id", null: false
    t.boolean "public", default: false, null: false
    t.string "guid", null: false
    t.string "type", limit: 40, null: false
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider_display_name"
    t.string "root_guid"
    t.integer "likes_count", default: 0
    t.integer "comments_count", default: 0
    t.integer "o_embed_cache_id"
    t.integer "reshares_count", default: 0
    t.datetime "interacted_at"
    t.string "tweet_id"
    t.integer "open_graph_cache_id"
    t.text "tumblr_ids"
    t.index ["author_id", "root_guid"], name: "index_posts_on_author_id_and_root_guid", unique: true
    t.index ["author_id"], name: "index_posts_on_person_id"
    t.index ["created_at", "id"], name: "index_posts_on_created_at_and_id"
    t.index ["guid"], name: "index_posts_on_guid", unique: true
    t.index ["id", "type"], name: "index_posts_on_id_and_type"
    t.index ["root_guid"], name: "index_posts_on_root_guid"
  end

  create_table "ppid", id: :serial, force: :cascade do |t|
    t.integer "o_auth_application_id"
    t.integer "user_id"
    t.string "guid", limit: 32
    t.string "identifier"
    t.index ["o_auth_application_id"], name: "index_ppid_on_o_auth_application_id"
    t.index ["user_id"], name: "index_ppid_on_user_id"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.string "diaspora_handle"
    t.string "first_name", limit: 127
    t.string "last_name", limit: 127
    t.string "image_url"
    t.string "image_url_small"
    t.string "image_url_medium"
    t.date "birthday"
    t.string "gender"
    t.text "bio"
    t.boolean "searchable", default: true, null: false
    t.integer "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.string "full_name", limit: 70
    t.boolean "nsfw", default: false
    t.boolean "public_details", default: false
    t.index ["full_name", "searchable"], name: "index_profiles_on_full_name_and_searchable"
    t.index ["full_name"], name: "index_profiles_on_full_name"
    t.index ["person_id"], name: "index_profiles_on_person_id"
  end

  create_table "references", force: :cascade do |t|
    t.integer "source_id", null: false
    t.string "source_type", limit: 60, null: false
    t.integer "target_id", null: false
    t.string "target_type", limit: 60, null: false
    t.index ["source_id", "source_type", "target_id", "target_type"], name: "index_references_on_source_and_target", unique: true
    t.index ["source_id", "source_type"], name: "index_references_on_source_id_and_source_type"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.boolean "reviewed", default: false
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id", null: false
    t.index ["item_id"], name: "index_reports_on_item_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id", "name"], name: "index_roles_on_person_id_and_name", unique: true
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.string "type", limit: 127, null: false
    t.integer "user_id", null: false
    t.string "uid", limit: 127
    t.string "access_token"
    t.string "access_secret"
    t.string "nickname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type", "uid"], name: "index_services_on_type_and_uid"
    t.index ["user_id"], name: "index_services_on_user_id"
  end

  create_table "share_visibilities", id: :serial, force: :cascade do |t|
    t.integer "shareable_id", null: false
    t.boolean "hidden", default: false, null: false
    t.string "shareable_type", limit: 60, default: "Post", null: false
    t.integer "user_id", null: false
    t.index ["shareable_id", "shareable_type", "hidden", "user_id"], name: "shareable_and_hidden_and_user_id"
    t.index ["shareable_id", "shareable_type", "user_id"], name: "shareable_and_user_id", unique: true
    t.index ["shareable_id"], name: "index_post_visibilities_on_post_id"
    t.index ["user_id"], name: "index_share_visibilities_on_user_id"
  end

  create_table "signature_orders", id: :serial, force: :cascade do |t|
    t.string "order", null: false
    t.index ["order"], name: "index_signature_orders_on_order", unique: true
  end

  create_table "simple_captcha_data", id: :serial, force: :cascade do |t|
    t.string "key", limit: 40
    t.string "value", limit: 12
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "idx_key"
  end

  create_table "tag_followings", id: :serial, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "user_id"], name: "index_tag_followings_on_tag_id_and_user_id", unique: true
    t.index ["tag_id"], name: "index_tag_followings_on_tag_id"
    t.index ["user_id"], name: "index_tag_followings_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type", limit: 127
    t.integer "tagger_id"
    t.string "tagger_type", limit: 127
    t.string "context", limit: 127
    t.datetime "created_at"
    t.index ["created_at"], name: "index_taggings_on_created_at"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tag_id"], name: "index_taggings_uniquely", unique: true
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_preferences", id: :serial, force: :cascade do |t|
    t.string "email_type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "email_type"], name: "index_user_preferences_on_user_id_and_email_type"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", null: false
    t.text "serialized_private_key"
    t.boolean "getting_started", default: true, null: false
    t.boolean "disable_mail", default: false, null: false
    t.string "language"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invited_by_id"
    t.string "authentication_token", limit: 30
    t.string "unconfirmed_email"
    t.string "confirm_email_token", limit: 30
    t.datetime "locked_at"
    t.boolean "show_community_spotlight_in_stream", default: true, null: false
    t.boolean "auto_follow_back", default: false
    t.integer "auto_follow_back_aspect_id"
    t.text "hidden_shareables"
    t.datetime "reset_password_sent_at"
    t.datetime "last_seen"
    t.datetime "remove_after"
    t.string "export"
    t.datetime "exported_at"
    t.boolean "exporting", default: false
    t.boolean "strip_exif", default: true
    t.string "exported_photos_file"
    t.datetime "exported_photos_at"
    t.boolean "exporting_photos", default: false
    t.string "color_theme"
    t.boolean "post_default_public", default: false
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.text "otp_backup_codes"
    t.string "plain_otp_secret"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "account_migrations", "people", column: "new_person_id"
  add_foreign_key "account_migrations", "people", column: "old_person_id"
  add_foreign_key "aspect_memberships", "aspects", name: "aspect_memberships_aspect_id_fk", on_delete: :cascade
  add_foreign_key "aspect_memberships", "contacts", name: "aspect_memberships_contact_id_fk", on_delete: :cascade
  add_foreign_key "aspect_visibilities", "aspects", name: "aspect_visibilities_aspect_id_fk", on_delete: :cascade
  add_foreign_key "authorizations", "o_auth_applications"
  add_foreign_key "authorizations", "users"
  add_foreign_key "comment_signatures", "comments", name: "comment_signatures_comment_id_fk", on_delete: :cascade
  add_foreign_key "comment_signatures", "signature_orders", name: "comment_signatures_signature_orders_id_fk"
  add_foreign_key "comments", "people", column: "author_id", name: "comments_author_id_fk", on_delete: :cascade
  add_foreign_key "contacts", "people", name: "contacts_person_id_fk", on_delete: :cascade
  add_foreign_key "conversation_visibilities", "conversations", name: "conversation_visibilities_conversation_id_fk", on_delete: :cascade
  add_foreign_key "conversation_visibilities", "people", name: "conversation_visibilities_person_id_fk", on_delete: :cascade
  add_foreign_key "conversations", "people", column: "author_id", name: "conversations_author_id_fk", on_delete: :cascade
  add_foreign_key "like_signatures", "likes", name: "like_signatures_like_id_fk", on_delete: :cascade
  add_foreign_key "like_signatures", "signature_orders", name: "like_signatures_signature_orders_id_fk"
  add_foreign_key "likes", "people", column: "author_id", name: "likes_author_id_fk", on_delete: :cascade
  add_foreign_key "messages", "conversations", name: "messages_conversation_id_fk", on_delete: :cascade
  add_foreign_key "messages", "people", column: "author_id", name: "messages_author_id_fk", on_delete: :cascade
  add_foreign_key "notification_actors", "notifications", name: "notification_actors_notification_id_fk", on_delete: :cascade
  add_foreign_key "o_auth_access_tokens", "authorizations"
  add_foreign_key "o_auth_applications", "users"
  add_foreign_key "people", "pods", name: "people_pod_id_fk", on_delete: :cascade
  add_foreign_key "poll_participation_signatures", "poll_participations", name: "poll_participation_signatures_poll_participation_id_fk", on_delete: :cascade
  add_foreign_key "poll_participation_signatures", "signature_orders", name: "poll_participation_signatures_signature_orders_id_fk"
  add_foreign_key "posts", "people", column: "author_id", name: "posts_author_id_fk", on_delete: :cascade
  add_foreign_key "ppid", "o_auth_applications"
  add_foreign_key "ppid", "users"
  add_foreign_key "profiles", "people", name: "profiles_person_id_fk", on_delete: :cascade
  add_foreign_key "services", "users", name: "services_user_id_fk", on_delete: :cascade
  add_foreign_key "share_visibilities", "users", name: "share_visibilities_user_id_fk", on_delete: :cascade
end
