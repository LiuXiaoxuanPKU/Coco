{
    "org": {
        "sql": "SELECT spree_promotions.* FROM spree_promotions INNER JOIN spree_promotions_stores ON spree_promotions.id = spree_promotions_stores.promotion_id WHERE spree_promotions_stores.store_id = \"$1\"",
        "cost": 28.01,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_promotions.* FROM spree_promotions INNER JOIN spree_promotions_stores ON spree_promotions.id = spree_promotions_stores.promotion_id WHERE spree_promotions_stores.store_id = \"$1\" LIMIT 1",
            "cost": 14.75,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}