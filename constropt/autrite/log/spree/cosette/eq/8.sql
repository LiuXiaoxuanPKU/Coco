{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_product_properties WHERE spree_product_properties.property_id IS NULL AND spree_product_properties.product_id = \"$1\" LIMIT \"$2\"",
        "cost": 8.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_product_properties WHERE False AND spree_product_properties.product_id = \"$1\" LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}