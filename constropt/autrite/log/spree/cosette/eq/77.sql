{
    "org": {
        "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC",
        "cost": 18.27,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND True AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC",
            "cost": 17.47,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC",
            "cost": 17.47,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND True AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC LIMIT 1",
            "cost": 17.47,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC LIMIT 1",
            "cost": 17.47,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND True AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC",
            "cost": 17.52,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC",
            "cost": 17.52,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND True AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC LIMIT 1",
            "cost": 17.52,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC LIMIT 1",
            "cost": 17.52,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC",
            "cost": 18.23,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_prices.currency = \"$4\" AND True AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC",
            "cost": 18.23,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_prices.currency = \"$4\" AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC",
            "cost": 18.23,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC LIMIT 1",
            "cost": 18.23,
            "rewrite_types": [
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_prices.currency = \"$4\" AND True AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC LIMIT 1",
            "cost": 18.23,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\", \"$3\") AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:28:58.338293') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:28:58.338460') AND spree_products.available_on <= '2022-08-14 05:28:58.338453' AND spree_prices.currency = \"$4\" AND spree_products_taxons.taxon_id IN (\"$5\", \"$6\", \"$7\") GROUP BY spree_products.id ORDER BY min_position ASC LIMIT 1",
            "cost": 18.23,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct",
                "AddLimitOne"
            ]
        }
    ]
}