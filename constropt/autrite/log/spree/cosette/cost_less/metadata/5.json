{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_menus WHERE spree_menus.location = \"$1\" AND spree_menus.store_id = \"$2\" AND spree_menus.locale IS NULL LIMIT \"$3\"",
        "cost": 8.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_menus WHERE spree_menus.location = \"$1\" AND spree_menus.store_id = \"$2\" AND False LIMIT \"$3\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}