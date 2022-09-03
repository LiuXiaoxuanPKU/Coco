{
    "org": {
        "sql": "SELECT 1 AS one FROM changeset_tags WHERE changeset_tags.k = \"$1\" AND NOT(changeset_tags.changeset_id = 734 AND changeset_tags.k = 'Key 2') AND changeset_tags.changeset_id IS NULL LIMIT \"$2\"",
        "cost": 8.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM changeset_tags WHERE changeset_tags.k = \"$1\" AND NOT(changeset_tags.changeset_id = 734 AND changeset_tags.k = 'Key 2') AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}