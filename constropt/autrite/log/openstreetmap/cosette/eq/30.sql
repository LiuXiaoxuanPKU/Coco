{
    "org": {
        "sql": "SELECT 1 AS one FROM way_tags WHERE way_tags.k = \"$1\" AND NOT(way_tags.way_id = 145 AND way_tags.version = 1 AND way_tags.k = 'Key 2') AND way_tags.way_id IS NULL AND way_tags.version IS NULL LIMIT \"$2\"",
        "cost": 8.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM way_tags WHERE way_tags.k = \"$1\" AND NOT(way_tags.way_id = 145 AND way_tags.version = 1 AND way_tags.k = 'Key 2') AND False AND way_tags.version IS NULL LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM way_tags WHERE way_tags.k = \"$1\" AND NOT(way_tags.way_id = 145 AND way_tags.version = 1 AND way_tags.k = 'Key 2') AND way_tags.way_id IS NULL AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        },
        {
            "sql": "SELECT 1 AS one FROM way_tags WHERE way_tags.k = \"$1\" AND NOT(way_tags.way_id = 145 AND way_tags.version = 1 AND way_tags.k = 'Key 2') AND False AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate",
                "RewriteNullPredicate"
            ]
        }
    ]
}