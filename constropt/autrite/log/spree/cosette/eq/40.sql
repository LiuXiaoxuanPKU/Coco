{
    "org": {
        "sql": "SELECT DISTINCT spree_products.id FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:56.708543') AND spree_products.available_on <= '2022-08-14 05:28:56.708534' AND spree_prices.currency = \"$1\" AND spree_prices.amount IS NOT NULL",
        "cost": 17.38,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT DISTINCT spree_products.id FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:56.708543') AND spree_products.available_on <= '2022-08-14 05:28:56.708534' AND True",
            "cost": 8.32,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.id FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:56.708543') AND spree_products.available_on <= '2022-08-14 05:28:56.708534'",
            "cost": 8.32,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.id FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:56.708543') AND spree_products.available_on <= '2022-08-14 05:28:56.708534' AND True",
            "cost": 16.63,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.id FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:56.708543') AND spree_products.available_on <= '2022-08-14 05:28:56.708534'",
            "cost": 16.63,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        }
    ]
}