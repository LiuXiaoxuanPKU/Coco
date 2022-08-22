CREATE TABLE account_aliases (
    id bigint NOT NULL,
    account_id bigint,
    acct character varying    NOT NULL,
    uri character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE account_conversations (
    id bigint NOT NULL,
    account_id bigint,
    conversation_id bigint,
    participant_account_ids bigint[]   NOT NULL,
    status_ids bigint[]   NOT NULL,
    last_status_id bigint,
    lock_version integer   NOT NULL,
    unread boolean   NOT NULL
);

CREATE TABLE account_deletion_requests (
    id bigint NOT NULL,
    account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE account_domain_blocks (
    id bigint NOT NULL,
    domain character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint
);

CREATE TABLE account_migrations (
    id bigint NOT NULL,
    account_id bigint,
    acct character varying    NOT NULL,
    followers_count bigint   NOT NULL,
    target_account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE account_moderation_notes (
    id bigint NOT NULL,
    content character varying(255) NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE account_notes (
    id bigint NOT NULL,
    account_id bigint,
    target_account_id bigint,
    comment character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE account_pins (
    id bigint NOT NULL,
    account_id bigint,
    target_account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE account_stats (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    statuses_count bigint   NOT NULL,
    following_count bigint   NOT NULL,
    followers_count bigint   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_status_at timestamp without time zone
);

CREATE TABLE account_statuses_cleanup_policies (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    enabled boolean   NOT NULL,
    min_status_age integer   NOT NULL,
    keep_direct boolean   NOT NULL,
    keep_pinned boolean   NOT NULL,
    keep_polls boolean   NOT NULL,
    keep_media boolean   NOT NULL,
    keep_self_fav boolean   NOT NULL,
    keep_self_bookmark boolean   NOT NULL,
    min_favs integer,
    min_reblogs integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE accounts (
    id bigint   NOT NULL,
    username character varying    NOT NULL,
    domain character varying,
    private_key character varying(255),
    public_key character varying(255)   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    note character varying(255)   NOT NULL,
    display_name character varying    NOT NULL,
    uri character varying    NOT NULL,
    url character varying,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    header_file_name character varying,
    header_content_type character varying,
    header_file_size integer,
    header_updated_at timestamp without time zone,
    avatar_remote_url character varying,
    locked boolean   NOT NULL,
    header_remote_url character varying    NOT NULL,
    last_webfingered_at timestamp without time zone,
    inbox_url character varying    NOT NULL,
    outbox_url character varying    NOT NULL,
    shared_inbox_url character varying    NOT NULL,
    followers_url character varying    NOT NULL,
    protocol integer   NOT NULL,
    memorial boolean   NOT NULL,
    moved_to_account_id bigint,
    featured_collection_url character varying,
    fields jsonb,
    actor_type character varying,
    discoverable boolean,
    also_known_as character varying[],
    silenced_at timestamp without time zone,
    suspended_at timestamp without time zone,
    hide_collections boolean,
    avatar_storage_schema_version integer,
    header_storage_schema_version integer,
    devices_url character varying,
    suspension_origin integer,
    sensitized_at timestamp without time zone,
    trendable boolean,
    reviewed_at timestamp without time zone,
    requested_review_at timestamp without time zone
);

CREATE TABLE statuses (
    id bigint   NOT NULL,
    uri character varying,
    character varying(255) text   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    in_reply_to_id bigint,
    reblog_of_id bigint,
    url character varying,
    sensitive boolean   NOT NULL,
    visibility integer   NOT NULL,
    spoiler_text character varying(255)   NOT NULL,
    reply boolean   NOT NULL,
    "language" character varying,
    conversation_id bigint,
    local boolean,
    account_id bigint NOT NULL,
    application_id bigint,
    in_reply_to_account_id bigint,
    poll_id bigint,
    deleted_at timestamp without time zone,
    edited_at timestamp without time zone,
    trendable boolean,
    ordered_media_attachment_ids bigint[]
);

CREATE TABLE account_warning_presets (
    id bigint NOT NULL,
    character varying(255) text   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying    NOT NULL
);

CREATE TABLE account_warnings (
    id bigint NOT NULL,
    account_id bigint,
    target_account_id bigint,
    action integer   NOT NULL,
    character varying(255) text   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    report_id bigint,
    status_ids character varying[],
    overruled_at timestamp without time zone
);

CREATE TABLE accounts_tags (
    account_id bigint NOT NULL,
    tag_id bigint NOT NULL
);

CREATE TABLE admin_action_logs (
    id bigint NOT NULL,
    account_id bigint,
    action character varying    NOT NULL,
    target_type character varying,
    target_id bigint,
    recorded_changes character varying(255)   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE announcement_mutes (
    id bigint NOT NULL,
    account_id bigint,
    announcement_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE announcement_reactions (
    id bigint NOT NULL,
    account_id bigint,
    announcement_id bigint,
    name character varying    NOT NULL,
    custom_emoji_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE announcements (
    id bigint NOT NULL,
    character varying(255) text   NOT NULL,
    published boolean   NOT NULL,
    all_day boolean   NOT NULL,
    scheduled_at timestamp without time zone,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    published_at timestamp without time zone,
    status_ids bigint[]
);

CREATE TABLE appeals (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    account_warning_id bigint NOT NULL,
    character varying(255) text   NOT NULL,
    approved_at timestamp without time zone,
    approved_by_account_id bigint,
    rejected_at timestamp without time zone,
    rejected_by_account_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    "value" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE backups (
    id bigint NOT NULL,
    user_id bigint,
    dump_file_name character varying,
    dump_content_type character varying,
    dump_updated_at timestamp without time zone,
    processed boolean   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dump_file_size bigint
);

CREATE TABLE blocks (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    uri character varying
);

CREATE TABLE bookmarks (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    status_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE canonical_email_blocks (
    id bigint NOT NULL,
    canonical_email_hash character varying    NOT NULL,
    reference_account_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE conversation_mutes (
    id bigint NOT NULL,
    conversation_id bigint NOT NULL,
    account_id bigint NOT NULL
);

CREATE TABLE conversations (
    id bigint NOT NULL,
    uri character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE custom_emoji_categories (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE custom_emojis (
    id bigint NOT NULL,
    shortcode character varying    NOT NULL,
    domain character varying,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    disabled boolean   NOT NULL,
    uri character varying,
    image_remote_url character varying,
    visible_in_picker boolean   NOT NULL,
    category_id bigint,
    image_storage_schema_version integer
);

CREATE TABLE custom_filters (
    id bigint NOT NULL,
    account_id bigint,
    expires_at timestamp without time zone,
    phrase character varying(255)   NOT NULL,
    context character varying[]   [] NOT NULL,
    irreversible boolean   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    whole_word boolean   NOT NULL
);

CREATE TABLE devices (
    id bigint NOT NULL,
    access_token_id bigint,
    account_id bigint,
    device_id character varying    NOT NULL,
    name character varying    NOT NULL,
    fingerprint_key character varying(255)   NOT NULL,
    identity_key character varying(255)   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE domain_allows (
    id bigint NOT NULL,
    domain character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE domain_blocks (
    id bigint NOT NULL,
    domain character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    severity integer  ,
    reject_media boolean   NOT NULL,
    reject_reports boolean   NOT NULL,
    private_comment character varying(255),
    public_comment character varying(255),
    obfuscate boolean   NOT NULL
);

CREATE TABLE email_domain_blocks (
    id bigint NOT NULL,
    domain character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id bigint
);

CREATE TABLE encrypted_messages (
    id bigint   NOT NULL,
    device_id bigint,
    from_account_id bigint,
    from_device_id character varying    NOT NULL,
    type integer   NOT NULL,
    body character varying(255)   NOT NULL,
    digest character varying(255)   NOT NULL,
    message_franking character varying(255)   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE favourites (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    status_id bigint NOT NULL
);

CREATE TABLE featured_tags (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    tag_id bigint NOT NULL,
    statuses_count bigint   NOT NULL,
    last_status_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE follow_recommendation_suppressions (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE follows (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    show_reblogs boolean   NOT NULL,
    uri character varying,
    notify boolean   NOT NULL
);

CREATE TABLE status_stats (
    id bigint NOT NULL,
    status_id bigint NOT NULL,
    replies_count bigint   NOT NULL,
    reblogs_count bigint   NOT NULL,
    favourites_count bigint   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE users (
    id bigint NOT NULL,
    email character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_password character varying    NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    sign_in_count integer   NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    admin boolean   NOT NULL,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    locale character varying,
    encrypted_otp_secret character varying,
    encrypted_otp_secret_iv character varying,
    encrypted_otp_secret_salt character varying,
    consumed_timestep integer,
    otp_required_for_login boolean   NOT NULL,
    last_emailed_at timestamp without time zone,
    otp_backup_codes character varying[],
    filtered_languages character varying[]   [] NOT NULL,
    account_id bigint NOT NULL,
    disabled boolean   NOT NULL,
    moderator boolean   NOT NULL,
    invite_id bigint,
    chosen_languages character varying[],
    created_by_application_id bigint,
    approved boolean   NOT NULL,
    sign_in_token character varying,
    sign_in_token_sent_at timestamp without time zone,
    webauthn_id character varying,
    sign_up_ip inet,
    skip_sign_in_token boolean
);

CREATE TABLE follow_requests (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    show_reblogs boolean   NOT NULL,
    uri character varying,
    notify boolean   NOT NULL
);

CREATE TABLE identities (
    id bigint NOT NULL,
    provider character varying    NOT NULL,
    uid character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE imports (
    id bigint NOT NULL,
    type integer NOT NULL,
    approved boolean   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying,
    data_content_type character varying,
    data_file_size integer,
    data_updated_at timestamp without time zone,
    account_id bigint NOT NULL,
    overwrite boolean   NOT NULL
);

CREATE TABLE invites (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    code character varying    NOT NULL,
    expires_at timestamp without time zone,
    max_uses integer,
    uses integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    autofollow boolean   NOT NULL,
    comment character varying(255)
);

CREATE TABLE ip_blocks (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    ip inet   NOT NULL,
    severity integer   NOT NULL,
    comment character varying(255)   NOT NULL
);

CREATE TABLE list_accounts (
    id bigint NOT NULL,
    list_id bigint NOT NULL,
    account_id bigint NOT NULL,
    follow_id bigint
);

CREATE TABLE lists (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    title character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    replies_policy integer   NOT NULL
);

CREATE TABLE login_activities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    authentication_method character varying,
    provider character varying,
    success boolean,
    failure_reason character varying,
    ip inet,
    user_agent character varying,
    created_at timestamp without time zone
);

CREATE TABLE markers (
    id bigint NOT NULL,
    user_id bigint,
    timeline character varying    NOT NULL,
    last_read_id bigint   NOT NULL,
    lock_version integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE media_attachments (
    id bigint   NOT NULL,
    status_id bigint,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    remote_url character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    shortcode character varying,
    type integer   NOT NULL,
    file_meta json,
    account_id bigint,
    description character varying(255),
    scheduled_status_id bigint,
    blurhash character varying,
    processing integer,
    file_storage_schema_version integer,
    thumbnail_file_name character varying,
    thumbnail_content_type character varying,
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    thumbnail_remote_url character varying
);

CREATE TABLE mentions (
    id bigint NOT NULL,
    status_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint,
    silent boolean   NOT NULL
);

CREATE TABLE mutes (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hide_notifications boolean   NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    expires_at timestamp without time zone
);

CREATE TABLE notifications (
    id bigint NOT NULL,
    activity_id bigint NOT NULL,
    activity_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    from_account_id bigint NOT NULL,
    type character varying
);

CREATE TABLE oauth_access_grants (
    id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying,
    application_id bigint NOT NULL,
    resource_owner_id bigint NOT NULL
);

CREATE TABLE oauth_access_tokens (
    id bigint NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    application_id bigint,
    resource_owner_id bigint,
    last_used_at timestamp without time zone,
    last_used_ip inet
);

CREATE TABLE oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri character varying(255) NOT NULL,
    scopes character varying    NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    superapp boolean   NOT NULL,
    website character varying,
    owner_type character varying,
    owner_id bigint,
    confidential boolean   NOT NULL
);

CREATE TABLE one_time_keys (
    id bigint NOT NULL,
    device_id bigint,
    key_id character varying    NOT NULL,
    key character varying(255)   NOT NULL,
    signature character varying(255)   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE pghero_space_stats (
    id bigint NOT NULL,
    database character varying(255),
    schema character varying(255),
    relation character varying(255),
    size bigint,
    captured_at timestamp without time zone
);

CREATE TABLE poll_votes (
    id bigint NOT NULL,
    account_id bigint,
    poll_id bigint,
    choice integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    uri character varying
);

CREATE TABLE polls (
    id bigint NOT NULL,
    account_id bigint,
    status_id bigint,
    expires_at timestamp without time zone,
    options character varying[]   [] NOT NULL,
    cached_tallies bigint[]   NOT NULL,
    multiple boolean   NOT NULL,
    hide_totals boolean   NOT NULL,
    votes_count bigint   NOT NULL,
    last_fetched_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lock_version integer   NOT NULL,
    voters_count bigint
);

CREATE TABLE preview_card_providers (
    id bigint NOT NULL,
    domain character varying    NOT NULL,
    icon_file_name character varying,
    icon_content_type character varying,
    icon_file_size bigint,
    icon_updated_at timestamp without time zone,
    trendable boolean,
    reviewed_at timestamp without time zone,
    requested_review_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE preview_cards (
    id bigint NOT NULL,
    url character varying    NOT NULL,
    title character varying    NOT NULL,
    description character varying    NOT NULL,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    type integer   NOT NULL,
    html character varying(255)   NOT NULL,
    author_name character varying    NOT NULL,
    author_url character varying    NOT NULL,
    provider_name character varying    NOT NULL,
    provider_url character varying    NOT NULL,
    width integer   NOT NULL,
    height integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    embed_url character varying    NOT NULL,
    image_storage_schema_version integer,
    blurhash character varying,
    "language" character varying,
    max_score double precision,
    max_score_at timestamp without time zone,
    trendable boolean,
    link_type integer
);

CREATE TABLE preview_cards_statuses (
    preview_card_id bigint NOT NULL,
    status_id bigint NOT NULL
);

CREATE TABLE relays (
    id bigint NOT NULL,
    inbox_url character varying    NOT NULL,
    follow_activity_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer   NOT NULL
);

CREATE TABLE report_notes (
    id bigint NOT NULL,
    content character varying(255) NOT NULL,
    report_id bigint NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE reports (
    id bigint NOT NULL,
    status_ids bigint[]   NOT NULL,
    comment character varying(255)   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    action_taken_by_account_id bigint,
    target_account_id bigint NOT NULL,
    assigned_account_id bigint,
    uri character varying,
    forwarded boolean,
    category integer   NOT NULL,
    action_taken_at timestamp without time zone,
    rule_ids bigint[]
);

CREATE TABLE rules (
    id bigint NOT NULL,
    priority integer   NOT NULL,
    deleted_at timestamp without time zone,
    character varying(255) text   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE scheduled_statuses (
    id bigint NOT NULL,
    account_id bigint,
    scheduled_at timestamp without time zone,
    params jsonb
);

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

CREATE TABLE session_activations (
    id bigint NOT NULL,
    session_id character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_agent character varying    NOT NULL,
    ip inet,
    access_token_id bigint,
    user_id bigint NOT NULL,
    web_push_subscription_id bigint
);

CREATE TABLE settings (
    id bigint NOT NULL,
    var character varying NOT NULL,
    "value" character varying(255),
    thing_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    thing_id bigint
);

CREATE TABLE site_uploads (
    id bigint NOT NULL,
    var character varying    NOT NULL,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    meta json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE status_edits (
    id bigint NOT NULL,
    status_id bigint NOT NULL,
    account_id bigint,
    character varying(255) text   NOT NULL,
    spoiler_text character varying(255)   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ordered_media_attachment_ids bigint[],
    media_descriptions text[],
    poll_options character varying[],
    sensitive boolean
);

CREATE TABLE status_pins (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    status_id bigint NOT NULL,
    created_at timestamp without time zone   NOT NULL,
    updated_at timestamp without time zone   NOT NULL
);

CREATE TABLE statuses_tags (
    status_id bigint NOT NULL,
    tag_id bigint NOT NULL
);

CREATE TABLE system_keys (
    id bigint NOT NULL,
    key binary(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE tags (
    id bigint NOT NULL,
    name character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    usable boolean,
    trendable boolean,
    listable boolean,
    reviewed_at timestamp without time zone,
    requested_review_at timestamp without time zone,
    last_status_at timestamp without time zone,
    max_score double precision,
    max_score_at timestamp without time zone
);

CREATE TABLE tombstones (
    id bigint NOT NULL,
    account_id bigint,
    uri character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    by_moderator boolean
);

CREATE TABLE unavailable_domains (
    id bigint NOT NULL,
    domain character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE user_invite_requests (
    id bigint NOT NULL,
    user_id bigint,
    character varying(255) text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE web_push_subscriptions (
    id bigint NOT NULL,
    endpoint character varying NOT NULL,
    key_p256dh character varying NOT NULL,
    key_auth character varying NOT NULL,
    data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    access_token_id bigint,
    user_id bigint
);

CREATE TABLE web_settings (
    id bigint NOT NULL,
    data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE webauthn_credentials (
    id bigint NOT NULL,
    external_id character varying NOT NULL,
    public_key character varying NOT NULL,
    nickname character varying NOT NULL,
    sign_count bigint   NOT NULL,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


-- Original Query
SELECT COALESCE(NULLIF(accounts.shared_inbox_url, ''), accounts.inbox_url) AS preferred_inbox_url FROM accounts INNER JOIN follows ON accounts.id = follows.account_id WHERE follows.target_account_id = 108847830090045132 AND accounts.protocol = 0 GROUP BY preferred_inbox_url;
-- Rewritten Queries
SELECT COALESCE(NULLIF(accounts.shared_inbox_url, ''), accounts.inbox_url) AS preferred_inbox_url FROM accounts INNER JOIN follows ON accounts.id = follows.account_id WHERE follows.target_account_id = 108847830090045132 AND accounts.protocol = 0 GROUP BY preferred_inbox_url LIMIT 1;
