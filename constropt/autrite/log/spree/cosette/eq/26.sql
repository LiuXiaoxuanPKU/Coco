{
    "org": {
        "sql": "SELECT SUM(spree_stock_items.count_on_hand) FROM spree_stock_items INNER JOIN spree_stock_locations ON spree_stock_locations.id = spree_stock_items.stock_location_id WHERE spree_stock_items.deleted_at IS NULL AND spree_stock_items.variant_id = \"$1\" AND spree_stock_locations.active = \"$2\"",
        "cost": 730.41,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT SUM(spree_stock_items.count_on_hand) FROM spree_stock_items WHERE spree_stock_items.deleted_at IS NULL AND spree_stock_items.variant_id = \"$1\"",
            "cost": 353.25,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT SUM(spree_stock_items.count_on_hand) FROM spree_stock_items WHERE spree_stock_items.deleted_at IS NULL AND spree_stock_items.variant_id = \"$1\" LIMIT 1",
            "cost": 353.25,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        }
    ]
}