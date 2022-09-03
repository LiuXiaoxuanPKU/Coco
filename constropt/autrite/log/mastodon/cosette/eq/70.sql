{
    "org": {
        "sql": "SELECT accounts.id, accounts.username, accounts.domain, accounts.private_key, accounts.public_key, accounts.created_at, accounts.updated_at, accounts.note, accounts.display_name, accounts.uri, accounts.url, accounts.avatar_file_name, accounts.avatar_content_type, accounts.avatar_file_size, accounts.avatar_updated_at, accounts.header_file_name, accounts.header_content_type, accounts.header_file_size, accounts.header_updated_at, accounts.avatar_remote_url, accounts.locked, accounts.header_remote_url, accounts.last_webfingered_at, accounts.inbox_url, accounts.outbox_url, accounts.shared_inbox_url, accounts.followers_url, accounts.protocol, accounts.memorial, accounts.moved_to_account_id, accounts.featured_collection_url, accounts.fields, accounts.actor_type, accounts.discoverable, accounts.also_known_as, accounts.silenced_at, accounts.suspended_at, accounts.hide_collections, accounts.avatar_storage_schema_version, accounts.header_storage_schema_version, accounts.devices_url, accounts.suspension_origin, accounts.sensitized_at, accounts.trendable, accounts.reviewed_at, accounts.requested_review_at FROM accounts INNER JOIN account_pins ON accounts.id = account_pins.target_account_id WHERE account_pins.account_id = \"$1\"",
        "cost": 20.93
    },
    "rewrites": [
        {
            "sql": "SELECT accounts.id, accounts.username, accounts.domain, accounts.private_key, accounts.public_key, accounts.created_at, accounts.updated_at, accounts.note, accounts.display_name, accounts.uri, accounts.url, accounts.avatar_file_name, accounts.avatar_content_type, accounts.avatar_file_size, accounts.avatar_updated_at, accounts.header_file_name, accounts.header_content_type, accounts.header_file_size, accounts.header_updated_at, accounts.avatar_remote_url, accounts.locked, accounts.header_remote_url, accounts.last_webfingered_at, accounts.inbox_url, accounts.outbox_url, accounts.shared_inbox_url, accounts.followers_url, accounts.protocol, accounts.memorial, accounts.moved_to_account_id, accounts.featured_collection_url, accounts.fields, accounts.actor_type, accounts.discoverable, accounts.also_known_as, accounts.silenced_at, accounts.suspended_at, accounts.hide_collections, accounts.avatar_storage_schema_version, accounts.header_storage_schema_version, accounts.devices_url, accounts.suspension_origin, accounts.sensitized_at, accounts.trendable, accounts.reviewed_at, accounts.requested_review_at FROM accounts INNER JOIN account_pins ON accounts.id = account_pins.target_account_id WHERE account_pins.account_id = \"$1\" LIMIT 1",
            "cost": 10.75,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        }
    ]
}