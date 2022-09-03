{
    "org": {
        "sql": "SELECT accounts.id AS t0_r0, accounts.username AS t0_r1, accounts.domain AS t0_r2, accounts.private_key AS t0_r3, accounts.public_key AS t0_r4, accounts.created_at AS t0_r5, accounts.updated_at AS t0_r6, accounts.note AS t0_r7, accounts.display_name AS t0_r8, accounts.uri AS t0_r9, accounts.url AS t0_r10, accounts.avatar_file_name AS t0_r11, accounts.avatar_content_type AS t0_r12, accounts.avatar_file_size AS t0_r13, accounts.avatar_updated_at AS t0_r14, accounts.header_file_name AS t0_r15, accounts.header_content_type AS t0_r16, accounts.header_file_size AS t0_r17, accounts.header_updated_at AS t0_r18, accounts.avatar_remote_url AS t0_r19, accounts.locked AS t0_r20, accounts.header_remote_url AS t0_r21, accounts.last_webfingered_at AS t0_r22, accounts.inbox_url AS t0_r23, accounts.outbox_url AS t0_r24, accounts.shared_inbox_url AS t0_r25, accounts.followers_url AS t0_r26, accounts.protocol AS t0_r27, accounts.memorial AS t0_r28, accounts.moved_to_account_id AS t0_r29, accounts.featured_collection_url AS t0_r30, accounts.fields AS t0_r31, accounts.actor_type AS t0_r32, accounts.discoverable AS t0_r33, accounts.also_known_as AS t0_r34, accounts.silenced_at AS t0_r35, accounts.suspended_at AS t0_r36, accounts.hide_collections AS t0_r37, accounts.avatar_storage_schema_version AS t0_r38, accounts.header_storage_schema_version AS t0_r39, accounts.devices_url AS t0_r40, accounts.suspension_origin AS t0_r41, accounts.sensitized_at AS t0_r42, accounts.trendable AS t0_r43, accounts.reviewed_at AS t0_r44, accounts.requested_review_at AS t0_r45, follows.id AS t1_r0, follows.created_at AS t1_r1, follows.updated_at AS t1_r2, follows.account_id AS t1_r3, follows.target_account_id AS t1_r4, follows.show_reblogs AS t1_r5, follows.uri AS t1_r6, follows.notify AS t1_r7, account_stats.id AS t2_r0, account_stats.account_id AS t2_r1, account_stats.statuses_count AS t2_r2, account_stats.following_count AS t2_r3, account_stats.followers_count AS t2_r4, account_stats.created_at AS t2_r5, account_stats.updated_at AS t2_r6, account_stats.last_status_at AS t2_r7 FROM accounts LEFT OUTER JOIN follows ON follows.target_account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE 1 = 1 AND follows.account_id = \"$1\" AND accounts.id IN (\"$2\", \"$3\") ORDER BY follows.id DESC",
        "cost": 31.96,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT accounts.id AS t0_r0, accounts.username AS t0_r1, accounts.domain AS t0_r2, accounts.private_key AS t0_r3, accounts.public_key AS t0_r4, accounts.created_at AS t0_r5, accounts.updated_at AS t0_r6, accounts.note AS t0_r7, accounts.display_name AS t0_r8, accounts.uri AS t0_r9, accounts.url AS t0_r10, accounts.avatar_file_name AS t0_r11, accounts.avatar_content_type AS t0_r12, accounts.avatar_file_size AS t0_r13, accounts.avatar_updated_at AS t0_r14, accounts.header_file_name AS t0_r15, accounts.header_content_type AS t0_r16, accounts.header_file_size AS t0_r17, accounts.header_updated_at AS t0_r18, accounts.avatar_remote_url AS t0_r19, accounts.locked AS t0_r20, accounts.header_remote_url AS t0_r21, accounts.last_webfingered_at AS t0_r22, accounts.inbox_url AS t0_r23, accounts.outbox_url AS t0_r24, accounts.shared_inbox_url AS t0_r25, accounts.followers_url AS t0_r26, accounts.protocol AS t0_r27, accounts.memorial AS t0_r28, accounts.moved_to_account_id AS t0_r29, accounts.featured_collection_url AS t0_r30, accounts.fields AS t0_r31, accounts.actor_type AS t0_r32, accounts.discoverable AS t0_r33, accounts.also_known_as AS t0_r34, accounts.silenced_at AS t0_r35, accounts.suspended_at AS t0_r36, accounts.hide_collections AS t0_r37, accounts.avatar_storage_schema_version AS t0_r38, accounts.header_storage_schema_version AS t0_r39, accounts.devices_url AS t0_r40, accounts.suspension_origin AS t0_r41, accounts.sensitized_at AS t0_r42, accounts.trendable AS t0_r43, accounts.reviewed_at AS t0_r44, accounts.requested_review_at AS t0_r45, follows.id AS t1_r0, follows.created_at AS t1_r1, follows.updated_at AS t1_r2, follows.account_id AS t1_r3, follows.target_account_id AS t1_r4, follows.show_reblogs AS t1_r5, follows.uri AS t1_r6, follows.notify AS t1_r7, account_stats.id AS t2_r0, account_stats.account_id AS t2_r1, account_stats.statuses_count AS t2_r2, account_stats.following_count AS t2_r3, account_stats.followers_count AS t2_r4, account_stats.created_at AS t2_r5, account_stats.updated_at AS t2_r6, account_stats.last_status_at AS t2_r7 FROM accounts LEFT OUTER JOIN follows ON follows.target_account_id = accounts.id INNER JOIN account_stats ON account_stats.account_id = accounts.id WHERE 1 = 1 AND follows.account_id = \"$1\" AND accounts.id IN (\"$2\", \"$3\") ORDER BY follows.id DESC",
            "cost": 17.94,
            "rewrite_types": [
                "ReplaceOuterJoin"
            ]
        },
        {
            "sql": "SELECT accounts.id AS t0_r0, accounts.username AS t0_r1, accounts.domain AS t0_r2, accounts.private_key AS t0_r3, accounts.public_key AS t0_r4, accounts.created_at AS t0_r5, accounts.updated_at AS t0_r6, accounts.note AS t0_r7, accounts.display_name AS t0_r8, accounts.uri AS t0_r9, accounts.url AS t0_r10, accounts.avatar_file_name AS t0_r11, accounts.avatar_content_type AS t0_r12, accounts.avatar_file_size AS t0_r13, accounts.avatar_updated_at AS t0_r14, accounts.header_file_name AS t0_r15, accounts.header_content_type AS t0_r16, accounts.header_file_size AS t0_r17, accounts.header_updated_at AS t0_r18, accounts.avatar_remote_url AS t0_r19, accounts.locked AS t0_r20, accounts.header_remote_url AS t0_r21, accounts.last_webfingered_at AS t0_r22, accounts.inbox_url AS t0_r23, accounts.outbox_url AS t0_r24, accounts.shared_inbox_url AS t0_r25, accounts.followers_url AS t0_r26, accounts.protocol AS t0_r27, accounts.memorial AS t0_r28, accounts.moved_to_account_id AS t0_r29, accounts.featured_collection_url AS t0_r30, accounts.fields AS t0_r31, accounts.actor_type AS t0_r32, accounts.discoverable AS t0_r33, accounts.also_known_as AS t0_r34, accounts.silenced_at AS t0_r35, accounts.suspended_at AS t0_r36, accounts.hide_collections AS t0_r37, accounts.avatar_storage_schema_version AS t0_r38, accounts.header_storage_schema_version AS t0_r39, accounts.devices_url AS t0_r40, accounts.suspension_origin AS t0_r41, accounts.sensitized_at AS t0_r42, accounts.trendable AS t0_r43, accounts.reviewed_at AS t0_r44, accounts.requested_review_at AS t0_r45, follows.id AS t1_r0, follows.created_at AS t1_r1, follows.updated_at AS t1_r2, follows.account_id AS t1_r3, follows.target_account_id AS t1_r4, follows.show_reblogs AS t1_r5, follows.uri AS t1_r6, follows.notify AS t1_r7, account_stats.id AS t2_r0, account_stats.account_id AS t2_r1, account_stats.statuses_count AS t2_r2, account_stats.following_count AS t2_r3, account_stats.followers_count AS t2_r4, account_stats.created_at AS t2_r5, account_stats.updated_at AS t2_r6, account_stats.last_status_at AS t2_r7 FROM accounts LEFT OUTER JOIN follows ON follows.target_account_id = accounts.id INNER JOIN account_stats ON account_stats.account_id = accounts.id WHERE 1 = 1 AND follows.account_id = \"$1\" AND accounts.id IN (\"$2\", \"$3\") ORDER BY follows.id DESC LIMIT 1",
            "cost": 17.94,
            "rewrite_types": [
                "AddLimitOne",
                "ReplaceOuterJoin"
            ]
        }
    ]
}