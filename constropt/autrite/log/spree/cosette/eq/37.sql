{
    "org": {
        "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:36.181805') AND spree_products.available_on <= '2022-08-14 05:37:36.181795' AND spree_prices.currency = \"$1\" AND spree_prices.amount IS NOT NULL",
        "cost": 17.42,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:36.181805') AND spree_products.available_on <= '2022-08-14 05:37:36.181795' AND True",
            "cost": 8.36,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:36.181805') AND spree_products.available_on <= '2022-08-14 05:37:36.181795'",
            "cost": 8.36,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:36.181805') AND spree_products.available_on <= '2022-08-14 05:37:36.181795' AND True",
            "cost": 16.67,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:36.181805') AND spree_products.available_on <= '2022-08-14 05:37:36.181795'",
            "cost": 16.67,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        }
    ]
}