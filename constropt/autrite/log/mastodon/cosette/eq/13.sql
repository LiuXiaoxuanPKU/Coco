{
    "org": {
        "sql": "SELECT 1 AS one FROM account_domain_blocks WHERE account_domain_blocks.account_id = \"$1\" AND account_domain_blocks.domain IS NULL LIMIT \"$2\"",
        "cost": 4.3
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM account_domain_blocks WHERE account_domain_blocks.account_id = \"$1\" AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}