{
    "org": {
        "sql": "SELECT 1 AS one FROM changesets WHERE changesets.id IS NULL LIMIT \"$1\"",
        "cost": 4.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM changesets WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}