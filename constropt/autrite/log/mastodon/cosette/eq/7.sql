{
    "org": {
        "sql": "SELECT account_domain_blocks.domain FROM account_domain_blocks WHERE account_domain_blocks.account_id = \"$1\"",
        "cost": 4.32
    },
    "rewrites": [
        {
            "sql": "SELECT account_domain_blocks.domain FROM account_domain_blocks WHERE account_domain_blocks.account_id = \"$1\" LIMIT 1",
            "cost": 2.3,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}