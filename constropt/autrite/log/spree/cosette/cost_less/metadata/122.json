{
    "org": {
        "sql": "SELECT DISTINCT spree_promotions.id AS alias_0, spree_promotions.id FROM spree_promotions INNER JOIN spree_promotions_stores ON spree_promotions.id = spree_promotions_stores.promotion_id LEFT OUTER JOIN spree_promotion_rules ON spree_promotion_rules.promotion_id = spree_promotions.id LEFT OUTER JOIN spree_promotion_actions ON spree_promotion_actions.deleted_at IS NULL AND spree_promotion_actions.promotion_id = spree_promotions.id WHERE spree_promotions_stores.store_id = \"$1\" AND (spree_promotions.starts_at IS NULL OR spree_promotions.starts_at < '2022-08-14 05:29:19.480467') AND (spree_promotions.expires_at IS NULL OR spree_promotions.expires_at > '2022-08-14 05:29:19.480586') AND LOWER(spree_promotions.code) = '10off' AND spree_promotion_actions.id IS NOT NULL ORDER BY spree_promotions.id DESC LIMIT \"$2\"",
        "cost": 29.64,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_promotions.id AS alias_0, spree_promotions.id FROM spree_promotions INNER JOIN spree_promotions_stores ON spree_promotions.id = spree_promotions_stores.promotion_id INNER JOIN spree_promotion_rules ON spree_promotion_rules.promotion_id = spree_promotions.id LEFT OUTER JOIN spree_promotion_actions ON spree_promotion_actions.deleted_at IS NULL AND spree_promotion_actions.promotion_id = spree_promotions.id WHERE spree_promotions_stores.store_id = \"$1\" AND (spree_promotions.starts_at IS NULL OR spree_promotions.starts_at < '2022-08-14 05:29:19.480467') AND (spree_promotions.expires_at IS NULL OR spree_promotions.expires_at > '2022-08-14 05:29:19.480586') AND LOWER(spree_promotions.code) = '10off' AND spree_promotion_actions.id IS NOT NULL ORDER BY spree_promotions.id DESC LIMIT \"$2\"",
            "cost": 20.84,
            "rewrite_types": [
                "RemoveDistinct",
                "ReplaceOuterJoin"
            ]
        },
        {
            "sql": "SELECT DISTINCT spree_promotions.id AS alias_0, spree_promotions.id FROM spree_promotions INNER JOIN spree_promotions_stores ON spree_promotions.id = spree_promotions_stores.promotion_id INNER JOIN spree_promotion_rules ON spree_promotion_rules.promotion_id = spree_promotions.id LEFT OUTER JOIN spree_promotion_actions ON spree_promotion_actions.deleted_at IS NULL AND spree_promotion_actions.promotion_id = spree_promotions.id WHERE spree_promotions_stores.store_id = \"$1\" AND (spree_promotions.starts_at IS NULL OR spree_promotions.starts_at < '2022-08-14 05:29:19.480467') AND (spree_promotions.expires_at IS NULL OR spree_promotions.expires_at > '2022-08-14 05:29:19.480586') AND LOWER(spree_promotions.code) = '10off' AND spree_promotion_actions.id IS NOT NULL ORDER BY spree_promotions.id DESC LIMIT \"$2\"",
            "cost": 20.85,
            "rewrite_types": [
                "ReplaceOuterJoin"
            ]
        }
    ]
}