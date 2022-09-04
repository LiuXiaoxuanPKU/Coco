{
    "org": {
        "sql": "SELECT changesets.* FROM changesets WHERE num_changes > 0 AND changesets.user_id = \"$1\" ORDER BY changesets.id DESC LIMIT \"$2\"",
        "cost": 18.18,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT changesets.* FROM changesets WHERE changesets.user_id = \"$1\" ORDER BY changesets.id DESC LIMIT \"$2\"",
            "cost": 18.17,
            "rewrite_types": [
                "RemovePredicate"
            ]
        }
    ]
}