{
    "org": {
        "sql": "SELECT changesets.* FROM changesets WHERE changesets.user_id = \"$1\" AND (closed_at < '2022-08-29 21:22:12.741412' OR num_changes > 10000) ORDER BY created_at DESC LIMIT \"$2\"",
        "cost": 24.4,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT changesets.* FROM changesets WHERE changesets.user_id = \"$1\" AND closed_at < '2022-08-29 21:22:12.741412' ORDER BY created_at DESC LIMIT \"$2\"",
            "cost": 24.38,
            "rewrite_types": [
                "RemovePredicate"
            ]
        }
    ]
}