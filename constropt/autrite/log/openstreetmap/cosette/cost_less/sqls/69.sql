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
SELECT current_nodes.* FROM current_nodes WHERE (current_nodes.tile BETWEEN 3221329994 AND 3221329995 OR current_nodes.tile BETWEEN 3221329998 AND 3221329999 OR current_nodes.tile BETWEEN 3221330010 AND 3221330011 OR current_nodes.tile BETWEEN 3221330014 AND 3221330047 OR current_nodes.tile BETWEEN 3221330111 AND 3221330175 OR current_nodes.tile BETWEEN 3221330186 AND 3221330187 OR current_nodes.tile BETWEEN 3221330190 AND 3221330191 OR current_nodes.tile BETWEEN 3221330202 AND 3221330203 OR current_nodes.tile BETWEEN 3221330206 AND 3221330239 OR current_nodes.tile BETWEEN 3221330250 AND 3221330251 OR current_nodes.tile BETWEEN 3221330254 AND 3221330255 OR current_nodes.tile BETWEEN 3221330266 AND 3221330267 OR current_nodes.tile BETWEEN 3221330270 AND 3221330431 OR current_nodes.tile BETWEEN 3221330495 AND 3221330559 OR current_nodes.tile BETWEEN 3221330623 AND 3221330943 OR current_nodes.tile BETWEEN 3221330954 AND 3221330955 OR current_nodes.tile BETWEEN 3221330958 AND 3221330959 OR current_nodes.tile BETWEEN 3221330970 AND 3221330971 OR current_nodes.tile BETWEEN 3221330974 AND 3221331007 OR current_nodes.tile BETWEEN 3221331018 AND 3221331019 OR current_nodes.tile BETWEEN 3221331022 AND 3221331023 OR current_nodes.tile BETWEEN 3221331034 AND 3221331035 OR current_nodes.tile BETWEEN 3221331038 AND 3221331199 OR current_nodes.tile BETWEEN 3221331210 AND 3221331211 OR current_nodes.tile BETWEEN 3221331214 AND 3221331215 OR current_nodes.tile BETWEEN 3221331226 AND 3221331227 OR current_nodes.tile BETWEEN 3221331230 AND 3221331263 OR current_nodes.tile BETWEEN 3221331274 AND 3221331275 OR current_nodes.tile BETWEEN 3221331278 AND 3221331279 OR current_nodes.tile BETWEEN 3221331290 AND 3221331291 OR current_nodes.tile BETWEEN 3221331294 AND 3221331967 OR current_nodes.tile BETWEEN 3221336127 AND 3221336191 OR current_nodes.tile BETWEEN 3221336256 AND 3221336257 OR current_nodes.tile BETWEEN 3221336260 AND 3221336261 OR current_nodes.tile BETWEEN 3221336272 AND 3221336273 OR current_nodes.tile BETWEEN 3221336276 AND 3221336277 OR current_nodes.tile BETWEEN 3221336320 AND 3221336449 OR current_nodes.tile BETWEEN 3221336452 AND 3221336453 OR current_nodes.tile BETWEEN 3221336464 AND 3221336465 OR current_nodes.tile BETWEEN 3221336468 AND 3221336469 OR current_nodes.tile BETWEEN 3221336512 AND 3221336513 OR current_nodes.tile BETWEEN 3221336516 AND 3221336517 OR current_nodes.tile BETWEEN 3221336528 AND 3221336529 OR current_nodes.tile BETWEEN 3221336532 AND 3221336533 OR current_nodes.tile BETWEEN 3221337088 AND 3221337217 OR current_nodes.tile BETWEEN 3221337220 AND 3221337221 OR current_nodes.tile BETWEEN 3221337232 AND 3221337233 OR current_nodes.tile BETWEEN 3221337236 AND 3221337237 OR current_nodes.tile BETWEEN 3221337280 AND 3221337281 OR current_nodes.tile BETWEEN 3221337284 AND 3221337285 OR current_nodes.tile BETWEEN 3221337296 AND 3221337297 OR current_nodes.tile BETWEEN 3221337300 AND 3221337301 OR current_nodes.tile BETWEEN 3221337344 AND 3221337473 OR current_nodes.tile BETWEEN 3221337476 AND 3221337477 OR current_nodes.tile BETWEEN 3221337488 AND 3221337489 OR current_nodes.tile BETWEEN 3221337492 AND 3221337493 OR current_nodes.tile BETWEEN 3221337536 AND 3221337537 OR current_nodes.tile BETWEEN 3221337540 AND 3221337541 OR current_nodes.tile BETWEEN 3221337552 AND 3221337553 OR current_nodes.tile BETWEEN 3221337556 AND 3221337557 OR current_nodes.tile BETWEEN 3221342218 AND 3221342219 OR current_nodes.tile BETWEEN 3221342222 AND 3221342223 OR current_nodes.tile BETWEEN 3221342234 AND 3221342235 OR current_nodes.tile BETWEEN 3221342238 AND 3221342271 OR current_nodes.tile BETWEEN 3221342282 AND 3221342283 OR current_nodes.tile BETWEEN 3221342286 AND 3221342287 OR current_nodes.tile BETWEEN 3221342298 AND 3221342299 OR current_nodes.tile BETWEEN 3221342302 AND 3221342463 OR current_nodes.tile BETWEEN 3221342720 AND 3221342976 OR current_nodes.tile BETWEEN 3221348352 AND 3221348481 OR current_nodes.tile BETWEEN 3221348484 AND 3221348485 OR current_nodes.tile BETWEEN 3221348496 AND 3221348497 OR current_nodes.tile BETWEEN 3221348500 AND 3221348501 OR current_nodes.tile BETWEEN 3221348544 AND 3221348545 OR current_nodes.tile BETWEEN 3221348548 AND 3221348549 OR current_nodes.tile BETWEEN 3221348560 AND 3221348561 OR current_nodes.tile BETWEEN 3221348564 AND 3221348565 OR current_nodes.tile IN (3221329951, 3221329973, 3221329975, 3221329981, 3221329983, 3221330069, 3221330071, 3221330077, 3221330079, 3221330101, 3221330103, 3221330109, 3221330453, 3221330455, 3221330461, 3221330463, 3221330485, 3221330487, 3221330493, 3221330581, 3221330583, 3221330589, 3221330591, 3221330613, 3221330615, 3221330621, 3221336085, 3221336087, 3221336093, 3221336095, 3221336117, 3221336119, 3221336125, 3221336213, 3221342474, 3221342496, 3221342498, 3221342504, 3221342506, 3221342592, 3221342594, 3221342600, 3221342602, 3221342624, 3221342626, 3221342632, 3221342634, 3221342978, 3221342984, 3221342986, 3221343008, 3221343010, 3221343016, 3221343018, 3221343104, 3221343106, 3221343112, 3221343114, 3221343136, 3221343138, 3221343144, 3221343146, 3221348608, 3221348610, 3221348616, 3221348618, 3221348640, 3221348642, 3221348648, 3221348650, 3221348736)) AND current_nodes.latitude BETWEEN 9000000.0 AND 11000000.0 AND current_nodes.longitude BETWEEN 9000000.0 AND 11000000.0 AND current_nodes.visible = False LIMIT 6;
-- Rewritten Queries
SELECT current_nodes.* FROM current_nodes WHERE (current_nodes.tile BETWEEN 3221329994 AND 3221329995 OR current_nodes.tile BETWEEN 3221329998 AND 3221329999 OR current_nodes.tile BETWEEN 3221330010 AND 3221330011 OR current_nodes.tile BETWEEN 3221330014 AND 3221330047 OR current_nodes.tile BETWEEN 3221330111 AND 3221330175 OR current_nodes.tile BETWEEN 3221330186 AND 3221330187 OR current_nodes.tile BETWEEN 3221330190 AND 3221330191 OR current_nodes.tile BETWEEN 3221330202 AND 3221330203 OR current_nodes.tile BETWEEN 3221330206 AND 3221330239 OR current_nodes.tile BETWEEN 3221330250 AND 3221330251 OR current_nodes.tile BETWEEN 3221330254 AND 3221330255 OR current_nodes.tile BETWEEN 3221330266 AND 3221330267 OR current_nodes.tile BETWEEN 3221330270 AND 3221330431 OR current_nodes.tile BETWEEN 3221330495 AND 3221330559 OR current_nodes.tile BETWEEN 3221330623 AND 3221330943 OR current_nodes.tile BETWEEN 3221330954 AND 3221330955 OR current_nodes.tile BETWEEN 3221330958 AND 3221330959 OR current_nodes.tile BETWEEN 3221330970 AND 3221330971 OR current_nodes.tile BETWEEN 3221330974 AND 3221331007 OR current_nodes.tile BETWEEN 3221331018 AND 3221331019 OR current_nodes.tile BETWEEN 3221331022 AND 3221331023 OR current_nodes.tile BETWEEN 3221331034 AND 3221331035 OR current_nodes.tile BETWEEN 3221331038 AND 3221331199 OR current_nodes.tile BETWEEN 3221331210 AND 3221331211 OR current_nodes.tile BETWEEN 3221331214 AND 3221331215 OR current_nodes.tile BETWEEN 3221331226 AND 3221331227 OR current_nodes.tile BETWEEN 3221331230 AND 3221331263 OR current_nodes.tile BETWEEN 3221331274 AND 3221331275 OR current_nodes.tile BETWEEN 3221331278 AND 3221331279 OR current_nodes.tile BETWEEN 3221331290 AND 3221331291 OR current_nodes.tile BETWEEN 3221331294 AND 3221331967 OR current_nodes.tile BETWEEN 3221336127 AND 3221336191 OR current_nodes.tile BETWEEN 3221336256 AND 3221336257 OR current_nodes.tile BETWEEN 3221336260 AND 3221336261 OR current_nodes.tile BETWEEN 3221336272 AND 3221336273 OR current_nodes.tile BETWEEN 3221336276 AND 3221336277 OR current_nodes.tile BETWEEN 3221336320 AND 3221336449 OR current_nodes.tile BETWEEN 3221336452 AND 3221336453 OR current_nodes.tile BETWEEN 3221336464 AND 3221336465 OR current_nodes.tile BETWEEN 3221336468 AND 3221336469 OR current_nodes.tile BETWEEN 3221336512 AND 3221336513 OR current_nodes.tile BETWEEN 3221336516 AND 3221336517 OR current_nodes.tile BETWEEN 3221336528 AND 3221336529 OR current_nodes.tile BETWEEN 3221336532 AND 3221336533 OR current_nodes.tile BETWEEN 3221337088 AND 3221337217 OR current_nodes.tile BETWEEN 3221337220 AND 3221337221 OR current_nodes.tile BETWEEN 3221337232 AND 3221337233 OR current_nodes.tile BETWEEN 3221337236 AND 3221337237 OR current_nodes.tile BETWEEN 3221337280 AND 3221337281 OR current_nodes.tile BETWEEN 3221337284 AND 3221337285 OR current_nodes.tile BETWEEN 3221337296 AND 3221337297 OR current_nodes.tile BETWEEN 3221337300 AND 3221337301 OR current_nodes.tile BETWEEN 3221337344 AND 3221337473 OR current_nodes.tile BETWEEN 3221337476 AND 3221337477 OR current_nodes.tile BETWEEN 3221337488 AND 3221337489 OR current_nodes.tile BETWEEN 3221337492 AND 3221337493 OR current_nodes.tile BETWEEN 3221337536 AND 3221337537 OR current_nodes.tile BETWEEN 3221337540 AND 3221337541 OR current_nodes.tile BETWEEN 3221337552 AND 3221337553 OR current_nodes.tile BETWEEN 3221337556 AND 3221337557 OR current_nodes.tile BETWEEN 3221342218 AND 3221342219 OR current_nodes.tile BETWEEN 3221342222 AND 3221342223 OR current_nodes.tile BETWEEN 3221342234 AND 3221342235 OR current_nodes.tile BETWEEN 3221342238 AND 3221342271 OR current_nodes.tile BETWEEN 3221342282 AND 3221342283 OR current_nodes.tile BETWEEN 3221342286 AND 3221342287 OR current_nodes.tile BETWEEN 3221342298 AND 3221342299 OR current_nodes.tile BETWEEN 3221342302 AND 3221342463 OR current_nodes.tile BETWEEN 3221342720 AND 3221342976 OR current_nodes.tile BETWEEN 3221348352 AND 3221348481 OR current_nodes.tile BETWEEN 3221348484 AND 3221348485 OR current_nodes.tile BETWEEN 3221348496 AND 3221348497 OR current_nodes.tile BETWEEN 3221348500 AND 3221348501 OR current_nodes.tile BETWEEN 3221348544 AND 3221348545 OR current_nodes.tile BETWEEN 3221348548 AND 3221348549 OR current_nodes.tile BETWEEN 3221348560 AND 3221348561 OR current_nodes.tile BETWEEN 3221348564 AND 3221348565 OR current_nodes.tile IN (3221329951, 3221329973, 3221329975, 3221329981, 3221329983, 3221330069, 3221330071, 3221330077, 3221330079, 3221330101, 3221330103, 3221330109, 3221330453, 3221330455, 3221330461, 3221330463, 3221330485, 3221330487, 3221330493, 3221330581, 3221330583, 3221330589, 3221330591, 3221330613, 3221330615, 3221330621, 3221336085, 3221336087, 3221336093, 3221336095, 3221336117, 3221336119, 3221336125, 3221336213, 3221342474, 3221342496, 3221342498, 3221342504, 3221342506, 3221342592, 3221342594, 3221342600, 3221342602, 3221342624, 3221342626, 3221342632, 3221342634, 3221342978, 3221342984, 3221342986, 3221343008, 3221343010, 3221343016, 3221343018, 3221343104, 3221343106, 3221343112, 3221343114, 3221343136, 3221343138, 3221343144, 3221343146, 3221348608, 3221348610, 3221348616, 3221348618, 3221348640, 3221348642, 3221348648, 3221348650, 3221348736)) AND current_nodes.latitude BETWEEN 9000000.0 AND 11000000.0 AND current_nodes.visible = False LIMIT 6;
