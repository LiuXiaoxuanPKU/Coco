{
    "org": {
        "sql": "SELECT user_tokens.* FROM user_tokens WHERE user_tokens.token IS NULL LIMIT \"$1\"",
        "cost": 8.43,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT user_tokens.* FROM user_tokens WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}