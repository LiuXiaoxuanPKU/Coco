CREATE TABLE acls (
    id bigint NOT NULL,
    address character varying,
    k character varying NOT NULL,
    v character varying,
    domain character varying,
    mx character varying
);

CREATE TABLE active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);

CREATE TABLE active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata character varying(255),
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);

CREATE TABLE active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    "value" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE changeset_comments (
    id integer NOT NULL,
    changeset_id bigint NOT NULL,
    author_id bigint NOT NULL,
    body character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    visible boolean NOT NULL
);

CREATE TABLE changeset_tags (
    changeset_id bigint NOT NULL,
    k character varying    NOT NULL,
    v character varying    NOT NULL
);

CREATE TABLE changesets (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    min_lat integer,
    max_lat integer,
    min_lon integer,
    max_lon integer,
    closed_at timestamp without time zone NOT NULL,
    num_changes integer   NOT NULL
);

CREATE TABLE changesets_subscribers (
    subscriber_id bigint NOT NULL,
    changeset_id bigint NOT NULL
);

CREATE TABLE client_applications (
    id integer NOT NULL,
    name character varying,
    url character varying,
    support_url character varying,
    callback_url character varying,
    key character varying(50),
    secret character varying(50),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    allow_read_prefs boolean   NOT NULL,
    allow_write_prefs boolean   NOT NULL,
    allow_write_diary boolean   NOT NULL,
    allow_write_api boolean   NOT NULL,
    allow_read_gpx boolean   NOT NULL,
    allow_write_gpx boolean   NOT NULL,
    allow_write_notes boolean   NOT NULL
);

CREATE TABLE current_node_tags (
    node_id bigint NOT NULL,
    k character varying    NOT NULL,
    v character varying    NOT NULL
);

CREATE TABLE current_nodes (
    id bigint NOT NULL,
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    changeset_id bigint NOT NULL,
    visible boolean NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    tile bigint NOT NULL,
    version bigint NOT NULL
);

CREATE TABLE current_relation_members (
    relation_id bigint NOT NULL,
    member_id bigint NOT NULL,
    member_role character varying NOT NULL,
    sequence_id integer   NOT NULL
);

CREATE TABLE current_relation_tags (
    relation_id bigint NOT NULL,
    k character varying    NOT NULL,
    v character varying    NOT NULL
);

CREATE TABLE current_relations (
    id bigint NOT NULL,
    changeset_id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    visible boolean NOT NULL,
    version bigint NOT NULL
);

CREATE TABLE current_way_nodes (
    way_id bigint NOT NULL,
    node_id bigint NOT NULL,
    sequence_id bigint NOT NULL
);

CREATE TABLE current_way_tags (
    way_id bigint NOT NULL,
    k character varying    NOT NULL,
    v character varying    NOT NULL
);

CREATE TABLE current_ways (
    id bigint NOT NULL,
    changeset_id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    visible boolean NOT NULL,
    version bigint NOT NULL
);

