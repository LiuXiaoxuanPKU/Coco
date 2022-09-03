{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_property_prototypes WHERE spree_property_prototypes.prototype_id IS NULL AND spree_property_prototypes.property_id = \"$1\" LIMIT \"$2\"",
        "cost": 8.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_property_prototypes WHERE False AND spree_property_prototypes.property_id = \"$1\" LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}