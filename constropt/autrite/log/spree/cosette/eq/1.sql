{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_stores WHERE spree_stores.code IS NULL LIMIT \"$1\"",
        "cost": 8.43,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_stores WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}