CREATE TABLE delayed_jobs (
    id bigint NOT NULL,
    priority integer   NOT NULL,
    attempts integer   NOT NULL,
    handler character varying(255) NOT NULL,
    last_error character varying(255),
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE diary_comments (
    id bigint NOT NULL,
    diary_entry_id bigint NOT NULL,
    user_id bigint NOT NULL,
    body character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visible boolean   NOT NULL
);

CREATE TABLE diary_entries (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title character varying NOT NULL,
    body character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    latitude double precision,
    longitude double precision,
    language_code character varying    NOT NULL,
    visible boolean   NOT NULL
);

CREATE TABLE diary_entry_subscriptions (
    user_id bigint NOT NULL,
    diary_entry_id bigint NOT NULL
);

CREATE TABLE friends (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    friend_user_id bigint NOT NULL,
    created_at timestamp without time zone
);

CREATE TABLE gps_points (
    altitude double precision,
    trackid integer NOT NULL,
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    gpx_id bigint NOT NULL,
    "timestamp" timestamp without time zone,
    tile bigint
);

CREATE TABLE gpx_file_tags (
    gpx_id bigint NOT NULL,
    tag character varying NOT NULL,
    id bigint NOT NULL
);

CREATE TABLE gpx_files (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    visible boolean   NOT NULL,
    name character varying    NOT NULL,
    size bigint,
    latitude double precision,
    longitude double precision,
    "timestamp" timestamp without time zone NOT NULL,
    description character varying    NOT NULL,
    inserted boolean NOT NULL
);

CREATE TABLE issue_comments (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    user_id integer NOT NULL,
    body character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE issues (
    id integer NOT NULL,
    reportable_type character varying NOT NULL,
    reportable_id integer NOT NULL,
    reported_user_id integer,
    resolved_at timestamp without time zone,
    resolved_by integer,
    updated_by integer,
    reports_count integer  ,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE languages (
    code character varying NOT NULL,
    english_name character varying NOT NULL,
    native_name character varying
);

CREATE TABLE messages (
    id bigint NOT NULL,
    from_user_id bigint NOT NULL,
    title character varying NOT NULL,
    body character varying(255) NOT NULL,
    sent_on timestamp without time zone NOT NULL,
    message_read boolean   NOT NULL,
    to_user_id bigint NOT NULL,
    to_user_visible boolean   NOT NULL,
    from_user_visible boolean   NOT NULL,
    body_format public.format_character varying   NOT NULL
);

CREATE TABLE node_tags (
    node_id bigint NOT NULL,
    version bigint NOT NULL,
    k character varying    NOT NULL,
    v character varying    NOT NULL
);

CREATE TABLE nodes (
    node_id bigint NOT NULL,
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    changeset_id bigint NOT NULL,
    visible boolean NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    tile bigint NOT NULL,
    version bigint NOT NULL,
    redaction_id integer
);

CREATE TABLE note_comments (
    id bigint NOT NULL,
    note_id bigint NOT NULL,
    visible boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    author_ip character varying,
    author_id bigint,
    body character varying(255)
);

CREATE TABLE notes (
    id bigint NOT NULL,
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    tile bigint NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    closed_at timestamp without time zone
);

CREATE TABLE oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying    NOT NULL,
    code_challenge character varying,
    code_challenge_method character varying
);

CREATE TABLE oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id bigint,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying    NOT NULL
);

CREATE TABLE oauth_applications (
    id bigint NOT NULL,
    owner_type character varying NOT NULL,
    owner_id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri character varying(255) NOT NULL,
    scopes character varying    NOT NULL,
    confidential boolean   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE oauth_nonces (
    id bigint NOT NULL,
    nonce character varying,
    "timestamp" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE oauth_tokens (
    id integer NOT NULL,
    user_id integer,
    type character varying(20),
    client_application_id integer,
    token character varying(50),
    secret character varying(50),
    authorized_at timestamp without time zone,
    invalidated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    allow_read_prefs boolean   NOT NULL,
    allow_write_prefs boolean   NOT NULL,
    allow_write_diary boolean   NOT NULL,
    allow_write_api boolean   NOT NULL,
    allow_read_gpx boolean   NOT NULL,
    allow_write_gpx boolean   NOT NULL,
    callback_url character varying,
    verifier character varying(20),
    scope character varying,
    valid_to timestamp without time zone,
    allow_write_notes boolean   NOT NULL
);

CREATE TABLE redactions (
    id integer NOT NULL,
    title character varying,
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id bigint NOT NULL
);

CREATE TABLE relation_members (
    relation_id bigint NOT NULL,
    member_id bigint NOT NULL,
    member_role character varying NOT NULL,
    version bigint   NOT NULL,
    sequence_id integer   NOT NULL
);

CREATE TABLE relation_tags (
    relation_id bigint NOT NULL,
    k character varying    NOT NULL,
    v character varying    NOT NULL,
    version bigint NOT NULL
);

CREATE TABLE relations (
    relation_id bigint NOT NULL,
    changeset_id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    version bigint NOT NULL,
    visible boolean   NOT NULL,
    redaction_id integer
);

CREATE TABLE reports (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    user_id integer NOT NULL,
    details character varying(255) NOT NULL,
    category character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

CREATE TABLE user_blocks (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    creator_id bigint NOT NULL,
    reason character varying(255) NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    needs_view boolean   NOT NULL,
    revoker_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE user_preferences (
    user_id bigint NOT NULL,
    k character varying NOT NULL,
    v character varying NOT NULL
);

CREATE TABLE user_roles (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    granter_id bigint NOT NULL
);

CREATE TABLE user_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token character varying NOT NULL,
    expiry timestamp without time zone NOT NULL,
    referer character varying(255)
);

CREATE TABLE users (
    email character varying NOT NULL,
    id bigint NOT NULL,
    pass_crypt character varying NOT NULL,
    creation_time timestamp without time zone NOT NULL,
    display_name character varying    NOT NULL,
    data_public boolean   NOT NULL,
    description character varying(255)   NOT NULL,
    home_lat double precision,
    home_lon double precision,
    home_zoom smallint  ,
    pass_salt character varying,
    email_valid boolean   NOT NULL,
    new_email character varying,
    creation_ip character varying,
    languages character varying,
    terms_agreed timestamp without time zone,
    consider_pd boolean   NOT NULL,
    auth_uid character varying,
    preferred_editor character varying,
    terms_seen boolean   NOT NULL,
    changesets_count integer   NOT NULL,
    traces_count integer   NOT NULL,
    diary_entries_count integer   NOT NULL,
    image_use_gravatar boolean   NOT NULL,
    auth_provider character varying,
    home_tile bigint,
    tou_agreed timestamp without time zone
);

CREATE TABLE way_nodes (
    way_id bigint NOT NULL,
    node_id bigint NOT NULL,
    version bigint NOT NULL,
    sequence_id bigint NOT NULL
);

CREATE TABLE way_tags (
    way_id bigint NOT NULL,
    k character varying NOT NULL,
    v character varying NOT NULL,
    version bigint NOT NULL
);

CREATE TABLE ways (
    way_id bigint NOT NULL,
    changeset_id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    version bigint NOT NULL,
    visible boolean   NOT NULL,
    redaction_id integer
);


-- Original Query
SELECT notes.* FROM notes WHERE (notes.status = 'open' OR notes.status = 'open' AND notes.closed_at > '2022-08-22 21:22:00.274789') AND (notes.tile BETWEEN 3223290360 AND 3223290367 OR notes.tile BETWEEN 3223290704 AND 3223290719 OR notes.tile BETWEEN 3223290736 AND 3223290751 OR notes.tile BETWEEN 3223290832 AND 3223290847 OR notes.tile BETWEEN 3223290864 AND 3223290879 OR notes.tile BETWEEN 3223291048 AND 3223291055 OR notes.tile BETWEEN 3223291064 AND 3223291071 OR notes.tile BETWEEN 3223291112 AND 3223291119 OR notes.tile BETWEEN 3223291128 AND 3223291135 OR notes.tile BETWEEN 3223291304 AND 3223291311 OR notes.tile BETWEEN 3223291320 AND 3223291327 OR notes.tile BETWEEN 3223291368 AND 3223291375 OR notes.tile BETWEEN 3223291384 AND 3223291903 OR notes.tile BETWEEN 3223292240 AND 3223292241 OR notes.tile BETWEEN 3223292244 AND 3223292245 OR notes.tile BETWEEN 3223292928 AND 3223292929 OR notes.tile BETWEEN 3223292932 AND 3223292933 OR notes.tile BETWEEN 3223292944 AND 3223292945 OR notes.tile BETWEEN 3223292948 AND 3223292949 OR notes.tile BETWEEN 3223292992 AND 3223292993 OR notes.tile BETWEEN 3223292996 AND 3223292997 OR notes.tile BETWEEN 3223293008 AND 3223293009 OR notes.tile BETWEEN 3223293012 AND 3223293013 OR notes.tile BETWEEN 3223293184 AND 3223293185 OR notes.tile BETWEEN 3223293188 AND 3223293189 OR notes.tile BETWEEN 3223293200 AND 3223293201 OR notes.tile BETWEEN 3223293204 AND 3223293205 OR notes.tile BETWEEN 3223293248 AND 3223293249 OR notes.tile BETWEEN 3223293252 AND 3223293253 OR notes.tile BETWEEN 3223293264 AND 3223293265 OR notes.tile BETWEEN 3223293268 AND 3223293269 OR notes.tile IN (3223294120, 3223294122, 3223294464, 3223294466, 3223294472, 3223294474, 3223294496, 3223294498, 3223294504, 3223294506, 3223294592, 3223294594, 3223294600, 3223294602, 3223294624, 3223294626, 3223294632, 3223294634, 3223296000)) AND notes.latitude BETWEEN 50000000.0 AND 51000000.0 AND notes.longitude BETWEEN 50000000.0 AND 51000000.0 ORDER BY updated_at DESC LIMIT 5;
-- Rewritten Queries
SELECT notes.* FROM notes WHERE (notes.status = 'open' OR notes.status = 'open' AND notes.closed_at > '2022-08-22 21:22:00.274789') AND (notes.tile BETWEEN 3223290360 AND 3223290367 OR notes.tile BETWEEN 3223290704 AND 3223290719 OR notes.tile BETWEEN 3223290736 AND 3223290751 OR notes.tile BETWEEN 3223290832 AND 3223290847 OR notes.tile BETWEEN 3223290864 AND 3223290879 OR notes.tile BETWEEN 3223291048 AND 3223291055 OR notes.tile BETWEEN 3223291064 AND 3223291071 OR notes.tile BETWEEN 3223291112 AND 3223291119 OR notes.tile BETWEEN 3223291128 AND 3223291135 OR notes.tile BETWEEN 3223291304 AND 3223291311 OR notes.tile BETWEEN 3223291320 AND 3223291327 OR notes.tile BETWEEN 3223291368 AND 3223291375 OR notes.tile BETWEEN 3223291384 AND 3223291903 OR notes.tile BETWEEN 3223292240 AND 3223292241 OR notes.tile BETWEEN 3223292244 AND 3223292245 OR notes.tile BETWEEN 3223292928 AND 3223292929 OR notes.tile BETWEEN 3223292932 AND 3223292933 OR notes.tile BETWEEN 3223292944 AND 3223292945 OR notes.tile BETWEEN 3223292948 AND 3223292949 OR notes.tile BETWEEN 3223292992 AND 3223292993 OR notes.tile BETWEEN 3223292996 AND 3223292997 OR notes.tile BETWEEN 3223293008 AND 3223293009 OR notes.tile BETWEEN 3223293012 AND 3223293013 OR notes.tile BETWEEN 3223293184 AND 3223293185 OR notes.tile BETWEEN 3223293188 AND 3223293189 OR notes.tile BETWEEN 3223293200 AND 3223293201 OR notes.tile BETWEEN 3223293204 AND 3223293205 OR notes.tile BETWEEN 3223293248 AND 3223293249 OR notes.tile BETWEEN 3223293252 AND 3223293253 OR notes.tile BETWEEN 3223293264 AND 3223293265 OR notes.tile BETWEEN 3223293268 AND 3223293269 OR notes.tile IN (3223294120, 3223294122, 3223294464, 3223294466, 3223294472, 3223294474, 3223294496, 3223294498, 3223294504, 3223294506, 3223294592, 3223294594, 3223294600, 3223294602, 3223294624, 3223294626, 3223294632, 3223294634, 3223296000)) AND notes.latitude BETWEEN 50000000.0 AND 51000000.0 ORDER BY updated_at DESC LIMIT 5;
