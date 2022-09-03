{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_products INNER JOIN friendly_id_slugs ON friendly_id_slugs.deleted_at IS NULL AND friendly_id_slugs.sluggable_type = \"$1\" AND friendly_id_slugs.sluggable_id = spree_products.id WHERE spree_products.id IS NOT NULL AND spree_products.slug = \"$2\" LIMIT \"$3\"",
        "cost": 16.62,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_products WHERE spree_products.id IS NOT NULL AND spree_products.slug = \"$2\" LIMIT \"$3\"",
            "cost": 8.3,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}