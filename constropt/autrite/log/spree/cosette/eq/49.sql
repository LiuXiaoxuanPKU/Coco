{
    "org": {
        "sql": "SELECT DISTINCT spree_products.id FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.is_master = \"$1\" AND spree_variants.product_id = spree_products.id INNER JOIN spree_option_value_variants ON spree_option_value_variants.variant_id = spree_variants.id INNER JOIN spree_option_values ON spree_option_values.id = spree_option_value_variants.option_value_id WHERE spree_products.deleted_at IS NULL AND spree_option_values.id IN (\"$2\", \"$3\") GROUP BY spree_products.id, spree_variants.id HAVING COUNT(spree_option_values.option_type_id) = 2",
        "cost": 40.76,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.id FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.is_master = \"$1\" AND spree_variants.product_id = spree_products.id INNER JOIN spree_option_value_variants ON spree_option_value_variants.variant_id = spree_variants.id INNER JOIN spree_option_values ON spree_option_values.id = spree_option_value_variants.option_value_id WHERE spree_products.deleted_at IS NULL AND spree_option_values.id IN (\"$2\", \"$3\") GROUP BY spree_products.id, spree_variants.id HAVING COUNT(spree_option_values.option_type_id) = 2",
            "cost": 40.75,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_products.id FROM spree_products INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.is_master = \"$1\" AND spree_variants.product_id = spree_products.id INNER JOIN spree_option_value_variants ON spree_option_value_variants.variant_id = spree_variants.id INNER JOIN spree_option_values ON spree_option_values.id = spree_option_value_variants.option_value_id WHERE spree_products.deleted_at IS NULL AND spree_option_values.id IN (\"$2\", \"$3\") GROUP BY spree_products.id, spree_variants.id HAVING COUNT(spree_option_values.option_type_id) = 2 LIMIT 1",
            "cost": 40.75,
            "rewrite_types": [
                "RemoveDistinct",
                "AddLimitOne"
            ]
        }
    ]
}