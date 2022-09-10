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
SELECT current_nodes.* FROM current_nodes WHERE (current_nodes.tile BETWEEN 3227646336 AND 3227646463 OR current_nodes.tile BETWEEN 3227646720 AND 3227646975 OR current_nodes.tile BETWEEN 3227647104 AND 3227647231 OR current_nodes.tile BETWEEN 3227647360 AND 3227647999 OR current_nodes.tile BETWEEN 3227734272 AND 3227734433 OR current_nodes.tile BETWEEN 3227734436 AND 3227734437 OR current_nodes.tile BETWEEN 3227734448 AND 3227734449 OR current_nodes.tile BETWEEN 3227734452 AND 3227734453 OR current_nodes.tile BETWEEN 3227734464 AND 3227734497 OR current_nodes.tile BETWEEN 3227734500 AND 3227734501 OR current_nodes.tile BETWEEN 3227734512 AND 3227734513 OR current_nodes.tile BETWEEN 3227734516 AND 3227734517 OR current_nodes.tile BETWEEN 3227735040 AND 3227735201 OR current_nodes.tile BETWEEN 3227735204 AND 3227735205 OR current_nodes.tile BETWEEN 3227735216 AND 3227735217 OR current_nodes.tile BETWEEN 3227735220 AND 3227735221 OR current_nodes.tile BETWEEN 3227735232 AND 3227735265 OR current_nodes.tile BETWEEN 3227735268 AND 3227735269 OR current_nodes.tile BETWEEN 3227735280 AND 3227735281 OR current_nodes.tile BETWEEN 3227735284 AND 3227735285 OR current_nodes.tile BETWEEN 3227735296 AND 3227735457 OR current_nodes.tile BETWEEN 3227735460 AND 3227735461 OR current_nodes.tile BETWEEN 3227735472 AND 3227735473 OR current_nodes.tile BETWEEN 3227735476 AND 3227735477 OR current_nodes.tile BETWEEN 3227735488 AND 3227735521 OR current_nodes.tile BETWEEN 3227735524 AND 3227735525 OR current_nodes.tile BETWEEN 3227735536 AND 3227735537 OR current_nodes.tile BETWEEN 3227735540 AND 3227735541 OR current_nodes.tile BETWEEN 3227822208 AND 3227822335 OR current_nodes.tile BETWEEN 3227822464 AND 3227822528 OR current_nodes.tile BETWEEN 3227822592 AND 3227822912 OR current_nodes.tile BETWEEN 3227822976 AND 3227823040 OR current_nodes.tile BETWEEN 3227910144 AND 3227910305 OR current_nodes.tile BETWEEN 3227910308 AND 3227910309 OR current_nodes.tile BETWEEN 3227910320 AND 3227910321 OR current_nodes.tile BETWEEN 3227910324 AND 3227910325 OR current_nodes.tile BETWEEN 3227910336 AND 3227910369 OR current_nodes.tile BETWEEN 3227910372 AND 3227910373 OR current_nodes.tile BETWEEN 3227910384 AND 3227910385 OR current_nodes.tile BETWEEN 3227910388 AND 3227910389 OR current_nodes.tile BETWEEN 3227910400 AND 3227910464 OR current_nodes.tile BETWEEN 3227910528 AND 3227910561 OR current_nodes.tile BETWEEN 3227910564 AND 3227910565 OR current_nodes.tile BETWEEN 3227910576 AND 3227910577 OR current_nodes.tile BETWEEN 3227910580 AND 3227910581 OR current_nodes.tile IN (3227822530, 3227822536, 3227822538, 3227822560, 3227822562, 3227822568, 3227822570, 3227822914, 3227822920, 3227822922, 3227822944, 3227822946, 3227822952, 3227822954, 3227823042, 3227823048, 3227823050, 3227823072, 3227823074, 3227823080, 3227823082, 3227910466, 3227910472, 3227910474, 3227910496, 3227910498, 3227910504, 3227910506, 3227910592, 3227910594, 3227910600, 3227910602, 3227910624)) AND current_nodes.latitude BETWEEN 69000000.0 AND 71000000.0 AND current_nodes.longitude BETWEEN 69000000.0 AND 71000000.0 AND current_nodes.visible = True LIMIT 3;
-- Rewritten Queries
SELECT current_nodes.* FROM current_nodes WHERE (current_nodes.tile BETWEEN 3227646336 AND 3227646463 OR current_nodes.tile BETWEEN 3227646720 AND 3227646975 OR current_nodes.tile BETWEEN 3227647104 AND 3227647231 OR current_nodes.tile BETWEEN 3227647360 AND 3227647999 OR current_nodes.tile BETWEEN 3227734272 AND 3227734433 OR current_nodes.tile BETWEEN 3227734436 AND 3227734437 OR current_nodes.tile BETWEEN 3227734448 AND 3227734449 OR current_nodes.tile BETWEEN 3227734452 AND 3227734453 OR current_nodes.tile BETWEEN 3227734464 AND 3227734497 OR current_nodes.tile BETWEEN 3227734500 AND 3227734501 OR current_nodes.tile BETWEEN 3227734512 AND 3227734513 OR current_nodes.tile BETWEEN 3227734516 AND 3227734517 OR current_nodes.tile BETWEEN 3227735040 AND 3227735201 OR current_nodes.tile BETWEEN 3227735204 AND 3227735205 OR current_nodes.tile BETWEEN 3227735216 AND 3227735217 OR current_nodes.tile BETWEEN 3227735220 AND 3227735221 OR current_nodes.tile BETWEEN 3227735232 AND 3227735265 OR current_nodes.tile BETWEEN 3227735268 AND 3227735269 OR current_nodes.tile BETWEEN 3227735280 AND 3227735281 OR current_nodes.tile BETWEEN 3227735284 AND 3227735285 OR current_nodes.tile BETWEEN 3227735296 AND 3227735457 OR current_nodes.tile BETWEEN 3227735460 AND 3227735461 OR current_nodes.tile BETWEEN 3227735472 AND 3227735473 OR current_nodes.tile BETWEEN 3227735476 AND 3227735477 OR current_nodes.tile BETWEEN 3227735488 AND 3227735521 OR current_nodes.tile BETWEEN 3227735524 AND 3227735525 OR current_nodes.tile BETWEEN 3227735536 AND 3227735537 OR current_nodes.tile BETWEEN 3227735540 AND 3227735541 OR current_nodes.tile BETWEEN 3227822208 AND 3227822335 OR current_nodes.tile BETWEEN 3227822464 AND 3227822528 OR current_nodes.tile BETWEEN 3227822592 AND 3227822912 OR current_nodes.tile BETWEEN 3227822976 AND 3227823040 OR current_nodes.tile BETWEEN 3227910144 AND 3227910305 OR current_nodes.tile BETWEEN 3227910308 AND 3227910309 OR current_nodes.tile BETWEEN 3227910320 AND 3227910321 OR current_nodes.tile BETWEEN 3227910324 AND 3227910325 OR current_nodes.tile BETWEEN 3227910336 AND 3227910369 OR current_nodes.tile BETWEEN 3227910372 AND 3227910373 OR current_nodes.tile BETWEEN 3227910384 AND 3227910385 OR current_nodes.tile BETWEEN 3227910388 AND 3227910389 OR current_nodes.tile BETWEEN 3227910400 AND 3227910464 OR current_nodes.tile BETWEEN 3227910528 AND 3227910561 OR current_nodes.tile BETWEEN 3227910564 AND 3227910565 OR current_nodes.tile BETWEEN 3227910576 AND 3227910577 OR current_nodes.tile BETWEEN 3227910580 AND 3227910581 OR current_nodes.tile IN (3227822530, 3227822536, 3227822538, 3227822560, 3227822562, 3227822568, 3227822570, 3227822914, 3227822920, 3227822922, 3227822944, 3227822946, 3227822952, 3227822954, 3227823042, 3227823048, 3227823050, 3227823072, 3227823074, 3227823080, 3227823082, 3227910466, 3227910472, 3227910474, 3227910496, 3227910498, 3227910504, 3227910506, 3227910592, 3227910594, 3227910600, 3227910602, 3227910624)) AND current_nodes.latitude BETWEEN 69000000.0 AND 71000000.0 AND current_nodes.visible = True LIMIT 3;
