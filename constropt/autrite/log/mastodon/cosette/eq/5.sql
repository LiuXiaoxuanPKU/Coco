{
    "org": {
        "sql": "SELECT 1 AS one FROM blocks WHERE blocks.account_id IS NULL AND blocks.target_account_id IS NULL LIMIT \"$1\"",
        "cost": 4.3
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM blocks WHERE False AND blocks.target_account_id IS NULL LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM blocks WHERE blocks.account_id IS NULL AND False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM blocks WHERE False AND False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        }
    ]
}