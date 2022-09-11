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
    "key" character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata character varying,
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
    "key" character varying NOT NULL,
    "value" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE changeset_comments (
    id integer NOT NULL,
    changeset_id bigint NOT NULL,
    author_id bigint NOT NULL,
    body character varying NOT NULL,
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
    "key" character varying(50),
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
    member_type character varying NOT NULL,
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
    handler character varying NOT NULL,
    last_error character varying,
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
    body character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visible boolean   NOT NULL,
    body_format character varying   NOT NULL
);

CREATE TABLE diary_entries (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title character varying NOT NULL,
    body character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    latitude double precision,
    longitude double precision,
    language_code character varying    NOT NULL,
    visible boolean   NOT NULL,
    body_format character varying   NOT NULL
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
    inserted boolean NOT NULL,
    visibility character varying   NOT NULL
);

CREATE TABLE issue_comments (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    user_id integer NOT NULL,
    body character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE issues (
    id integer NOT NULL,
    reportable_type character varying NOT NULL,
    reportable_id integer NOT NULL,
    reported_user_id integer,
    status character varying   NOT NULL,
    assigned_role character varying NOT NULL,
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
    body character varying NOT NULL,
    sent_on timestamp without time zone NOT NULL,
    message_read boolean   NOT NULL,
    to_user_id bigint NOT NULL,
    to_user_visible boolean   NOT NULL,
    from_user_visible boolean   NOT NULL,
    body_format character varying   NOT NULL
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
    body character varying,
    event character varying
);

CREATE TABLE notes (
    id bigint NOT NULL,
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    tile bigint NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    status character varying NOT NULL,
    closed_at timestamp without time zone
);

CREATE TABLE oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri character varying NOT NULL,
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
    redirect_uri character varying NOT NULL,
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
    "scope" character varying,
    valid_to timestamp without time zone,
    allow_write_notes boolean   NOT NULL
);

CREATE TABLE redactions (
    id integer NOT NULL,
    title character varying,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id bigint NOT NULL,
    description_format character varying   NOT NULL
);

CREATE TABLE relation_members (
    relation_id bigint NOT NULL,
    member_type character varying NOT NULL,
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
    details character varying NOT NULL,
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
    reason character varying NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    needs_view boolean   NOT NULL,
    revoker_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reason_format character varying   NOT NULL
);

CREATE TABLE user_preferences (
    user_id bigint NOT NULL,
    k character varying NOT NULL,
    v character varying NOT NULL
);

CREATE TABLE user_roles (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    "role" character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    granter_id bigint NOT NULL
);

CREATE TABLE user_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token character varying NOT NULL,
    expiry timestamp without time zone NOT NULL,
    referer character varying
);

