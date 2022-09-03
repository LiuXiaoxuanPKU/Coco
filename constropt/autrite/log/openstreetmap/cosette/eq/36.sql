{
    "org": {
        "sql": "SELECT 1 AS one FROM relation_tags WHERE relation_tags.k = \"$1\" AND NOT(relation_tags.relation_id = 154 AND relation_tags.version = 1 AND relation_tags.k = 'Key 1') AND relation_tags.relation_id IS NULL AND relation_tags.version IS NULL LIMIT \"$2\"",
        "cost": 8.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM relation_tags WHERE relation_tags.k = \"$1\" AND NOT(relation_tags.relation_id = 154 AND relation_tags.version = 1 AND relation_tags.k = 'Key 1') AND False AND relation_tags.version IS NULL LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM relation_tags WHERE relation_tags.k = \"$1\" AND NOT(relation_tags.relation_id = 154 AND relation_tags.version = 1 AND relation_tags.k = 'Key 1') AND relation_tags.relation_id IS NULL AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM relation_tags WHERE relation_tags.k = \"$1\" AND NOT(relation_tags.relation_id = 154 AND relation_tags.version = 1 AND relation_tags.k = 'Key 1') AND False AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        }
    ]
}