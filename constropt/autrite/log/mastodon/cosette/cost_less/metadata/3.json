{
    "org": {
        "sql": "SELECT 1 AS one FROM domain_blocks WHERE domain_blocks.domain IS NULL LIMIT \"$1\"",
        "cost": 8.43,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM domain_blocks WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}