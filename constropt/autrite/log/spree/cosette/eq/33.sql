{
    "org": {
        "sql": "SELECT spree_variants.* FROM spree_variants INNER JOIN spree_products ON spree_variants.product_id = spree_products.id INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id WHERE spree_variants.deleted_at IS NULL AND spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" AND spree_variants.id = \"$2\" ORDER BY spree_variants.position ASC LIMIT \"$3\"",
        "cost": 16.96,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_variants.* FROM spree_variants INNER JOIN spree_products ON spree_variants.product_id = spree_products.id WHERE spree_variants.deleted_at IS NULL AND spree_products.deleted_at IS NULL AND spree_variants.id = \"$2\" ORDER BY spree_variants.position ASC LIMIT \"$3\"",
            "cost": 16.62,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}