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
    k character varying     ,
    v character varying     
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
    num_changes integer    
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
    allow_read_prefs boolean    ,
    allow_write_prefs boolean    ,
    allow_write_diary boolean    ,
    allow_write_api boolean    ,
    allow_read_gpx boolean    ,
    allow_write_gpx boolean    ,
    allow_write_notes boolean    
);

CREATE TABLE current_node_tags (
    node_id bigint NOT NULL,
    k character varying     ,
    v character varying     
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
    sequence_id integer    
);

CREATE TABLE current_relation_tags (
    relation_id bigint NOT NULL,
    k character varying     ,
    v character varying     
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
    k character varying     ,
    v character varying     
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
    priority integer    ,
    attempts integer    ,
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
    visible boolean    ,
    body_format character varying    
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
    language_code character varying     ,
    visible boolean    ,
    body_format character varying    
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
    visible boolean    ,
    name character varying     ,
    size bigint,
    latitude double precision,
    longitude double precision,
    "timestamp" timestamp without time zone NOT NULL,
    description character varying     ,
    inserted boolean NOT NULL,
    visibility character varying    
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
    status character varying    ,
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
    message_read boolean    ,
    to_user_id bigint NOT NULL,
    to_user_visible boolean    ,
    from_user_visible boolean    ,
    body_format character varying    
);

CREATE TABLE node_tags (
    node_id bigint NOT NULL,
    version bigint NOT NULL,
    k character varying     ,
    v character varying     
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
    scopes character varying     ,
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
    previous_refresh_token character varying     
);

CREATE TABLE oauth_applications (
    id bigint NOT NULL,
    owner_type character varying NOT NULL,
    owner_id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri character varying NOT NULL,
    scopes character varying     ,
    confidential boolean    ,
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
    allow_read_prefs boolean    ,
    allow_write_prefs boolean    ,
    allow_write_diary boolean    ,
    allow_write_api boolean    ,
    allow_read_gpx boolean    ,
    allow_write_gpx boolean    ,
    callback_url character varying,
    verifier character varying(20),
    scope character varying,
    valid_to timestamp without time zone,
    allow_write_notes boolean    
);

CREATE TABLE redactions (
    id integer NOT NULL,
    title character varying,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id bigint NOT NULL,
    description_format character varying    
);

CREATE TABLE relation_members (
    relation_id bigint NOT NULL,
    member_type character varying NOT NULL,
    member_id bigint NOT NULL,
    member_role character varying NOT NULL,
    version bigint    ,
    sequence_id integer    
);

CREATE TABLE relation_tags (
    relation_id bigint NOT NULL,
    k character varying     ,
    v character varying     ,
    version bigint NOT NULL
);

CREATE TABLE relations (
    relation_id bigint NOT NULL,
    changeset_id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    version bigint NOT NULL,
    visible boolean    ,
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
    needs_view boolean    ,
    revoker_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reason_format character varying    
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
    display_name character varying     ,
    data_public boolean    ,
    description character varying    ,
    home_lat double precision,
    home_lon double precision,
    home_zoom smallint  ,
    pass_salt character varying,
    email_valid boolean    ,
    new_email character varying,
    creation_ip character varying,
    languages character varying,
    status character varying    ,
    terms_agreed timestamp without time zone,
    consider_pd boolean    ,
    auth_uid character varying,
    preferred_editor character varying,
    terms_seen boolean    ,
    description_format character varying    ,
    changesets_count integer    ,
    traces_count integer    ,
    diary_entries_count integer    ,
    image_use_gravatar boolean    ,
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
    visible boolean    ,
    redaction_id integer
);


