{
    "org": {
        "sql": "SELECT 1 AS one FROM current_node_tags WHERE current_node_tags.k = \"$1\" AND NOT(current_node_tags.node_id = 353 AND current_node_tags.k = 'Key 2') AND current_node_tags.node_id IS NULL LIMIT \"$2\"",
        "cost": 4.31,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM current_node_tags WHERE current_node_tags.k = \"$1\" AND NOT(current_node_tags.node_id = 353 AND current_node_tags.k = 'Key 2') AND False LIMIT \"$2\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}