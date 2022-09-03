{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_stock_items INNER JOIN spree_stock_locations ON spree_stock_locations.id = spree_stock_items.stock_location_id WHERE spree_stock_items.deleted_at IS NULL AND spree_stock_locations.active = \"$1\" AND spree_stock_items.id = \"$2\" LIMIT \"$3\"",
        "cost": 16.76,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_stock_items WHERE spree_stock_items.deleted_at IS NULL AND spree_stock_items.id = \"$2\" LIMIT \"$3\"",
            "cost": 8.45,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}