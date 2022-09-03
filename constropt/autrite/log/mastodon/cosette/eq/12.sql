{
    "org": {
        "sql": "SELECT 1 AS one FROM webauthn_credentials WHERE webauthn_credentials.nickname IS NULL AND webauthn_credentials.user_id IS NULL LIMIT \"$1\"",
        "cost": 8.3
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM webauthn_credentials WHERE False AND webauthn_credentials.user_id IS NULL LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}