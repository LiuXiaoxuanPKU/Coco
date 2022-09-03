{
    "org": {
        "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL",
        "cost": 18.23,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True",
            "cost": 8.31,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245'",
            "cost": 8.31,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True LIMIT 1",
            "cost": 8.31,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' LIMIT 1",
            "cost": 8.31,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True",
            "cost": 8.37,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245'",
            "cost": 8.37,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True LIMIT 1",
            "cost": 8.37,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' LIMIT 1",
            "cost": 8.37,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True",
            "cost": 16.62,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245'",
            "cost": 16.62,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True LIMIT 1",
            "cost": 16.62,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' LIMIT 1",
            "cost": 16.62,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True",
            "cost": 16.67,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245'",
            "cost": 16.67,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True LIMIT 1",
            "cost": 16.67,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' LIMIT 1",
            "cost": 16.67,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL",
            "cost": 17.37,
            "rewrite_types": [
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND True",
            "cost": 17.37,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\"",
            "cost": 17.37,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL LIMIT 1",
            "cost": 17.37,
            "rewrite_types": [
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND True LIMIT 1",
            "cost": 17.37,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" LIMIT 1",
            "cost": 17.37,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL",
            "cost": 17.42,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND True",
            "cost": 17.42,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\"",
            "cost": 17.42,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True",
            "cost": 17.42,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245'",
            "cost": 17.42,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL LIMIT 1",
            "cost": 17.42,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND True LIMIT 1",
            "cost": 17.42,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" LIMIT 1",
            "cost": 17.42,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True LIMIT 1",
            "cost": 17.42,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' LIMIT 1",
            "cost": 17.42,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True",
            "cost": 17.48,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245'",
            "cost": 17.48,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND True LIMIT 1",
            "cost": 17.48,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' LIMIT 1",
            "cost": 17.48,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL",
            "cost": 18.17,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND True",
            "cost": 18.17,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\"",
            "cost": 18.17,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND spree_prices.amount IS NOT NULL LIMIT 1",
            "cost": 18.17,
            "rewrite_types": [
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" AND True LIMIT 1",
            "cost": 18.17,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:29:13.779101') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:29:13.779251') AND spree_products.available_on <= '2022-08-14 05:29:13.779245' AND spree_prices.currency = \"$3\" LIMIT 1",
            "cost": 18.17,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        }
    ]
}