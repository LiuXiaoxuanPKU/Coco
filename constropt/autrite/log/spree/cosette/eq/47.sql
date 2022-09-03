{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_promotions INNER JOIN spree_promotion_rules ON spree_promotions.id = spree_promotion_rules.promotion_id INNER JOIN spree_product_promotion_rules ON spree_promotion_rules.id = spree_product_promotion_rules.promotion_rule_id WHERE spree_product_promotion_rules.product_id = \"$1\" AND spree_promotions.advertise = \"$2\" AND (spree_promotions.starts_at IS NULL OR spree_promotions.starts_at < '2022-08-14 05:38:26.589079') AND (spree_promotions.expires_at IS NULL OR spree_promotions.expires_at > '2022-08-14 05:38:26.589163') AND spree_promotions.id = \"$3\" LIMIT \"$4\"",
        "cost": 24.94,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_promotions INNER JOIN spree_promotion_rules ON spree_promotions.id = spree_promotion_rules.promotion_id WHERE spree_promotions.advertise = \"$2\" AND (spree_promotions.starts_at IS NULL OR spree_promotions.starts_at < '2022-08-14 05:38:26.589079') AND (spree_promotions.expires_at IS NULL OR spree_promotions.expires_at > '2022-08-14 05:38:26.589163') AND spree_promotions.id = \"$3\" LIMIT \"$4\"",
            "cost": 12.62,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}