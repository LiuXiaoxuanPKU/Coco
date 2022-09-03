{
    "org": {
        "sql": "SELECT 1 AS one FROM changeset_comments WHERE changeset_comments.id IS NULL LIMIT \"$1\"",
        "cost": 4.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM changeset_comments WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}