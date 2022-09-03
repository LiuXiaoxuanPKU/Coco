{
    "org": {
        "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL LIMIT \"$4\" OFFSET \"$5\"",
        "cost": 18.01,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND True AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND True LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 8.41,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 8.41,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND True AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND True LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 16.33,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 16.33,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND True AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND True LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 16.72,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 16.72,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND True AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND True LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 17.26,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 17.26,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 17.47,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND True AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND spree_prices.currency = \"$3\" AND True LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 17.47,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND spree_prices.currency = \"$3\" LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 17.47,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND spree_prices.currency = \"$3\" LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 17.47,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:09.208452') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:09.208587') AND spree_products.available_on <= '2022-08-14 05:42:09.208580' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL LIMIT \"$4\" OFFSET \"$5\"",
            "cost": 17.47,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        }
    ]
}