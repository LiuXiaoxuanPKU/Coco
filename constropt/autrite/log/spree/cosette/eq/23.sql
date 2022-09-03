{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_line_items INNER JOIN spree_variants ON spree_variants.id = spree_line_items.variant_id INNER JOIN spree_products ON spree_products.id = spree_variants.product_id WHERE spree_line_items.order_id = \"$1\" AND spree_products.promotionable = \"$2\" LIMIT \"$3\"",
        "cost": 73.37,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_line_items WHERE spree_line_items.order_id = \"$1\" LIMIT \"$3\"",
            "cost": 1.9,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM spree_line_items INNER JOIN spree_variants ON spree_variants.id = spree_line_items.variant_id WHERE spree_line_items.order_id = \"$1\" LIMIT \"$3\"",
            "cost": 9.62,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}