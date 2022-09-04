{
    "org": {
        "sql": "SELECT 1 AS one FROM current_nodes INNER JOIN current_way_nodes ON current_nodes.id = current_way_nodes.node_id WHERE current_way_nodes.way_id = \"$1\" LIMIT \"$2\"",
        "cost": 23.87,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM current_nodes LIMIT \"$2\"",
            "cost": 0.09,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}