{
    "org": {
        "sql": "SELECT blocks.account_id FROM blocks WHERE blocks.target_account_id = \"$1\"",
        "cost": 11.66,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT blocks.account_id FROM blocks WHERE blocks.target_account_id = \"$1\" LIMIT 1",
            "cost": 6.3,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}