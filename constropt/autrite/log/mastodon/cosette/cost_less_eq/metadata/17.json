{
    "org": {
        "sql": "SELECT 1 AS one FROM webauthn_credentials WHERE webauthn_credentials.external_id IS NULL LIMIT \"$1\"",
        "cost": 4.43,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM webauthn_credentials WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}