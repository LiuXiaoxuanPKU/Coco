{
    "org": {
        "sql": "SELECT changesets.* FROM changesets WHERE closed_at < '2022-08-29 21:22:12.547375' OR num_changes > 10000 ORDER BY created_at DESC LIMIT \"$1\"",
        "cost": 0.77,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT changesets.* FROM changesets WHERE closed_at < '2022-08-29 21:22:12.547375' ORDER BY created_at DESC LIMIT \"$1\"",
            "cost": 0.75,
            "rewrite_types": [
                "RemovePredicate"
            ]
        }
    ]
}