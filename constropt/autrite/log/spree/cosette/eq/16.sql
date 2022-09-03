{
    "org": {
        "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\"",
        "cost": 28.01,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_stores ON spree_products.id = spree_products_stores.product_id WHERE spree_products.deleted_at IS NULL AND spree_products_stores.store_id = \"$1\" LIMIT 1",
            "cost": 14.75,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}