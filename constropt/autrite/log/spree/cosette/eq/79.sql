{
    "org": {
        "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
        "cost": 18.85,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND True AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND True AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 17.79,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 17.79,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND True AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND True AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 17.88,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 17.88,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND True AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND True AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.01,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.01,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND True AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND True AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.1,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.1,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.55,
            "rewrite_types": [
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND True AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND True AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.55,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.55,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.55,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.55,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.64,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND True AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND True AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.64,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.64,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.64,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_prices.currency = \"$2\" AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.64,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.76,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_prices.currency = \"$2\" AND True AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND True AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.76,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_prices.currency = \"$2\" AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.76,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_prices.currency = \"$2\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.76,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.*, MIN(spree_products_taxons.position) AS min_position FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id INNER JOIN spree_prices ON spree_prices.deleted_at IS NULL AND spree_prices.variant_id = spree_variants.id INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_prices.currency = \"$2\" AND spree_products_taxons.taxon_id = \"$3\" AND (spree_products.deleted_at IS NULL OR spree_products.deleted_at >= '2022-08-14 05:42:13.596070') AND (spree_products.discontinue_on IS NULL OR spree_products.discontinue_on >= '2022-08-14 05:42:13.596193') AND spree_products.available_on <= '2022-08-14 05:42:13.596187' AND spree_prices.currency = \"$4\" AND spree_prices.amount IS NOT NULL AND spree_products_taxons.taxon_id = \"$5\" GROUP BY spree_products.id ORDER BY min_position ASC LIMIT \"$6\" OFFSET \"$7\"",
            "cost": 18.76,
            "rewrite_types": [
                "RemovePredicate",
                "RemoveDistinct"
            ]
        }
    ]
}