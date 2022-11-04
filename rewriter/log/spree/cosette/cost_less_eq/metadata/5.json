{
    "org": {
        "sql": "SELECT spree_stock_locations.* FROM spree_stock_locations WHERE spree_stock_locations.name IS NULL LIMIT \"$1\"",
        "cost": 225.0,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_stock_locations.* FROM spree_stock_locations WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}