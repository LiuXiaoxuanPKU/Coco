{
    "org": {
        "sql": "SELECT spree_option_types.* FROM spree_option_types WHERE 1 = 1 AND spree_option_types.position IS NOT NULL ORDER BY spree_option_types.position DESC LIMIT \"$1\"",
        "cost": 43.99,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_option_types.* FROM spree_option_types WHERE 1 = 1 AND True ORDER BY spree_option_types.position DESC LIMIT \"$1\"",
            "cost": 43.96,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}