{
    "org": {
        "sql": "SELECT 1 AS one FROM users WHERE users.display_name IS NULL LIMIT \"$1\"",
        "cost": 8.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM users WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}