-- Original Query
SELECT gpx_files.id AS t0_r0, gpx_files.user_id AS t0_r1, gpx_files.visible AS t0_r2, gpx_files.name AS t0_r3, gpx_files.size AS t0_r4, gpx_files.latitude AS t0_r5, gpx_files.longitude AS t0_r6, gpx_files.timestamp AS t0_r7, gpx_files.description AS t0_r8, gpx_files.inserted AS t0_r9, gpx_files.visibility AS t0_r10, users.email AS t1_r0, users.id AS t1_r1, users.pass_crypt AS t1_r2, users.creation_time AS t1_r3, users.display_name AS t1_r4, users.data_public AS t1_r5, users.description AS t1_r6, users.home_lat AS t1_r7, users.home_lon AS t1_r8, users.home_zoom AS t1_r9, users.pass_salt AS t1_r10, users.email_valid AS t1_r11, users.new_email AS t1_r12, users.creation_ip AS t1_r13, users.languages AS t1_r14, users.status AS t1_r15, users.terms_agreed AS t1_r16, users.consider_pd AS t1_r17, users.auth_uid AS t1_r18, users.preferred_editor AS t1_r19, users.terms_seen AS t1_r20, users.description_format AS t1_r21, users.changesets_count AS t1_r22, users.traces_count AS t1_r23, users.diary_entries_count AS t1_r24, users.image_use_gravatar AS t1_r25, users.auth_provider AS t1_r26, users.home_tile AS t1_r27, users.tou_agreed AS t1_r28, gpx_file_tags.gpx_id AS t2_r0, gpx_file_tags.tag AS t2_r1, gpx_file_tags.id AS t2_r2 FROM gpx_files INNER JOIN gpx_file_tags ON gpx_file_tags.gpx_id = gpx_files.id LEFT OUTER JOIN users ON users.id = gpx_files.user_id WHERE gpx_files.visible = False AND (visibility IN ('public', 'identifiable') OR user_id = 2236) AND gpx_file_tags.tag = 'kmkkdvqxxtyhllehicwynulsubvzzqmeaihdbdjadmrrqzexztdoxmlfezbrmiocwjfiixgkfxgmuhvpkjmctsycrypfsxloaiowlhzdiufqmjljnxavwdfcwuhecltcdodtonkmgfmwwjgdjwebsbjriskwghqrknolnxjornwekjuzhaxnscsxsxwdwdhtqmyaurneymhfvahykfxyschbsvxrfzzxdldngmjenevjoa' AND gpx_files.visible = False AND gpx_files.id IN (8565, 276) ORDER BY gpx_files.id DESC;
-- Rewritten Queries
SELECT gpx_files.id AS t0_r0, gpx_files.user_id AS t0_r1, gpx_files.visible AS t0_r2, gpx_files.name AS t0_r3, gpx_files.size AS t0_r4, gpx_files.latitude AS t0_r5, gpx_files.longitude AS t0_r6, gpx_files.timestamp AS t0_r7, gpx_files.description AS t0_r8, gpx_files.inserted AS t0_r9, gpx_files.visibility AS t0_r10, users.email AS t1_r0, users.id AS t1_r1, users.pass_crypt AS t1_r2, users.creation_time AS t1_r3, users.display_name AS t1_r4, users.data_public AS t1_r5, users.description AS t1_r6, users.home_lat AS t1_r7, users.home_lon AS t1_r8, users.home_zoom AS t1_r9, users.pass_salt AS t1_r10, users.email_valid AS t1_r11, users.new_email AS t1_r12, users.creation_ip AS t1_r13, users.languages AS t1_r14, users.status AS t1_r15, users.terms_agreed AS t1_r16, users.consider_pd AS t1_r17, users.auth_uid AS t1_r18, users.preferred_editor AS t1_r19, users.terms_seen AS t1_r20, users.description_format AS t1_r21, users.changesets_count AS t1_r22, users.traces_count AS t1_r23, users.diary_entries_count AS t1_r24, users.image_use_gravatar AS t1_r25, users.auth_provider AS t1_r26, users.home_tile AS t1_r27, users.tou_agreed AS t1_r28, gpx_file_tags.gpx_id AS t2_r0, gpx_file_tags.tag AS t2_r1, gpx_file_tags.id AS t2_r2 FROM gpx_files INNER JOIN gpx_file_tags ON gpx_file_tags.gpx_id = gpx_files.id LEFT OUTER JOIN users ON users.id = gpx_files.user_id WHERE gpx_files.visible = False AND (visibility IN ('public', 'identifiable') OR user_id = 2236) AND gpx_file_tags.tag = 'kmkkdvqxxtyhllehicwynulsubvzzqmeaihdbdjadmrrqzexztdoxmlfezbrmiocwjfiixgkfxgmuhvpkjmctsycrypfsxloaiowlhzdiufqmjljnxavwdfcwuhecltcdodtonkmgfmwwjgdjwebsbjriskwghqrknolnxjornwekjuzhaxnscsxsxwdwdhtqmyaurneymhfvahykfxyschbsvxrfzzxdldngmjenevjoa' AND gpx_files.visible = False AND gpx_files.id IN (8565, 276) ORDER BY gpx_files.id DESC LIMIT 1;
SELECT gpx_files.id AS t0_r0, gpx_files.user_id AS t0_r1, gpx_files.visible AS t0_r2, gpx_files.name AS t0_r3, gpx_files.size AS t0_r4, gpx_files.latitude AS t0_r5, gpx_files.longitude AS t0_r6, gpx_files.timestamp AS t0_r7, gpx_files.description AS t0_r8, gpx_files.inserted AS t0_r9, gpx_files.visibility AS t0_r10, users.email AS t1_r0, users.id AS t1_r1, users.pass_crypt AS t1_r2, users.creation_time AS t1_r3, users.display_name AS t1_r4, users.data_public AS t1_r5, users.description AS t1_r6, users.home_lat AS t1_r7, users.home_lon AS t1_r8, users.home_zoom AS t1_r9, users.pass_salt AS t1_r10, users.email_valid AS t1_r11, users.new_email AS t1_r12, users.creation_ip AS t1_r13, users.languages AS t1_r14, users.status AS t1_r15, users.terms_agreed AS t1_r16, users.consider_pd AS t1_r17, users.auth_uid AS t1_r18, users.preferred_editor AS t1_r19, users.terms_seen AS t1_r20, users.description_format AS t1_r21, users.changesets_count AS t1_r22, users.traces_count AS t1_r23, users.diary_entries_count AS t1_r24, users.image_use_gravatar AS t1_r25, users.auth_provider AS t1_r26, users.home_tile AS t1_r27, users.tou_agreed AS t1_r28, gpx_file_tags.gpx_id AS t2_r0, gpx_file_tags.tag AS t2_r1, gpx_file_tags.id AS t2_r2 FROM gpx_files INNER JOIN gpx_file_tags ON gpx_file_tags.gpx_id = gpx_files.id INNER JOIN users ON users.id = gpx_files.user_id WHERE gpx_files.visible = False AND (visibility IN ('public', 'identifiable') OR user_id = 2236) AND gpx_file_tags.tag = 'kmkkdvqxxtyhllehicwynulsubvzzqmeaihdbdjadmrrqzexztdoxmlfezbrmiocwjfiixgkfxgmuhvpkjmctsycrypfsxloaiowlhzdiufqmjljnxavwdfcwuhecltcdodtonkmgfmwwjgdjwebsbjriskwghqrknolnxjornwekjuzhaxnscsxsxwdwdhtqmyaurneymhfvahykfxyschbsvxrfzzxdldngmjenevjoa' AND gpx_files.visible = False AND gpx_files.id IN (4568, 8565) ORDER BY gpx_files.id DESC;
SELECT gpx_files.id AS t0_r0, gpx_files.user_id AS t0_r1, gpx_files.visible AS t0_r2, gpx_files.name AS t0_r3, gpx_files.size AS t0_r4, gpx_files.latitude AS t0_r5, gpx_files.longitude AS t0_r6, gpx_files.timestamp AS t0_r7, gpx_files.description AS t0_r8, gpx_files.inserted AS t0_r9, gpx_files.visibility AS t0_r10, users.email AS t1_r0, users.id AS t1_r1, users.pass_crypt AS t1_r2, users.creation_time AS t1_r3, users.display_name AS t1_r4, users.data_public AS t1_r5, users.description AS t1_r6, users.home_lat AS t1_r7, users.home_lon AS t1_r8, users.home_zoom AS t1_r9, users.pass_salt AS t1_r10, users.email_valid AS t1_r11, users.new_email AS t1_r12, users.creation_ip AS t1_r13, users.languages AS t1_r14, users.status AS t1_r15, users.terms_agreed AS t1_r16, users.consider_pd AS t1_r17, users.auth_uid AS t1_r18, users.preferred_editor AS t1_r19, users.terms_seen AS t1_r20, users.description_format AS t1_r21, users.changesets_count AS t1_r22, users.traces_count AS t1_r23, users.diary_entries_count AS t1_r24, users.image_use_gravatar AS t1_r25, users.auth_provider AS t1_r26, users.home_tile AS t1_r27, users.tou_agreed AS t1_r28, gpx_file_tags.gpx_id AS t2_r0, gpx_file_tags.tag AS t2_r1, gpx_file_tags.id AS t2_r2 FROM gpx_files INNER JOIN gpx_file_tags ON gpx_file_tags.gpx_id = gpx_files.id INNER JOIN users ON users.id = gpx_files.user_id WHERE gpx_files.visible = False AND (visibility IN ('public', 'identifiable') OR user_id = 2236) AND gpx_file_tags.tag = 'kmkkdvqxxtyhllehicwynulsubvzzqmeaihdbdjadmrrqzexztdoxmlfezbrmiocwjfiixgkfxgmuhvpkjmctsycrypfsxloaiowlhzdiufqmjljnxavwdfcwuhecltcdodtonkmgfmwwjgdjwebsbjriskwghqrknolnxjornwekjuzhaxnscsxsxwdwdhtqmyaurneymhfvahykfxyschbsvxrfzzxdldngmjenevjoa' AND gpx_files.visible = False AND gpx_files.id IN (4568, 8565) ORDER BY gpx_files.id DESC LIMIT 1;
