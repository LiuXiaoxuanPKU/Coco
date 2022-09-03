{
    "org": {
        "sql": "SELECT spree_variants.id FROM spree_variants INNER JOIN spree_stock_items ON spree_stock_items.deleted_at IS NULL AND spree_stock_items.variant_id = spree_variants.id WHERE spree_variants.deleted_at IS NULL AND spree_variants.id IN (\"$1\", \"$2\") AND (spree_stock_items.count_on_hand > 0 OR spree_variants.track_inventory = False)",
        "cost": 1487.11,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_variants.id FROM spree_variants WHERE spree_variants.deleted_at IS NULL AND spree_variants.id IN (\"$1\", \"$2\") AND spree_variants.track_inventory = False",
            "cost": 4.3,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}