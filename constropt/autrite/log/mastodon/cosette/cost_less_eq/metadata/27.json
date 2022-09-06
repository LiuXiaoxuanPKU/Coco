{
    "org": {
        "sql": "SELECT webauthn_credentials.external_id FROM webauthn_credentials WHERE webauthn_credentials.user_id = \"$1\"",
        "cost": 11.97,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT webauthn_credentials.external_id FROM webauthn_credentials WHERE webauthn_credentials.user_id = \"$1\" LIMIT 1",
            "cost": 6.3,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}