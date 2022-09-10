{
    "org": {
        "sql": "SELECT mentions.status_id, mentions.account_id FROM mentions WHERE mentions.silent = \"$1\" AND mentions.status_id IN (\"$2\", \"$3\")",
        "cost": 19.03,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT mentions.status_id, mentions.account_id FROM mentions WHERE mentions.silent = \"$1\" AND mentions.status_id IN (\"$2\", \"$3\") LIMIT 1",
            "cost": 10.46,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}