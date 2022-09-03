{
    "org": {
        "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_stock_items ON spree_stock_items.deleted_at IS NULL AND spree_stock_items.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$1\" AND spree_prices.amount IS NOT NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:43.686766') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:43.686904') AND spree_products.available_on <= '2022-08-14 05:28:43.686898' AND spree_variants.deleted_at IS NULL AND (spree_stock_items.count_on_hand > 0 OR spree_variants.track_inventory = False)",
        "cost": 383.7,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND True AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:43.686766') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:43.686904') AND spree_products.available_on <= '2022-08-14 05:28:43.686898' AND spree_variants.deleted_at IS NULL AND spree_variants.track_inventory = False",
            "cost": 12.67,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:43.686766') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:43.686904') AND spree_products.available_on <= '2022-08-14 05:28:43.686898' AND spree_variants.deleted_at IS NULL AND spree_variants.track_inventory = False",
            "cost": 12.67,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$1\" AND spree_prices.amount IS NOT NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:43.686766') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:43.686904') AND spree_products.available_on <= '2022-08-14 05:28:43.686898' AND spree_variants.deleted_at IS NULL AND spree_variants.track_inventory = False",
            "cost": 20.99,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$1\" AND True AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:43.686766') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:43.686904') AND spree_products.available_on <= '2022-08-14 05:28:43.686898' AND spree_variants.deleted_at IS NULL AND spree_variants.track_inventory = False",
            "cost": 20.99,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$1\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:43.686766') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:43.686904') AND spree_products.available_on <= '2022-08-14 05:28:43.686898' AND spree_variants.deleted_at IS NULL AND spree_variants.track_inventory = False",
            "cost": 20.99,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        }
    ]
}