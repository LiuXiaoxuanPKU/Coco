{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_menus WHERE spree_menus.location IS NULL AND spree_menus.store_id = \"$1\" AND spree_menus.locale IS NULL LIMIT \"$2\"",
        "cost": 8.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_menus WHERE spree_menus.location IS NULL AND spree_menus.store_id = \"$1\" AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_menus WHERE False AND spree_menus.store_id = \"$1\" AND spree_menus.locale IS NULL LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_menus WHERE False AND spree_menus.store_id = \"$1\" AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        }
    ]
}