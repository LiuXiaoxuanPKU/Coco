{
    "org": {
        "sql": "SELECT changesets.* FROM changesets WHERE num_changes > 0 ORDER BY changesets.id DESC LIMIT \"$1\"",
        "cost": 0.41,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT changesets.* FROM changesets ORDER BY changesets.id DESC LIMIT \"$1\"",
            "cost": 0.4,
            "rewrite_types": [
                "RemovePredicate"
            ]
        }
    ]
}