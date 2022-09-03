{
    "org": {
        "sql": "SELECT 1 AS one FROM spree_option_type_prototypes WHERE spree_option_type_prototypes.prototype_id IS NULL AND spree_option_type_prototypes.option_type_id = \"$1\" LIMIT \"$2\"",
        "cost": 4.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM spree_option_type_prototypes WHERE False AND spree_option_type_prototypes.option_type_id = \"$1\" LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}