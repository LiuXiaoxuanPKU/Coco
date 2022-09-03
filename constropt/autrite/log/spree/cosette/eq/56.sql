{
    "org": {
        "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND spree_prices.currency = \"$1\" AND spree_prices.amount IS NOT NULL ORDER BY spree_products.name DESC",
        "cost": 17.42,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND True ORDER BY spree_products.name DESC",
            "cost": 8.32,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' ORDER BY spree_products.name DESC",
            "cost": 8.32,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND True ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 8.32,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 8.32,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND True ORDER BY spree_products.name DESC",
            "cost": 8.37,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' ORDER BY spree_products.name DESC",
            "cost": 8.37,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND True ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 8.37,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 8.37,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND True ORDER BY spree_products.name DESC",
            "cost": 16.63,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' ORDER BY spree_products.name DESC",
            "cost": 16.63,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND True ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 16.63,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 16.63,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND True ORDER BY spree_products.name DESC",
            "cost": 16.67,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' ORDER BY spree_products.name DESC",
            "cost": 16.67,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND True ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 16.67,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 16.67,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND spree_prices.currency = \"$1\" AND spree_prices.amount IS NOT NULL ORDER BY spree_products.name DESC",
            "cost": 17.38,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND spree_prices.currency = \"$1\" AND True ORDER BY spree_products.name DESC",
            "cost": 17.38,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND spree_prices.currency = \"$1\" ORDER BY spree_products.name DESC",
            "cost": 17.38,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND spree_prices.currency = \"$1\" AND spree_prices.amount IS NOT NULL ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 17.38,
            "rewrite_types": [
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND spree_prices.currency = \"$1\" AND True ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 17.38,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:54.101040') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:54.101192') AND spree_products.available_on <= '2022-08-14 05:28:54.101187' AND spree_prices.currency = \"$1\" ORDER BY spree_products.name DESC LIMIT 1",
            "cost": 17.38,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        }
    ]
}