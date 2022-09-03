{
    "org": {
        "sql": "SELECT spree_stock_items.* FROM spree_stock_items INNER JOIN spree_stock_locations ON spree_stock_locations.id = spree_stock_items.stock_location_id WHERE spree_stock_items.deleted_at IS NULL AND spree_stock_items.variant_id = \"$1\" AND spree_stock_locations.active = \"$2\"",
        "cost": 704.55,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_stock_items.* FROM spree_stock_items WHERE spree_stock_items.deleted_at IS NULL AND spree_stock_items.variant_id = \"$1\"",
            "cost": 327.39,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}