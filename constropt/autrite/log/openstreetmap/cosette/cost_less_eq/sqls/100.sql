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
SELECT notes.* FROM notes WHERE notes.status <> 'open' AND (notes.tile BETWEEN 3221331576 AND 3221331583 OR notes.tile BETWEEN 3221331664 AND 3221331679 OR notes.tile BETWEEN 3221331696 AND 3221331711 OR notes.tile BETWEEN 3221331752 AND 3221331759 OR notes.tile BETWEEN 3221331768 AND 3221331775 OR notes.tile BETWEEN 3221331816 AND 3221331823 OR notes.tile BETWEEN 3221331832 AND 3221331967 OR notes.tile BETWEEN 3221337168 AND 3221337183 OR notes.tile BETWEEN 3221337200 AND 3221337215 OR notes.tile BETWEEN 3221337296 AND 3221337311 OR notes.tile BETWEEN 3221337328 AND 3221337599 OR notes.tile BETWEEN 3221337680 AND 3221337695 OR notes.tile BETWEEN 3221337712 AND 3221337727 OR notes.tile BETWEEN 3221337808 AND 3221337823 OR notes.tile BETWEEN 3221337840 AND 3221338111 OR notes.tile BETWEEN 3221339216 AND 3221339231 OR notes.tile BETWEEN 3221339248 AND 3221339263 OR notes.tile BETWEEN 3221339344 AND 3221339359 OR notes.tile BETWEEN 3221339376 AND 3221339647 OR notes.tile BETWEEN 3221339728 AND 3221339743 OR notes.tile BETWEEN 3221339760 AND 3221339775 OR notes.tile BETWEEN 3221339856 AND 3221339871 OR notes.tile BETWEEN 3221339888 AND 3221340159 OR notes.tile BETWEEN 3221342760 AND 3221342767 OR notes.tile BETWEEN 3221342776 AND 3221342783 OR notes.tile BETWEEN 3221342824 AND 3221342831 OR notes.tile BETWEEN 3221342840 AND 3221342975 OR notes.tile BETWEEN 3221343016 AND 3221343023 OR notes.tile BETWEEN 3221343032 AND 3221343039 OR notes.tile BETWEEN 3221343080 AND 3221343087 OR notes.tile BETWEEN 3221343096 AND 3221343231 OR notes.tile BETWEEN 3221343784 AND 3221343791 OR notes.tile BETWEEN 3221343800 AND 3221343807 OR notes.tile BETWEEN 3221343848 AND 3221343855 OR notes.tile BETWEEN 3221343864 AND 3221343999 OR notes.tile BETWEEN 3221344040 AND 3221344047 OR notes.tile BETWEEN 3221344056 AND 3221344063 OR notes.tile BETWEEN 3221344104 AND 3221344111 OR notes.tile BETWEEN 3221344120 AND 3221344255 OR notes.tile BETWEEN 3221346856 AND 3221346863 OR notes.tile BETWEEN 3221346872 AND 3221346879 OR notes.tile BETWEEN 3221346920 AND 3221346927 OR notes.tile BETWEEN 3221346936 AND 3221347071 OR notes.tile BETWEEN 3221347112 AND 3221347119 OR notes.tile BETWEEN 3221347128 AND 3221347135 OR notes.tile BETWEEN 3221347176 AND 3221347183 OR notes.tile BETWEEN 3221347192 AND 3221347327 OR notes.tile BETWEEN 3221347880 AND 3221347887 OR notes.tile BETWEEN 3221347896 AND 3221347903 OR notes.tile BETWEEN 3221347944 AND 3221347951 OR notes.tile BETWEEN 3221347960 AND 3221348095 OR notes.tile BETWEEN 3221348136 AND 3221348143 OR notes.tile BETWEEN 3221348152 AND 3221348159 OR notes.tile BETWEEN 3221348200 AND 3221348207 OR notes.tile BETWEEN 3221348216 AND 3221356543 OR notes.tile BETWEEN 3221427280 AND 3221427295 OR notes.tile BETWEEN 3221427312 AND 3221427327 OR notes.tile BETWEEN 3221427408 AND 3221427423 OR notes.tile BETWEEN 3221427440 AND 3221427711 OR notes.tile BETWEEN 3221427792 AND 3221427807 OR notes.tile BETWEEN 3221427824 AND 3221427839 OR notes.tile BETWEEN 3221427920 AND 3221427935 OR notes.tile BETWEEN 3221427952 AND 3221428223 OR notes.tile BETWEEN 3221429328 AND 3221429343 OR notes.tile BETWEEN 3221429360 AND 3221429375 OR notes.tile BETWEEN 3221429456 AND 3221429471 OR notes.tile BETWEEN 3221429488 AND 3221429759 OR notes.tile BETWEEN 3221429840 AND 3221429855 OR notes.tile BETWEEN 3221429872 AND 3221429879 OR notes.tile BETWEEN 3221430016 AND 3221430055 OR notes.tile BETWEEN 3221430064 AND 3221430071 OR notes.tile BETWEEN 3221430080 AND 3221430119 OR notes.tile BETWEEN 3221430128 AND 3221430135 OR notes.tile BETWEEN 3221438464 AND 3221441063 OR notes.tile BETWEEN 3221441072 AND 3221441079 OR notes.tile BETWEEN 3221441088 AND 3221441127 OR notes.tile BETWEEN 3221441136 AND 3221441143 OR notes.tile BETWEEN 3221441280 AND 3221441319 OR notes.tile BETWEEN 3221441328 AND 3221441335 OR notes.tile BETWEEN 3221441344 AND 3221441383 OR notes.tile BETWEEN 3221441392 AND 3221441399 OR notes.tile BETWEEN 3221441536 AND 3221442087 OR notes.tile BETWEEN 3221442096 AND 3221442103 OR notes.tile BETWEEN 3221442112 AND 3221442151 OR notes.tile BETWEEN 3221442160 AND 3221442167 OR notes.tile BETWEEN 3221442304 AND 3221442343 OR notes.tile BETWEEN 3221442352 AND 3221442359 OR notes.tile BETWEEN 3221442368 AND 3221442407 OR notes.tile BETWEEN 3221442416 AND 3221442423 OR notes.tile BETWEEN 3221442560 AND 3221445159 OR notes.tile BETWEEN 3221445168 AND 3221445175 OR notes.tile BETWEEN 3221445184 AND 3221445223 OR notes.tile BETWEEN 3221445232 AND 3221445239 OR notes.tile BETWEEN 3221445376 AND 3221445415 OR notes.tile BETWEEN 3221445424 AND 3221445431 OR notes.tile BETWEEN 3221445440 AND 3221445479 OR notes.tile BETWEEN 3221445488 AND 3221445495 OR notes.tile BETWEEN 3221445632 AND 3221446183 OR notes.tile BETWEEN 3221446192 AND 3221446199 OR notes.tile BETWEEN 3221446208 AND 3221446247 OR notes.tile BETWEEN 3221446256 AND 3221446263 OR notes.tile BETWEEN 3221446400 AND 3221446439 OR notes.tile BETWEEN 3221446448 AND 3221446455 OR notes.tile BETWEEN 3221446464 AND 3221446503 OR notes.tile BETWEEN 3221446512 AND 3221446519 OR notes.tile BETWEEN 3221522984 AND 3221522991 OR notes.tile BETWEEN 3221523000 AND 3221523007 OR notes.tile BETWEEN 3221523048 AND 3221523055 OR notes.tile BETWEEN 3221523064 AND 3221523199 OR notes.tile BETWEEN 3221523240 AND 3221523247 OR notes.tile BETWEEN 3221523256 AND 3221523263 OR notes.tile BETWEEN 3221523304 AND 3221523311 OR notes.tile BETWEEN 3221523320 AND 3221523455 OR notes.tile BETWEEN 3221524008 AND 3221524015 OR notes.tile BETWEEN 3221524024 AND 3221524031 OR notes.tile BETWEEN 3221524072 AND 3221524079 OR notes.tile BETWEEN 3221524088 AND 3221524223 OR notes.tile BETWEEN 3221524264 AND 3221524271 OR notes.tile BETWEEN 3221524280 AND 3221524287 OR notes.tile BETWEEN 3221524328 AND 3221524335 OR notes.tile BETWEEN 3221524344 AND 3221524479 OR notes.tile BETWEEN 3221527080 AND 3221527087 OR notes.tile BETWEEN 3221527096 AND 3221527103 OR notes.tile BETWEEN 3221527144 AND 3221527151 OR notes.tile BETWEEN 3221527160 AND 3221527295 OR notes.tile BETWEEN 3221527336 AND 3221527343 OR notes.tile BETWEEN 3221527352 AND 3221527359 OR notes.tile BETWEEN 3221527400 AND 3221527407 OR notes.tile BETWEEN 3221527416 AND 3221527551 OR notes.tile BETWEEN 3221528104 AND 3221528111 OR notes.tile BETWEEN 3221528120 AND 3221528127 OR notes.tile BETWEEN 3221528168 AND 3221528172 OR notes.tile BETWEEN 3221528192 AND 3221528260 OR notes.tile BETWEEN 3221528264 AND 3221528268 OR notes.tile BETWEEN 3221528288 AND 3221528292 OR notes.tile BETWEEN 3221528296 AND 3221528300 OR notes.tile BETWEEN 3221528576 AND 3221533764 OR notes.tile BETWEEN 3221533768 AND 3221533772 OR notes.tile BETWEEN 3221533792 AND 3221533796 OR notes.tile BETWEEN 3221533800 AND 3221533804 OR notes.tile BETWEEN 3221533824 AND 3221533892 OR notes.tile BETWEEN 3221533896 AND 3221533900 OR notes.tile BETWEEN 3221533920 AND 3221533924 OR notes.tile BETWEEN 3221533928 AND 3221533932 OR notes.tile BETWEEN 3221534208 AND 3221534276 OR notes.tile BETWEEN 3221534280 AND 3221534284 OR notes.tile BETWEEN 3221534304 AND 3221534308 OR notes.tile BETWEEN 3221534312 AND 3221534316 OR notes.tile BETWEEN 3221534336 AND 3221534404 OR notes.tile BETWEEN 3221534408 AND 3221534412 OR notes.tile BETWEEN 3221534432 AND 3221534436 OR notes.tile BETWEEN 3221534440 AND 3221534444 OR notes.tile BETWEEN 3221534720 AND 3221535812 OR notes.tile BETWEEN 3221535816 AND 3221535820 OR notes.tile BETWEEN 3221535840 AND 3221535844 OR notes.tile BETWEEN 3221535848 AND 3221535852 OR notes.tile BETWEEN 3221535872 AND 3221535940 OR notes.tile BETWEEN 3221535944 AND 3221535948 OR notes.tile BETWEEN 3221535968 AND 3221535972 OR notes.tile BETWEEN 3221535976 AND 3221535980 OR notes.tile BETWEEN 3221536256 AND 3221536324 OR notes.tile BETWEEN 3221536328 AND 3221536332 OR notes.tile BETWEEN 3221536352 AND 3221536356 OR notes.tile BETWEEN 3221536360 AND 3221536364 OR notes.tile BETWEEN 3221536384 AND 3221536452 OR notes.tile BETWEEN 3221536456 AND 3221536460 OR notes.tile BETWEEN 3221536480 AND 3221536484 OR notes.tile BETWEEN 3221536488 AND 3221536492 OR notes.tile BETWEEN 3221618688 AND 3221621287 OR notes.tile BETWEEN 3221621296 AND 3221621303 OR notes.tile BETWEEN 3221621312 AND 3221621351 OR notes.tile BETWEEN 3221621360 AND 3221621367 OR notes.tile BETWEEN 3221621504 AND 3221621543 OR notes.tile BETWEEN 3221621552 AND 3221621559 OR notes.tile BETWEEN 3221621568 AND 3221621607 OR notes.tile BETWEEN 3221621616 AND 3221621623 OR notes.tile BETWEEN 3221621760 AND 3221622311 OR notes.tile BETWEEN 3221622320 AND 3221622327 OR notes.tile BETWEEN 3221622336 AND 3221622375 OR notes.tile BETWEEN 3221622384 AND 3221622391 OR notes.tile BETWEEN 3221622528 AND 3221622567 OR notes.tile BETWEEN 3221622576 AND 3221622583 OR notes.tile BETWEEN 3221622592 AND 3221622631 OR notes.tile BETWEEN 3221622640 AND 3221622647 OR notes.tile BETWEEN 3221622784 AND 3221623876 OR notes.tile BETWEEN 3221623880 AND 3221623884 OR notes.tile BETWEEN 3221623904 AND 3221623908 OR notes.tile BETWEEN 3221623912 AND 3221623916 OR notes.tile BETWEEN 3221623936 AND 3221624004 OR notes.tile BETWEEN 3221624008 AND 3221624012 OR notes.tile BETWEEN 3221624032 AND 3221624036 OR notes.tile BETWEEN 3221624040 AND 3221624044 OR notes.tile BETWEEN 3221624320 AND 3221624388 OR notes.tile BETWEEN 3221624392 AND 3221624396 OR notes.tile BETWEEN 3221624416 AND 3221624420 OR notes.tile BETWEEN 3221624424 AND 3221624428 OR notes.tile BETWEEN 3221624448 AND 3221624516 OR notes.tile BETWEEN 3221624520 AND 3221624524 OR notes.tile BETWEEN 3221624544 AND 3221624548 OR notes.tile BETWEEN 3221624552 AND 3221624556 OR notes.tile BETWEEN 3221624832 AND 3221625383 OR notes.tile BETWEEN 3221625392 AND 3221625399 OR notes.tile BETWEEN 3221625408 AND 3221625447 OR notes.tile BETWEEN 3221625456 AND 3221625463 OR notes.tile BETWEEN 3221625600 AND 3221625639 OR notes.tile BETWEEN 3221625648 AND 3221625655 OR notes.tile BETWEEN 3221625664 AND 3221625703 OR notes.tile BETWEEN 3221625712 AND 3221625719 OR notes.tile BETWEEN 3221625856 AND 3221625924 OR notes.tile BETWEEN 3221625928 AND 3221625932 OR notes.tile BETWEEN 3221625952 AND 3221625956 OR notes.tile BETWEEN 3221625960 AND 3221625964 OR notes.tile BETWEEN 3221625984 AND 3221626052 OR notes.tile BETWEEN 3221626056 AND 3221626060 OR notes.tile BETWEEN 3221626080 AND 3221626084 OR notes.tile BETWEEN 3221626088 AND 3221626092 OR notes.tile BETWEEN 3221626368 AND 3221626407 OR notes.tile BETWEEN 3221626416 AND 3221626423 OR notes.tile BETWEEN 3221626432 AND 3221626436 OR notes.tile BETWEEN 3221626440 AND 3221626444 OR notes.tile BETWEEN 3221626464 AND 3221626468 OR notes.tile IN (3221528174, 3221528262, 3221528270, 3221528294, 3221528302, 3221533766, 3221533774, 3221533798, 3221533806, 3221533894, 3221533902, 3221533926, 3221533934, 3221534278, 3221534286, 3221534310, 3221534318, 3221534406, 3221534414, 3221534438, 3221534446, 3221535814, 3221535822, 3221535846, 3221535854, 3221535942, 3221535950, 3221535974, 3221535982, 3221536326, 3221536334, 3221536358, 3221536366, 3221536454, 3221536462, 3221536486, 3221536494, 3221623878, 3221623886, 3221623910, 3221623918, 3221624006, 3221624014, 3221624038, 3221624046, 3221624390, 3221624398, 3221624422, 3221624430, 3221624518, 3221624526, 3221624550, 3221624558, 3221625926, 3221625934, 3221625958, 3221625966, 3221626054, 3221626062, 3221626086, 3221626094, 3221626438, 3221626446, 3221626470)) AND notes.latitude BETWEEN 10000000.0 AND 17000000.0 AND notes.longitude BETWEEN 10000000.0 AND 17000000.0 ORDER BY updated_at DESC LIMIT 1;
-- Rewritten Queries
SELECT notes.* FROM notes WHERE notes.status <> 'open' AND (notes.tile BETWEEN 3221331576 AND 3221331583 OR notes.tile BETWEEN 3221331664 AND 3221331679 OR notes.tile BETWEEN 3221331696 AND 3221331711 OR notes.tile BETWEEN 3221331752 AND 3221331759 OR notes.tile BETWEEN 3221331768 AND 3221331775 OR notes.tile BETWEEN 3221331816 AND 3221331823 OR notes.tile BETWEEN 3221331832 AND 3221331967 OR notes.tile BETWEEN 3221337168 AND 3221337183 OR notes.tile BETWEEN 3221337200 AND 3221337215 OR notes.tile BETWEEN 3221337296 AND 3221337311 OR notes.tile BETWEEN 3221337328 AND 3221337599 OR notes.tile BETWEEN 3221337680 AND 3221337695 OR notes.tile BETWEEN 3221337712 AND 3221337727 OR notes.tile BETWEEN 3221337808 AND 3221337823 OR notes.tile BETWEEN 3221337840 AND 3221338111 OR notes.tile BETWEEN 3221339216 AND 3221339231 OR notes.tile BETWEEN 3221339248 AND 3221339263 OR notes.tile BETWEEN 3221339344 AND 3221339359 OR notes.tile BETWEEN 3221339376 AND 3221339647 OR notes.tile BETWEEN 3221339728 AND 3221339743 OR notes.tile BETWEEN 3221339760 AND 3221339775 OR notes.tile BETWEEN 3221339856 AND 3221339871 OR notes.tile BETWEEN 3221339888 AND 3221340159 OR notes.tile BETWEEN 3221342760 AND 3221342767 OR notes.tile BETWEEN 3221342776 AND 3221342783 OR notes.tile BETWEEN 3221342824 AND 3221342831 OR notes.tile BETWEEN 3221342840 AND 3221342975 OR notes.tile BETWEEN 3221343016 AND 3221343023 OR notes.tile BETWEEN 3221343032 AND 3221343039 OR notes.tile BETWEEN 3221343080 AND 3221343087 OR notes.tile BETWEEN 3221343096 AND 3221343231 OR notes.tile BETWEEN 3221343784 AND 3221343791 OR notes.tile BETWEEN 3221343800 AND 3221343807 OR notes.tile BETWEEN 3221343848 AND 3221343855 OR notes.tile BETWEEN 3221343864 AND 3221343999 OR notes.tile BETWEEN 3221344040 AND 3221344047 OR notes.tile BETWEEN 3221344056 AND 3221344063 OR notes.tile BETWEEN 3221344104 AND 3221344111 OR notes.tile BETWEEN 3221344120 AND 3221344255 OR notes.tile BETWEEN 3221346856 AND 3221346863 OR notes.tile BETWEEN 3221346872 AND 3221346879 OR notes.tile BETWEEN 3221346920 AND 3221346927 OR notes.tile BETWEEN 3221346936 AND 3221347071 OR notes.tile BETWEEN 3221347112 AND 3221347119 OR notes.tile BETWEEN 3221347128 AND 3221347135 OR notes.tile BETWEEN 3221347176 AND 3221347183 OR notes.tile BETWEEN 3221347192 AND 3221347327 OR notes.tile BETWEEN 3221347880 AND 3221347887 OR notes.tile BETWEEN 3221347896 AND 3221347903 OR notes.tile BETWEEN 3221347944 AND 3221347951 OR notes.tile BETWEEN 3221347960 AND 3221348095 OR notes.tile BETWEEN 3221348136 AND 3221348143 OR notes.tile BETWEEN 3221348152 AND 3221348159 OR notes.tile BETWEEN 3221348200 AND 3221348207 OR notes.tile BETWEEN 3221348216 AND 3221356543 OR notes.tile BETWEEN 3221427280 AND 3221427295 OR notes.tile BETWEEN 3221427312 AND 3221427327 OR notes.tile BETWEEN 3221427408 AND 3221427423 OR notes.tile BETWEEN 3221427440 AND 3221427711 OR notes.tile BETWEEN 3221427792 AND 3221427807 OR notes.tile BETWEEN 3221427824 AND 3221427839 OR notes.tile BETWEEN 3221427920 AND 3221427935 OR notes.tile BETWEEN 3221427952 AND 3221428223 OR notes.tile BETWEEN 3221429328 AND 3221429343 OR notes.tile BETWEEN 3221429360 AND 3221429375 OR notes.tile BETWEEN 3221429456 AND 3221429471 OR notes.tile BETWEEN 3221429488 AND 3221429759 OR notes.tile BETWEEN 3221429840 AND 3221429855 OR notes.tile BETWEEN 3221429872 AND 3221429879 OR notes.tile BETWEEN 3221430016 AND 3221430055 OR notes.tile BETWEEN 3221430064 AND 3221430071 OR notes.tile BETWEEN 3221430080 AND 3221430119 OR notes.tile BETWEEN 3221430128 AND 3221430135 OR notes.tile BETWEEN 3221438464 AND 3221441063 OR notes.tile BETWEEN 3221441072 AND 3221441079 OR notes.tile BETWEEN 3221441088 AND 3221441127 OR notes.tile BETWEEN 3221441136 AND 3221441143 OR notes.tile BETWEEN 3221441280 AND 3221441319 OR notes.tile BETWEEN 3221441328 AND 3221441335 OR notes.tile BETWEEN 3221441344 AND 3221441383 OR notes.tile BETWEEN 3221441392 AND 3221441399 OR notes.tile BETWEEN 3221441536 AND 3221442087 OR notes.tile BETWEEN 3221442096 AND 3221442103 OR notes.tile BETWEEN 3221442112 AND 3221442151 OR notes.tile BETWEEN 3221442160 AND 3221442167 OR notes.tile BETWEEN 3221442304 AND 3221442343 OR notes.tile BETWEEN 3221442352 AND 3221442359 OR notes.tile BETWEEN 3221442368 AND 3221442407 OR notes.tile BETWEEN 3221442416 AND 3221442423 OR notes.tile BETWEEN 3221442560 AND 3221445159 OR notes.tile BETWEEN 3221445168 AND 3221445175 OR notes.tile BETWEEN 3221445184 AND 3221445223 OR notes.tile BETWEEN 3221445232 AND 3221445239 OR notes.tile BETWEEN 3221445376 AND 3221445415 OR notes.tile BETWEEN 3221445424 AND 3221445431 OR notes.tile BETWEEN 3221445440 AND 3221445479 OR notes.tile BETWEEN 3221445488 AND 3221445495 OR notes.tile BETWEEN 3221445632 AND 3221446183 OR notes.tile BETWEEN 3221446192 AND 3221446199 OR notes.tile BETWEEN 3221446208 AND 3221446247 OR notes.tile BETWEEN 3221446256 AND 3221446263 OR notes.tile BETWEEN 3221446400 AND 3221446439 OR notes.tile BETWEEN 3221446448 AND 3221446455 OR notes.tile BETWEEN 3221446464 AND 3221446503 OR notes.tile BETWEEN 3221446512 AND 3221446519 OR notes.tile BETWEEN 3221522984 AND 3221522991 OR notes.tile BETWEEN 3221523000 AND 3221523007 OR notes.tile BETWEEN 3221523048 AND 3221523055 OR notes.tile BETWEEN 3221523064 AND 3221523199 OR notes.tile BETWEEN 3221523240 AND 3221523247 OR notes.tile BETWEEN 3221523256 AND 3221523263 OR notes.tile BETWEEN 3221523304 AND 3221523311 OR notes.tile BETWEEN 3221523320 AND 3221523455 OR notes.tile BETWEEN 3221524008 AND 3221524015 OR notes.tile BETWEEN 3221524024 AND 3221524031 OR notes.tile BETWEEN 3221524072 AND 3221524079 OR notes.tile BETWEEN 3221524088 AND 3221524223 OR notes.tile BETWEEN 3221524264 AND 3221524271 OR notes.tile BETWEEN 3221524280 AND 3221524287 OR notes.tile BETWEEN 3221524328 AND 3221524335 OR notes.tile BETWEEN 3221524344 AND 3221524479 OR notes.tile BETWEEN 3221527080 AND 3221527087 OR notes.tile BETWEEN 3221527096 AND 3221527103 OR notes.tile BETWEEN 3221527144 AND 3221527151 OR notes.tile BETWEEN 3221527160 AND 3221527295 OR notes.tile BETWEEN 3221527336 AND 3221527343 OR notes.tile BETWEEN 3221527352 AND 3221527359 OR notes.tile BETWEEN 3221527400 AND 3221527407 OR notes.tile BETWEEN 3221527416 AND 3221527551 OR notes.tile BETWEEN 3221528104 AND 3221528111 OR notes.tile BETWEEN 3221528120 AND 3221528127 OR notes.tile BETWEEN 3221528168 AND 3221528172 OR notes.tile BETWEEN 3221528192 AND 3221528260 OR notes.tile BETWEEN 3221528264 AND 3221528268 OR notes.tile BETWEEN 3221528288 AND 3221528292 OR notes.tile BETWEEN 3221528296 AND 3221528300 OR notes.tile BETWEEN 3221528576 AND 3221533764 OR notes.tile BETWEEN 3221533768 AND 3221533772 OR notes.tile BETWEEN 3221533792 AND 3221533796 OR notes.tile BETWEEN 3221533800 AND 3221533804 OR notes.tile BETWEEN 3221533824 AND 3221533892 OR notes.tile BETWEEN 3221533896 AND 3221533900 OR notes.tile BETWEEN 3221533920 AND 3221533924 OR notes.tile BETWEEN 3221533928 AND 3221533932 OR notes.tile BETWEEN 3221534208 AND 3221534276 OR notes.tile BETWEEN 3221534280 AND 3221534284 OR notes.tile BETWEEN 3221534304 AND 3221534308 OR notes.tile BETWEEN 3221534312 AND 3221534316 OR notes.tile BETWEEN 3221534336 AND 3221534404 OR notes.tile BETWEEN 3221534408 AND 3221534412 OR notes.tile BETWEEN 3221534432 AND 3221534436 OR notes.tile BETWEEN 3221534440 AND 3221534444 OR notes.tile BETWEEN 3221534720 AND 3221535812 OR notes.tile BETWEEN 3221535816 AND 3221535820 OR notes.tile BETWEEN 3221535840 AND 3221535844 OR notes.tile BETWEEN 3221535848 AND 3221535852 OR notes.tile BETWEEN 3221535872 AND 3221535940 OR notes.tile BETWEEN 3221535944 AND 3221535948 OR notes.tile BETWEEN 3221535968 AND 3221535972 OR notes.tile BETWEEN 3221535976 AND 3221535980 OR notes.tile BETWEEN 3221536256 AND 3221536324 OR notes.tile BETWEEN 3221536328 AND 3221536332 OR notes.tile BETWEEN 3221536352 AND 3221536356 OR notes.tile BETWEEN 3221536360 AND 3221536364 OR notes.tile BETWEEN 3221536384 AND 3221536452 OR notes.tile BETWEEN 3221536456 AND 3221536460 OR notes.tile BETWEEN 3221536480 AND 3221536484 OR notes.tile BETWEEN 3221536488 AND 3221536492 OR notes.tile BETWEEN 3221618688 AND 3221621287 OR notes.tile BETWEEN 3221621296 AND 3221621303 OR notes.tile BETWEEN 3221621312 AND 3221621351 OR notes.tile BETWEEN 3221621360 AND 3221621367 OR notes.tile BETWEEN 3221621504 AND 3221621543 OR notes.tile BETWEEN 3221621552 AND 3221621559 OR notes.tile BETWEEN 3221621568 AND 3221621607 OR notes.tile BETWEEN 3221621616 AND 3221621623 OR notes.tile BETWEEN 3221621760 AND 3221622311 OR notes.tile BETWEEN 3221622320 AND 3221622327 OR notes.tile BETWEEN 3221622336 AND 3221622375 OR notes.tile BETWEEN 3221622384 AND 3221622391 OR notes.tile BETWEEN 3221622528 AND 3221622567 OR notes.tile BETWEEN 3221622576 AND 3221622583 OR notes.tile BETWEEN 3221622592 AND 3221622631 OR notes.tile BETWEEN 3221622640 AND 3221622647 OR notes.tile BETWEEN 3221622784 AND 3221623876 OR notes.tile BETWEEN 3221623880 AND 3221623884 OR notes.tile BETWEEN 3221623904 AND 3221623908 OR notes.tile BETWEEN 3221623912 AND 3221623916 OR notes.tile BETWEEN 3221623936 AND 3221624004 OR notes.tile BETWEEN 3221624008 AND 3221624012 OR notes.tile BETWEEN 3221624032 AND 3221624036 OR notes.tile BETWEEN 3221624040 AND 3221624044 OR notes.tile BETWEEN 3221624320 AND 3221624388 OR notes.tile BETWEEN 3221624392 AND 3221624396 OR notes.tile BETWEEN 3221624416 AND 3221624420 OR notes.tile BETWEEN 3221624424 AND 3221624428 OR notes.tile BETWEEN 3221624448 AND 3221624516 OR notes.tile BETWEEN 3221624520 AND 3221624524 OR notes.tile BETWEEN 3221624544 AND 3221624548 OR notes.tile BETWEEN 3221624552 AND 3221624556 OR notes.tile BETWEEN 3221624832 AND 3221625383 OR notes.tile BETWEEN 3221625392 AND 3221625399 OR notes.tile BETWEEN 3221625408 AND 3221625447 OR notes.tile BETWEEN 3221625456 AND 3221625463 OR notes.tile BETWEEN 3221625600 AND 3221625639 OR notes.tile BETWEEN 3221625648 AND 3221625655 OR notes.tile BETWEEN 3221625664 AND 3221625703 OR notes.tile BETWEEN 3221625712 AND 3221625719 OR notes.tile BETWEEN 3221625856 AND 3221625924 OR notes.tile BETWEEN 3221625928 AND 3221625932 OR notes.tile BETWEEN 3221625952 AND 3221625956 OR notes.tile BETWEEN 3221625960 AND 3221625964 OR notes.tile BETWEEN 3221625984 AND 3221626052 OR notes.tile BETWEEN 3221626056 AND 3221626060 OR notes.tile BETWEEN 3221626080 AND 3221626084 OR notes.tile BETWEEN 3221626088 AND 3221626092 OR notes.tile BETWEEN 3221626368 AND 3221626407 OR notes.tile BETWEEN 3221626416 AND 3221626423 OR notes.tile BETWEEN 3221626432 AND 3221626436 OR notes.tile BETWEEN 3221626440 AND 3221626444 OR notes.tile BETWEEN 3221626464 AND 3221626468 OR notes.tile IN (3221528174, 3221528262, 3221528270, 3221528294, 3221528302, 3221533766, 3221533774, 3221533798, 3221533806, 3221533894, 3221533902, 3221533926, 3221533934, 3221534278, 3221534286, 3221534310, 3221534318, 3221534406, 3221534414, 3221534438, 3221534446, 3221535814, 3221535822, 3221535846, 3221535854, 3221535942, 3221535950, 3221535974, 3221535982, 3221536326, 3221536334, 3221536358, 3221536366, 3221536454, 3221536462, 3221536486, 3221536494, 3221623878, 3221623886, 3221623910, 3221623918, 3221624006, 3221624014, 3221624038, 3221624046, 3221624390, 3221624398, 3221624422, 3221624430, 3221624518, 3221624526, 3221624550, 3221624558, 3221625926, 3221625934, 3221625958, 3221625966, 3221626054, 3221626062, 3221626086, 3221626094, 3221626438, 3221626446, 3221626470)) AND notes.longitude BETWEEN 10000000.0 AND 17000000.0 ORDER BY updated_at DESC LIMIT 1;
