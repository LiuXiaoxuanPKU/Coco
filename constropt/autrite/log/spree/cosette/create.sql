CREATE TABLE action_mailbox_inbound_emails (
    id bigint NOT NULL,
    status integer   NOT NULL,
    message_id character varying NOT NULL,
    message_checksum character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE action_text_rich_texts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    body character varying,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
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
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
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

CREATE TABLE friendly_id_slugs (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    sluggable_id bigint NOT NULL,
    sluggable_type character varying(50),
    "scope" character varying,
    created_at timestamp without time zone,
    deleted_at timestamp without time zone
);

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

CREATE TABLE spree_addresses (
    id bigint NOT NULL,
    firstname character varying,
    lastname character varying,
    address1 character varying,
    address2 character varying,
    city character varying,
    zipcode character varying,
    phone character varying,
    state_name character varying,
    alternative_phone character varying,
    company character varying,
    state_id bigint,
    country_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint,
    deleted_at timestamp without time zone,
    label character varying,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_adjustments (
    id bigint NOT NULL,
    source_type character varying,
    source_id bigint,
    adjustable_type character varying,
    adjustable_id bigint,
    amount numeric(10,2),
    label character varying,
    mandatory boolean,
    eligible boolean  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "state" character varying,
    order_id bigint NOT NULL,
    included boolean  
);

CREATE TABLE spree_assets (
    id bigint NOT NULL,
    viewable_type character varying,
    viewable_id bigint,
    attachment_width integer,
    attachment_height integer,
    attachment_file_size integer,
    "position" integer,
    attachment_content_type character varying,
    attachment_file_name character varying,
    type character varying(75),
    attachment_updated_at timestamp without time zone,
    alt character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_calculators (
    id bigint NOT NULL,
    type character varying,
    calculable_type character varying,
    calculable_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    preferences character varying,
    deleted_at timestamp without time zone
);

CREATE TABLE spree_checks (
    id bigint NOT NULL,
    payment_method_id bigint,
    user_id bigint,
    account_holder_name character varying,
    account_holder_type character varying,
    routing_number character varying,
    account_number character varying,
    account_type character varying   ,
    status character varying,
    last_digits character varying,
    gateway_customer_profile_id character varying,
    gateway_payment_profile_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);

CREATE TABLE spree_cms_pages (
    id bigint NOT NULL,
    title character varying NOT NULL,
    meta_title character varying,
    content character varying,
    meta_description character varying,
    visible boolean  ,
    slug character varying,
    type character varying,
    locale character varying,
    deleted_at timestamp without time zone,
    store_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_cms_sections (
    id bigint NOT NULL,
    name character varying NOT NULL,
    content character varying,
    settings character varying,
    fit character varying,
    destination character varying,
    type character varying,
    "position" integer,
    linked_resource_type character varying,
    linked_resource_id bigint,
    cms_page_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_countries (
    id bigint NOT NULL,
    iso_name character varying,
    iso character varying NOT NULL,
    iso3 character varying NOT NULL,
    name character varying,
    numcode integer,
    states_required boolean  ,
    updated_at timestamp without time zone,
    zipcode_required boolean  ,
    created_at timestamp without time zone
);

CREATE TABLE spree_credit_cards (
    id bigint NOT NULL,
    "month" character varying,
    "year" character varying,
    cc_type character varying,
    last_digits character varying,
    address_id bigint,
    gateway_customer_profile_id character varying,
    gateway_payment_profile_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying,
    user_id bigint,
    payment_method_id bigint,
    "default" boolean   NOT NULL,
    deleted_at timestamp without time zone,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_customer_returns (
    id bigint NOT NULL,
    number character varying,
    stock_location_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    store_id bigint,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_digital_links (
    id bigint NOT NULL,
    digital_id bigint,
    line_item_id bigint,
    token character varying,
    access_counter integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_digitals (
    id bigint NOT NULL,
    variant_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_gateways (
    id bigint NOT NULL,
    type character varying,
    name character varying,
    description character varying,
    active boolean  ,
    environment character varying   ,
    server character varying   ,
    test_mode boolean  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    preferences character varying
);

CREATE TABLE spree_inventory_units (
    id bigint NOT NULL,
    "state" character varying,
    variant_id bigint,
    order_id bigint,
    shipment_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pending boolean  ,
    line_item_id bigint,
    quantity integer  ,
    original_return_item_id bigint
);

CREATE TABLE spree_line_items (
    id bigint NOT NULL,
    variant_id bigint,
    order_id bigint,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    currency character varying,
    cost_price numeric(10,2),
    tax_category_id bigint,
    adjustment_total numeric(10,2)  ,
    additional_tax_total numeric(10,2)  ,
    promo_total numeric(10,2)  ,
    included_tax_total numeric(10,2)   NOT NULL,
    pre_tax_amount numeric(12,4)   NOT NULL,
    taxable_adjustment_total numeric(10,2)   NOT NULL,
    non_taxable_adjustment_total numeric(10,2)   NOT NULL,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_log_entries (
    id bigint NOT NULL,
    source_type character varying,
    source_id bigint,
    details character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_menu_items (
    id bigint NOT NULL,
    name character varying NOT NULL,
    subtitle character varying,
    destination character varying,
    new_window boolean  ,
    item_type character varying,
    linked_resource_type character varying   ,
    linked_resource_id bigint,
    code character varying,
    parent_id bigint,
    lft bigint NOT NULL,
    rgt bigint NOT NULL,
    depth integer   NOT NULL,
    menu_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_menus (
    id bigint NOT NULL,
    name character varying,
    location character varying,
    locale character varying,
    store_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying,
    resource_owner_type character varying NOT NULL
);

CREATE TABLE spree_oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id bigint,
    application_id bigint,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying    NOT NULL,
    resource_owner_type character varying
);

CREATE TABLE spree_oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri character varying NOT NULL,
    scopes character varying    NOT NULL,
    confidential boolean   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_option_type_prototypes (
    id bigint NOT NULL,
    prototype_id bigint,
    option_type_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_option_types (
    id bigint NOT NULL,
    name character varying(100),
    presentation character varying(100),
    "position" integer   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    filterable boolean   NOT NULL,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_option_value_variants (
    id bigint NOT NULL,
    variant_id bigint,
    option_value_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_option_values (
    id bigint NOT NULL,
    "position" integer,
    name character varying,
    presentation character varying,
    option_type_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_order_promotions (
    id bigint NOT NULL,
    order_id bigint,
    promotion_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_orders (
    id bigint NOT NULL,
    number character varying(32),
    item_total numeric(10,2)   NOT NULL,
    total numeric(10,2)   NOT NULL,
    "state" character varying,
    adjustment_total numeric(10,2)   NOT NULL,
    user_id bigint,
    completed_at timestamp without time zone,
    bill_address_id bigint,
    ship_address_id bigint,
    payment_total numeric(10,2)  ,
    shipment_state character varying,
    payment_state character varying,
    email character varying,
    special_instructions character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    currency character varying,
    last_ip_address character varying,
    created_by_id bigint,
    shipment_total numeric(10,2)   NOT NULL,
    additional_tax_total numeric(10,2)  ,
    promo_total numeric(10,2)  ,
    channel character varying   ,
    included_tax_total numeric(10,2)   NOT NULL,
    item_count integer  ,
    approver_id bigint,
    approved_at timestamp without time zone,
    confirmation_delivered boolean  ,
    considered_risky boolean  ,
    token character varying,
    canceled_at timestamp without time zone,
    canceler_id bigint,
    store_id bigint,
    state_lock_version integer   NOT NULL,
    taxable_adjustment_total numeric(10,2)   NOT NULL,
    non_taxable_adjustment_total numeric(10,2)   NOT NULL,
    store_owner_notification_delivered boolean,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_payment_capture_events (
    id bigint NOT NULL,
    amount numeric(10,2)  ,
    payment_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_payment_methods (
    id bigint NOT NULL,
    type character varying,
    name character varying,
    description character varying,
    active boolean  ,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    display_on character varying   ,
    auto_capture boolean,
    preferences character varying,
    "position" integer  ,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_payment_methods_stores (
    payment_method_id bigint,
    store_id bigint
);

CREATE TABLE spree_payments (
    id bigint NOT NULL,
    amount numeric(10,2)   NOT NULL,
    order_id bigint,
    source_type character varying,
    source_id bigint,
    payment_method_id bigint,
    "state" character varying,
    response_code character varying,
    avs_response character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    number character varying,
    cvv_response_code character varying,
    cvv_response_message character varying,
    public_metadata character varying,
    private_metadata character varying,
    intent_client_key character varying
);

CREATE TABLE spree_preferences (
    id bigint NOT NULL,
    "value" character varying,
    "key" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_prices (
    id bigint NOT NULL,
    variant_id bigint NOT NULL,
    amount numeric(10,2),
    currency character varying,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    compare_at_amount numeric(10,2)
);

CREATE TABLE spree_product_option_types (
    id bigint NOT NULL,
    "position" integer,
    product_id bigint,
    option_type_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_product_promotion_rules (
    id bigint NOT NULL,
    product_id bigint,
    promotion_rule_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_product_properties (
    id bigint NOT NULL,
    "value" character varying,
    product_id bigint,
    property_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "position" integer  ,
    show_property boolean  ,
    filter_param character varying
);

CREATE TABLE spree_products (
    id bigint NOT NULL,
    name character varying    NOT NULL,
    description character varying,
    available_on timestamp without time zone,
    deleted_at timestamp without time zone,
    slug character varying,
    meta_description character varying,
    meta_keywords character varying,
    tax_category_id bigint,
    shipping_category_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    promotionable boolean  ,
    meta_title character varying,
    discontinue_on timestamp without time zone,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_products_stores (
    id bigint NOT NULL,
    product_id bigint,
    store_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_products_taxons (
    id bigint NOT NULL,
    product_id bigint,
    taxon_id bigint,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_promotion_action_line_items (
    id bigint NOT NULL,
    promotion_action_id bigint,
    variant_id bigint,
    quantity integer  ,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_promotion_actions (
    id bigint NOT NULL,
    promotion_id bigint,
    "position" integer,
    type character varying,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_promotion_categories (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    code character varying
);

CREATE TABLE spree_promotion_rule_taxons (
    id bigint NOT NULL,
    taxon_id bigint,
    promotion_rule_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_promotion_rule_users (
    id bigint NOT NULL,
    user_id bigint,
    promotion_rule_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_promotion_rules (
    id bigint NOT NULL,
    promotion_id bigint,
    user_id bigint,
    product_group_id bigint,
    type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    code character varying,
    preferences character varying
);

CREATE TABLE spree_promotions (
    id bigint NOT NULL,
    description character varying,
    expires_at timestamp without time zone,
    starts_at timestamp without time zone,
    name character varying,
    type character varying,
    usage_limit integer,
    match_policy character varying   ,
    code character varying,
    advertise boolean  ,
    "path" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    promotion_category_id bigint,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_promotions_stores (
    id bigint NOT NULL,
    promotion_id bigint,
    store_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_properties (
    id bigint NOT NULL,
    name character varying,
    presentation character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    filterable boolean   NOT NULL,
    filter_param character varying,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_property_prototypes (
    id bigint NOT NULL,
    prototype_id bigint,
    property_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_prototype_taxons (
    id bigint NOT NULL,
    taxon_id bigint,
    prototype_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_prototypes (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_refund_reasons (
    id bigint NOT NULL,
    name character varying,
    active boolean  ,
    mutable boolean  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_refunds (
    id bigint NOT NULL,
    payment_id bigint,
    amount numeric(10,2)   NOT NULL,
    transaction_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    refund_reason_id bigint,
    reimbursement_id bigint,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_reimbursement_credits (
    id bigint NOT NULL,
    amount numeric(10,2)   NOT NULL,
    reimbursement_id bigint,
    creditable_id bigint,
    creditable_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_reimbursement_types (
    id bigint NOT NULL,
    name character varying,
    active boolean  ,
    mutable boolean  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    type character varying
);

CREATE TABLE spree_reimbursements (
    id bigint NOT NULL,
    number character varying,
    reimbursement_status character varying,
    customer_return_id bigint,
    order_id bigint,
    total numeric(10,2),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_return_authorization_reasons (
    id bigint NOT NULL,
    name character varying,
    active boolean  ,
    mutable boolean  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_return_authorizations (
    id bigint NOT NULL,
    number character varying,
    "state" character varying,
    order_id bigint,
    memo character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    stock_location_id bigint,
    return_authorization_reason_id bigint
);

CREATE TABLE spree_return_items (
    id bigint NOT NULL,
    return_authorization_id bigint,
    inventory_unit_id bigint,
    exchange_variant_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pre_tax_amount numeric(12,4)   NOT NULL,
    included_tax_total numeric(12,4)   NOT NULL,
    additional_tax_total numeric(12,4)   NOT NULL,
    reception_status character varying,
    acceptance_status character varying,
    customer_return_id bigint,
    reimbursement_id bigint,
    acceptance_status_errors character varying,
    preferred_reimbursement_type_id bigint,
    override_reimbursement_type_id bigint,
    resellable boolean   NOT NULL
);

CREATE TABLE spree_role_users (
    id bigint NOT NULL,
    role_id bigint,
    user_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_roles (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_shipments (
    id bigint NOT NULL,
    tracking character varying,
    number character varying,
    cost numeric(10,2)  ,
    shipped_at timestamp without time zone,
    order_id bigint,
    address_id bigint,
    "state" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    stock_location_id bigint,
    adjustment_total numeric(10,2)  ,
    additional_tax_total numeric(10,2)  ,
    promo_total numeric(10,2)  ,
    included_tax_total numeric(10,2)   NOT NULL,
    pre_tax_amount numeric(12,4)   NOT NULL,
    taxable_adjustment_total numeric(10,2)   NOT NULL,
    non_taxable_adjustment_total numeric(10,2)   NOT NULL,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_shipping_categories (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_shipping_method_categories (
    id bigint NOT NULL,
    shipping_method_id bigint NOT NULL,
    shipping_category_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_shipping_method_zones (
    id bigint NOT NULL,
    shipping_method_id bigint,
    zone_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE TABLE spree_shipping_methods (
    id bigint NOT NULL,
    name character varying,
    display_on character varying,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tracking_url character varying,
    admin_name character varying,
    tax_category_id bigint,
    code character varying,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_shipping_rates (
    id bigint NOT NULL,
    shipment_id bigint,
    shipping_method_id bigint,
    selected boolean  ,
    cost numeric(8,2)  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tax_rate_id bigint
);

CREATE TABLE spree_state_changes (
    id bigint NOT NULL,
    name character varying,
    previous_state character varying,
    stateful_id bigint,
    user_id bigint,
    stateful_type character varying,
    next_state character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_states (
    id bigint NOT NULL,
    name character varying,
    abbr character varying,
    country_id bigint,
    updated_at timestamp without time zone,
    created_at timestamp without time zone
);

CREATE TABLE spree_stock_items (
    id bigint NOT NULL,
    stock_location_id bigint,
    variant_id bigint,
    count_on_hand integer   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    backorderable boolean  ,
    deleted_at timestamp without time zone
);

CREATE TABLE spree_stock_locations (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "default" boolean   NOT NULL,
    address1 character varying,
    address2 character varying,
    city character varying,
    state_id bigint,
    state_name character varying,
    country_id bigint,
    zipcode character varying,
    phone character varying,
    active boolean  ,
    backorderable_default boolean  ,
    propagate_all_variants boolean  ,
    admin_name character varying
);

CREATE TABLE spree_stock_movements (
    id bigint NOT NULL,
    stock_item_id bigint,
    quantity integer  ,
    action character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    originator_type character varying,
    originator_id bigint
);

CREATE TABLE spree_stock_transfers (
    id bigint NOT NULL,
    type character varying,
    reference character varying,
    source_location_id bigint,
    destination_location_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    number character varying,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_store_credit_categories (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_store_credit_events (
    id bigint NOT NULL,
    store_credit_id bigint NOT NULL,
    action character varying NOT NULL,
    amount numeric(8,2),
    authorization_code character varying NOT NULL,
    user_total_amount numeric(8,2)   NOT NULL,
    originator_id bigint,
    originator_type character varying,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_store_credit_types (
    id bigint NOT NULL,
    name character varying,
    priority integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_store_credits (
    id bigint NOT NULL,
    user_id bigint,
    category_id bigint,
    created_by_id bigint,
    amount numeric(8,2)   NOT NULL,
    amount_used numeric(8,2)   NOT NULL,
    memo character varying,
    deleted_at timestamp without time zone,
    currency character varying,
    amount_authorized numeric(8,2)   NOT NULL,
    originator_id bigint,
    originator_type character varying,
    type_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    store_id bigint,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_stores (
    id bigint NOT NULL,
    name character varying,
    url character varying,
    meta_description character varying,
    meta_keywords character varying,
    seo_title character varying,
    mail_from_address character varying,
    default_currency character varying,
    code character varying,
    "default" boolean   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    supported_currencies character varying,
    facebook character varying,
    twitter character varying,
    instagram character varying,
    default_locale character varying,
    customer_support_email character varying,
    default_country_id bigint,
    description character varying,
    address character varying,
    contact_phone character varying,
    new_order_notifications_email character varying,
    checkout_zone_id bigint,
    seo_robots character varying,
    supported_locales character varying,
    deleted_at timestamp without time zone,
    settings character varying
);

CREATE TABLE spree_tax_categories (
    id bigint NOT NULL,
    name character varying,
    description character varying,
    is_default boolean  ,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tax_code character varying
);

CREATE TABLE spree_tax_rates (
    id bigint NOT NULL,
    amount numeric(8,5),
    zone_id bigint,
    tax_category_id bigint,
    included_in_price boolean  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying,
    show_rate_in_label boolean  ,
    deleted_at timestamp without time zone
);

CREATE TABLE spree_taxonomies (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "position" integer  ,
    store_id bigint,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_taxons (
    id bigint NOT NULL,
    parent_id bigint,
    "position" integer  ,
    name character varying NOT NULL,
    permalink character varying,
    taxonomy_id bigint,
    lft bigint,
    rgt bigint,
    description character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    meta_title character varying,
    meta_description character varying,
    meta_keywords character varying,
    depth integer,
    hide_from_nav boolean  ,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_trackers (
    id bigint NOT NULL,
    analytics_id character varying,
    active boolean  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    engine integer   NOT NULL
);

CREATE TABLE spree_users (
    id bigint NOT NULL,
    encrypted_password character varying(128),
    password_salt character varying(128),
    email character varying,
    remember_token character varying,
    persistence_token character varying,
    reset_password_token character varying,
    perishable_token character varying,
    sign_in_count integer   NOT NULL,
    failed_attempts integer   NOT NULL,
    last_request_at timestamp without time zone,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    login character varying,
    ship_address_id bigint,
    bill_address_id bigint,
    authentication_token character varying,
    unlock_token character varying,
    locked_at timestamp without time zone,
    reset_password_sent_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    public_metadata character varying,
    private_metadata character varying,
    spree_api_key character varying(48),
    remember_created_at timestamp without time zone,
    deleted_at timestamp without time zone,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone
);

CREATE TABLE spree_variants (
    id bigint NOT NULL,
    sku character varying    NOT NULL,
    weight numeric(8,2)  ,
    height numeric(8,2),
    width numeric(8,2),
    depth numeric(8,2),
    deleted_at timestamp without time zone,
    is_master boolean  ,
    product_id bigint,
    cost_price numeric(10,2),
    "position" integer,
    cost_currency character varying,
    track_inventory boolean  ,
    tax_category_id bigint,
    updated_at timestamp without time zone NOT NULL,
    discontinue_on timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    public_metadata character varying,
    private_metadata character varying
);

CREATE TABLE spree_webhooks_events (
    id bigint NOT NULL,
    execution_time integer,
    name character varying NOT NULL,
    request_errors character varying,
    response_code character varying,
    subscriber_id bigint NOT NULL,
    success boolean,
    url character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_webhooks_subscribers (
    id bigint NOT NULL,
    url character varying NOT NULL,
    active boolean  ,
    subscriptions character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_wished_items (
    id bigint NOT NULL,
    variant_id bigint,
    wishlist_id bigint,
    quantity integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_wishlists (
    id bigint NOT NULL,
    user_id bigint,
    store_id bigint,
    name character varying,
    token character varying NOT NULL,
    is_private boolean   NOT NULL,
    is_default boolean   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE spree_zone_members (
    id bigint NOT NULL,
    zoneable_type character varying,
    zoneable_id bigint,
    zone_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE spree_zones (
    id bigint NOT NULL,
    name character varying,
    description character varying,
    default_tax boolean  ,
    zone_members_count integer  ,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    kind character varying   
);

