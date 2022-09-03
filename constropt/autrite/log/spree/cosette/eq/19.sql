{
    "org": {
        "sql": "SELECT spree_option_types.* FROM spree_option_types INNER JOIN spree_option_type_prototypes ON spree_option_types.id = spree_option_type_prototypes.option_type_id WHERE spree_option_type_prototypes.prototype_id = \"$1\" ORDER BY spree_option_types.position ASC",
        "cost": 21.2,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_option_types.* FROM spree_option_types INNER JOIN spree_option_type_prototypes ON spree_option_types.id = spree_option_type_prototypes.option_type_id WHERE spree_option_type_prototypes.prototype_id = \"$1\" ORDER BY spree_option_types.position ASC LIMIT 1",
            "cost": 21.19,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}