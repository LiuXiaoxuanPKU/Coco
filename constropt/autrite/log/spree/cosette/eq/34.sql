{
    "org": {
        "sql": "SELECT spree_stock_items.* FROM spree_stock_items INNER JOIN spree_variants ON spree_stock_items.variant_id = spree_variants.id INNER JOIN spree_products ON spree_variants.product_id = spree_products.id INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id WHERE spree_stock_items.deleted_at IS NULL AND spree_variants.deleted_at IS NULL AND spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" ORDER BY spree_variants.position ASC",
        "cost": 650.9,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_stock_items.* FROM spree_stock_items INNER JOIN spree_variants ON spree_stock_items.variant_id = spree_variants.id INNER JOIN spree_products ON spree_variants.product_id = spree_products.id INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id WHERE spree_stock_items.deleted_at IS NULL AND spree_variants.deleted_at IS NULL AND spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" ORDER BY spree_variants.position ASC LIMIT 1",
            "cost": 396.77,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}