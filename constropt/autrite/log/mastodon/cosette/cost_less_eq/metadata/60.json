{
    "org": {
        "sql": "SELECT 1 AS one FROM follow_requests WHERE follow_requests.account_id = \"$1\" AND follow_requests.target_account_id IS NULL LIMIT \"$2\"",
        "cost": 8.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM follow_requests WHERE follow_requests.account_id = \"$1\" AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}