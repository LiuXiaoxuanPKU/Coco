{
    "org": {
        "sql": "SELECT 1 AS one FROM current_relation_tags WHERE current_relation_tags.k = \"$1\" AND NOT(current_relation_tags.relation_id = 110 AND current_relation_tags.k = 'Key 1') AND current_relation_tags.relation_id IS NULL LIMIT \"$2\"",
        "cost": 8.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM current_relation_tags WHERE current_relation_tags.k = \"$1\" AND NOT(current_relation_tags.relation_id = 110 AND current_relation_tags.k = 'Key 1') AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}