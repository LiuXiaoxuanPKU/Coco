{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id INNER JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id WHERE spree_products.deleted_at IS NULL AND spree_properties.name = \"$1\" AND spree_product_properties.value = 'Nike' AND spree_products.id = \"$2\" LIMIT \"$3\"",
        "cost": 28.25,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_products INNER JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_product_properties.value = 'Nike' AND spree_products.id = \"$2\" LIMIT \"$3\"",
            "cost": 19.81,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}