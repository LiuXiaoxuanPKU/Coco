{
    "org": {
        "sql": "SELECT changesets.* FROM changesets WHERE num_changes > 0 AND changesets.id <= '744' ORDER BY changesets.id DESC LIMIT \"$1\"",
        "cost": 0.76,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT changesets.* FROM changesets WHERE changesets.id <= '744' ORDER BY changesets.id DESC LIMIT \"$1\"",
            "cost": 0.73,
            "rewrite_types": [
                "RemovePredicate"
            ]
        }
    ]
}