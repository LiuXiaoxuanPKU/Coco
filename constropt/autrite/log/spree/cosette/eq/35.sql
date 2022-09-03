{
    "org": {
        "sql": "SELECT DISTINCT spree_promotions.id AS alias_0, spree_promotions.id FROM spree_promotions INNER JOIN spree_promotions_stores ON spree_promotions.id = spree_promotions_stores.promotion_id LEFT OUTER JOIN spree_promotion_actions ON spree_promotion_actions.deleted_at IS NULL AND spree_promotion_actions.promotion_id = spree_promotions.id WHERE spree_promotions_stores.store_id = \"$1\" AND LOWER(spree_promotions.code) = '10off' AND spree_promotion_actions.id IS NOT NULL ORDER BY spree_promotions.id DESC LIMIT \"$2\"",
        "cost": 28.45,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_promotions.id AS alias_0, spree_promotions.id FROM spree_promotions INNER JOIN spree_promotions_stores ON spree_promotions.id = spree_promotions_stores.promotion_id LEFT OUTER JOIN spree_promotion_actions ON spree_promotion_actions.deleted_at IS NULL AND spree_promotion_actions.promotion_id = spree_promotions.id WHERE spree_promotions_stores.store_id = \"$1\" AND LOWER(spree_promotions.code) = '10off' AND spree_promotion_actions.id IS NOT NULL ORDER BY spree_promotions.id DESC LIMIT \"$2\"",
            "cost": 28.44,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT spree_promotions.id AS alias_0, spree_promotions.id FROM spree_promotions INNER JOIN spree_promotions_stores ON spree_promotions.id = spree_promotions_stores.promotion_id INNER JOIN spree_promotion_actions ON spree_promotion_actions.deleted_at IS NULL AND spree_promotion_actions.promotion_id = spree_promotions.id WHERE spree_promotions_stores.store_id = \"$1\" AND LOWER(spree_promotions.code) = '10off' AND spree_promotion_actions.id IS NOT NULL ORDER BY spree_promotions.id DESC LIMIT \"$2\"",
            "cost": 28.44,
            "rewrite_types": [
                "RemoveDistinct",
                "ReplaceOuterJoin"
            ]
        }
    ]
}