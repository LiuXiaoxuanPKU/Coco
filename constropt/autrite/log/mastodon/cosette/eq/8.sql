{
    "org": {
        "sql": "SELECT 1 AS one FROM follows WHERE follows.account_id IS NULL AND follows.target_account_id IS NULL LIMIT \"$1\"",
        "cost": 4.3
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM follows WHERE False AND follows.target_account_id IS NULL LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM follows WHERE follows.account_id IS NULL AND False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM follows WHERE False AND False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        }
    ]
}