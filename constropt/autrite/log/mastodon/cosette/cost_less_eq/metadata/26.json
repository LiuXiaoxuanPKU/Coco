{
    "org": {
        "sql": "SELECT 1 AS one FROM follows WHERE follows.account_id = \"$1\" AND follows.target_account_id IS NULL LIMIT \"$2\"",
        "cost": 4.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM follows WHERE follows.account_id = \"$1\" AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}