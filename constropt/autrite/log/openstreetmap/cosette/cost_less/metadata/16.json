{
    "org": {
        "sql": "SELECT changesets.* FROM changesets WHERE closed_at >= '2022-08-29 21:22:12.528622' AND num_changes <= 10000 ORDER BY created_at DESC LIMIT \"$1\"",
        "cost": 24.38,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT changesets.* FROM changesets WHERE closed_at >= '2022-08-29 21:22:12.528622' ORDER BY created_at DESC LIMIT \"$1\"",
            "cost": 24.37,
            "rewrite_types": [
                "RemovePredicate"
            ]
        }
    ]
}