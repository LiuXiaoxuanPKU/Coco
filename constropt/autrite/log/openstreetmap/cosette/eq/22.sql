{
    "org": {
        "sql": "SELECT 1 AS one FROM current_way_tags WHERE current_way_tags.k = \"$1\" AND NOT(current_way_tags.way_id = 186 AND current_way_tags.k = 'Key 3') AND current_way_tags.way_id IS NULL LIMIT \"$2\"",
        "cost": 8.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM current_way_tags WHERE current_way_tags.k = \"$1\" AND NOT(current_way_tags.way_id = 186 AND current_way_tags.k = 'Key 3') AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}