{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:37.128612') AND spree_products.available_on <= '2022-08-14 05:37:37.128602' AND spree_prices.currency = \"$1\" AND spree_prices.amount IS NOT NULL AND spree_products.id = \"$2\" LIMIT \"$3\"",
        "cost": 24.93,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:37.128612') AND spree_products.available_on <= '2022-08-14 05:37:37.128602' AND True AND spree_products.id = \"$2\" LIMIT \"$3\"",
            "cost": 8.31,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:37.128612') AND spree_products.available_on <= '2022-08-14 05:37:37.128602' AND spree_products.id = \"$2\" LIMIT \"$3\"",
            "cost": 8.31,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:37.128612') AND spree_products.available_on <= '2022-08-14 05:37:37.128602' AND True AND spree_products.id = \"$2\" LIMIT \"$3\"",
            "cost": 16.62,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:37:37.128612') AND spree_products.available_on <= '2022-08-14 05:37:37.128602' AND spree_products.id = \"$2\" LIMIT \"$3\"",
            "cost": 16.62,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        }
    ]
}