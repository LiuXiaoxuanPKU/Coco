{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL LIMIT \"$3\"",
        "cost": 17.9,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' AND True LIMIT \"$3\"",
            "cost": 8.31,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' LIMIT \"$3\"",
            "cost": 8.31,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' AND True LIMIT \"$3\"",
            "cost": 16.62,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' LIMIT \"$3\"",
            "cost": 16.62,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' AND True LIMIT \"$3\"",
            "cost": 17.15,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' LIMIT \"$3\"",
            "cost": 17.15,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL LIMIT \"$3\"",
            "cost": 17.37,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' AND spree_prices.currency = \"$2\" AND True LIMIT \"$3\"",
            "cost": 17.37,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:11.408979') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:11.409087') AND spree_products.available_on <= '2022-08-14 05:29:11.409081' AND spree_prices.currency = \"$2\" LIMIT \"$3\"",
            "cost": 17.37,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        }
    ]
}