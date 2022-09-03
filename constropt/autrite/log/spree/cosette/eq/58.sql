{
    "org": {
        "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products.id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:10.362626') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:10.362750') AND spree_products.available_on <= '2022-08-14 05:29:10.362744' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL",
        "cost": 17.43,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND spree_products.id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:10.362626') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:10.362750') AND spree_products.available_on <= '2022-08-14 05:29:10.362744' AND True",
            "cost": 8.37,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND spree_products.id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:10.362626') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:10.362750') AND spree_products.available_on <= '2022-08-14 05:29:10.362744'",
            "cost": 8.37,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products.id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:10.362626') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:10.362750') AND spree_products.available_on <= '2022-08-14 05:29:10.362744' AND True",
            "cost": 16.68,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products.id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:10.362626') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:10.362750') AND spree_products.available_on <= '2022-08-14 05:29:10.362744'",
            "cost": 16.68,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        }
    ]
}