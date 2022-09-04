{
    "org": {
        "sql": "SELECT spree_product_option_types.option_type_id FROM spree_product_option_types WHERE spree_product_option_types.product_id = \"$1\"",
        "cost": 11.45,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_product_option_types.option_type_id FROM spree_product_option_types WHERE spree_product_option_types.product_id = \"$1\" LIMIT 1",
            "cost": 6.3,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}