{
    "org": {
        "sql": "SELECT current_nodes.* FROM current_nodes WHERE current_nodes.tile BETWEEN 4294967294 AND 4294967295 AND current_nodes.latitude BETWEEN 899980000.0 AND 899990000.0 AND current_nodes.longitude BETWEEN 1799980000.0 AND 1799990000.0 AND current_nodes.visible = \"$1\" LIMIT \"$2\"",
        "cost": 8.32,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT current_nodes.* FROM current_nodes WHERE current_nodes.tile BETWEEN 4294967294 AND 4294967295 AND current_nodes.latitude BETWEEN 899980000.0 AND 899990000.0 AND current_nodes.visible = \"$1\" LIMIT \"$2\"",
            "cost": 8.31,
            "rewrite_types": [
                "RemovePredicate"
            ]
        }
    ]
}