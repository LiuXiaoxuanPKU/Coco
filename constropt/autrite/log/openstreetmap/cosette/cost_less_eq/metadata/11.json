{
    "org": {
        "sql": "SELECT users.* FROM users WHERE users.status IN (\"$1\", \"$2\") AND users.display_name IS NULL LIMIT \"$3\"",
        "cost": 8.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT users.* FROM users WHERE users.status IN (\"$1\", \"$2\") AND False LIMIT \"$3\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}