CREATE TABLE users (
    email character varying NOT NULL,
    id bigint NOT NULL,
    pass_crypt character varying NOT NULL,
    creation_time timestamp without time zone NOT NULL,
    display_name character varying    NOT NULL,
    data_public boolean   NOT NULL,
    description character varying   NOT NULL,
    home_lat double precision,
    home_lon double precision,
    home_zoom smallint  ,
    pass_salt character varying,
    email_valid boolean   NOT NULL,
    new_email character varying,
    creation_ip character varying,
    languages character varying,
    status character varying   NOT NULL,
    terms_agreed timestamp without time zone,
    consider_pd boolean   NOT NULL,
    auth_uid character varying,
    preferred_editor character varying,
    terms_seen boolean   NOT NULL,
    description_format character varying   NOT NULL,
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
SELECT notes.* FROM notes WHERE (notes.status = 'open' OR notes.status = 'open' AND notes.closed_at > '2022-08-22 21:22:00.471344') AND (notes.tile BETWEEN 3221331576 AND 3221331583 OR notes.tile BETWEEN 3221331664 AND 3221331679 OR notes.tile BETWEEN 3221331696 AND 3221331711 OR notes.tile BETWEEN 3221331752 AND 3221331759 OR notes.tile BETWEEN 3221331768 AND 3221331775 OR notes.tile BETWEEN 3221331816 AND 3221331823 OR notes.tile BETWEEN 3221331832 AND 3221331967 OR notes.tile BETWEEN 3221337168 AND 3221337183 OR notes.tile BETWEEN 3221337200 AND 3221337215 OR notes.tile BETWEEN 3221337296 AND 3221337311 OR notes.tile BETWEEN 3221337328 AND 3221337599 OR notes.tile BETWEEN 3221337680 AND 3221337695 OR notes.tile BETWEEN 3221337712 AND 3221337727 OR notes.tile BETWEEN 3221337808 AND 3221337817 OR notes.tile BETWEEN 3221337820 AND 3221337821 OR notes.tile BETWEEN 3221337856 AND 3221337993 OR notes.tile BETWEEN 3221337996 AND 3221337997 OR notes.tile BETWEEN 3221338000 AND 3221338009 OR notes.tile BETWEEN 3221338012 AND 3221338013 OR notes.tile BETWEEN 3221338048 AND 3221338057 OR notes.tile BETWEEN 3221338060 AND 3221338061 OR notes.tile BETWEEN 3221338064 AND 3221338073 OR notes.tile BETWEEN 3221338076 AND 3221338077 OR notes.tile BETWEEN 3221342760 AND 3221342767 OR notes.tile BETWEEN 3221342776 AND 3221342783 OR notes.tile BETWEEN 3221342824 AND 3221342831 OR notes.tile BETWEEN 3221342840 AND 3221342975 OR notes.tile BETWEEN 3221343016 AND 3221343023 OR notes.tile BETWEEN 3221343032 AND 3221343039 OR notes.tile BETWEEN 3221343080 AND 3221343087 OR notes.tile BETWEEN 3221343096 AND 3221343231 OR notes.tile BETWEEN 3221343784 AND 3221343791 OR notes.tile BETWEEN 3221343800 AND 3221343807 OR notes.tile BETWEEN 3221343848 AND 3221343855 OR notes.tile BETWEEN 3221343864 AND 3221343999 OR notes.tile BETWEEN 3221344040 AND 3221344047 OR notes.tile BETWEEN 3221344128 AND 3221344144 OR notes.tile BETWEEN 3221344160 AND 3221344176 OR notes.tile BETWEEN 3221348352 AND 3221349001 OR notes.tile BETWEEN 3221349004 AND 3221349005 OR notes.tile BETWEEN 3221349008 AND 3221349017 OR notes.tile BETWEEN 3221349020 AND 3221349021 OR notes.tile BETWEEN 3221349056 AND 3221349065 OR notes.tile BETWEEN 3221349068 AND 3221349069 OR notes.tile BETWEEN 3221349072 AND 3221349081 OR notes.tile BETWEEN 3221349084 AND 3221349085 OR notes.tile BETWEEN 3221349120 AND 3221349257 OR notes.tile BETWEEN 3221349260 AND 3221349261 OR notes.tile BETWEEN 3221349264 AND 3221349273 OR notes.tile BETWEEN 3221349276 AND 3221349277 OR notes.tile BETWEEN 3221349312 AND 3221349321 OR notes.tile BETWEEN 3221349324 AND 3221349325 OR notes.tile BETWEEN 3221349328 AND 3221349337 OR notes.tile BETWEEN 3221349340 AND 3221349341 OR notes.tile BETWEEN 3221349376 AND 3221349648 OR notes.tile BETWEEN 3221349664 AND 3221349680 OR notes.tile BETWEEN 3221349760 AND 3221349776 OR notes.tile BETWEEN 3221349792 AND 3221349808 OR notes.tile BETWEEN 3221349888 AND 3221350025 OR notes.tile BETWEEN 3221350028 AND 3221350029 OR notes.tile BETWEEN 3221350032 AND 3221350041 OR notes.tile BETWEEN 3221350044 AND 3221350045 OR notes.tile BETWEEN 3221350080 AND 3221350089 OR notes.tile BETWEEN 3221350092 AND 3221350093 OR notes.tile BETWEEN 3221350096 AND 3221350105 OR notes.tile BETWEEN 3221350108 AND 3221350109 OR notes.tile BETWEEN 3221350144 AND 3221350160 OR notes.tile BETWEEN 3221350176 AND 3221350192 OR notes.tile BETWEEN 3221350272 AND 3221350281 OR notes.tile BETWEEN 3221350284 AND 3221350285 OR notes.tile IN (3221344056, 3221344058, 3221344146, 3221344152, 3221344154, 3221344178, 3221344184, 3221344186, 3221349650, 3221349656, 3221349658, 3221349682, 3221349688, 3221349690, 3221349778, 3221349784, 3221349786, 3221349810, 3221349816, 3221349818, 3221350162, 3221350168, 3221350170, 3221350194, 3221350200, 3221350202, 3221350288, 3221350290, 3221350296)) AND notes.latitude BETWEEN 10000000.0 AND 12000000.0 AND notes.longitude BETWEEN 10000000.0 AND 12000000.0 ORDER BY updated_at DESC LIMIT 2;
-- Rewritten Queries
SELECT notes.* FROM notes WHERE (notes.status = 'open' OR notes.status = 'open' AND notes.closed_at > '2022-08-22 21:22:00.471344') AND (notes.tile BETWEEN 3221331576 AND 3221331583 OR notes.tile BETWEEN 3221331664 AND 3221331679 OR notes.tile BETWEEN 3221331696 AND 3221331711 OR notes.tile BETWEEN 3221331752 AND 3221331759 OR notes.tile BETWEEN 3221331768 AND 3221331775 OR notes.tile BETWEEN 3221331816 AND 3221331823 OR notes.tile BETWEEN 3221331832 AND 3221331967 OR notes.tile BETWEEN 3221337168 AND 3221337183 OR notes.tile BETWEEN 3221337200 AND 3221337215 OR notes.tile BETWEEN 3221337296 AND 3221337311 OR notes.tile BETWEEN 3221337328 AND 3221337599 OR notes.tile BETWEEN 3221337680 AND 3221337695 OR notes.tile BETWEEN 3221337712 AND 3221337727 OR notes.tile BETWEEN 3221337808 AND 3221337817 OR notes.tile BETWEEN 3221337820 AND 3221337821 OR notes.tile BETWEEN 3221337856 AND 3221337993 OR notes.tile BETWEEN 3221337996 AND 3221337997 OR notes.tile BETWEEN 3221338000 AND 3221338009 OR notes.tile BETWEEN 3221338012 AND 3221338013 OR notes.tile BETWEEN 3221338048 AND 3221338057 OR notes.tile BETWEEN 3221338060 AND 3221338061 OR notes.tile BETWEEN 3221338064 AND 3221338073 OR notes.tile BETWEEN 3221338076 AND 3221338077 OR notes.tile BETWEEN 3221342760 AND 3221342767 OR notes.tile BETWEEN 3221342776 AND 3221342783 OR notes.tile BETWEEN 3221342824 AND 3221342831 OR notes.tile BETWEEN 3221342840 AND 3221342975 OR notes.tile BETWEEN 3221343016 AND 3221343023 OR notes.tile BETWEEN 3221343032 AND 3221343039 OR notes.tile BETWEEN 3221343080 AND 3221343087 OR notes.tile BETWEEN 3221343096 AND 3221343231 OR notes.tile BETWEEN 3221343784 AND 3221343791 OR notes.tile BETWEEN 3221343800 AND 3221343807 OR notes.tile BETWEEN 3221343848 AND 3221343855 OR notes.tile BETWEEN 3221343864 AND 3221343999 OR notes.tile BETWEEN 3221344040 AND 3221344047 OR notes.tile BETWEEN 3221344128 AND 3221344144 OR notes.tile BETWEEN 3221344160 AND 3221344176 OR notes.tile BETWEEN 3221348352 AND 3221349001 OR notes.tile BETWEEN 3221349004 AND 3221349005 OR notes.tile BETWEEN 3221349008 AND 3221349017 OR notes.tile BETWEEN 3221349020 AND 3221349021 OR notes.tile BETWEEN 3221349056 AND 3221349065 OR notes.tile BETWEEN 3221349068 AND 3221349069 OR notes.tile BETWEEN 3221349072 AND 3221349081 OR notes.tile BETWEEN 3221349084 AND 3221349085 OR notes.tile BETWEEN 3221349120 AND 3221349257 OR notes.tile BETWEEN 3221349260 AND 3221349261 OR notes.tile BETWEEN 3221349264 AND 3221349273 OR notes.tile BETWEEN 3221349276 AND 3221349277 OR notes.tile BETWEEN 3221349312 AND 3221349321 OR notes.tile BETWEEN 3221349324 AND 3221349325 OR notes.tile BETWEEN 3221349328 AND 3221349337 OR notes.tile BETWEEN 3221349340 AND 3221349341 OR notes.tile BETWEEN 3221349376 AND 3221349648 OR notes.tile BETWEEN 3221349664 AND 3221349680 OR notes.tile BETWEEN 3221349760 AND 3221349776 OR notes.tile BETWEEN 3221349792 AND 3221349808 OR notes.tile BETWEEN 3221349888 AND 3221350025 OR notes.tile BETWEEN 3221350028 AND 3221350029 OR notes.tile BETWEEN 3221350032 AND 3221350041 OR notes.tile BETWEEN 3221350044 AND 3221350045 OR notes.tile BETWEEN 3221350080 AND 3221350089 OR notes.tile BETWEEN 3221350092 AND 3221350093 OR notes.tile BETWEEN 3221350096 AND 3221350105 OR notes.tile BETWEEN 3221350108 AND 3221350109 OR notes.tile BETWEEN 3221350144 AND 3221350160 OR notes.tile BETWEEN 3221350176 AND 3221350192 OR notes.tile BETWEEN 3221350272 AND 3221350281 OR notes.tile BETWEEN 3221350284 AND 3221350285 OR notes.tile IN (3221344056, 3221344058, 3221344146, 3221344152, 3221344154, 3221344178, 3221344184, 3221344186, 3221349650, 3221349656, 3221349658, 3221349682, 3221349688, 3221349690, 3221349778, 3221349784, 3221349786, 3221349810, 3221349816, 3221349818, 3221350162, 3221350168, 3221350170, 3221350194, 3221350200, 3221350202, 3221350288, 3221350290, 3221350296)) AND notes.latitude BETWEEN 10000000.0 AND 12000000.0 ORDER BY updated_at DESC LIMIT 2;
