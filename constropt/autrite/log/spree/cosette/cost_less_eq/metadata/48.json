{
    "org": {
        "sql": "SELECT DISTINCT spree_stock_locations.* FROM spree_stock_locations INNER JOIN spree_stock_items ON spree_stock_items.deleted_at IS NULL AND spree_stock_items.stock_location_id = spree_stock_locations.id WHERE spree_stock_locations.active = \"$1\" AND spree_stock_items.variant_id IN (\"$2\", \"$3\", \"$4\")",
        "cost": 9358.78,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_stock_locations.* FROM spree_stock_locations WHERE spree_stock_locations.active = \"$1\"",
            "cost": 225.0,
            "rewrite_types": [
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_stock_locations.* FROM spree_stock_locations WHERE spree_stock_locations.active = \"$1\"",
            "cost": 750.0,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}