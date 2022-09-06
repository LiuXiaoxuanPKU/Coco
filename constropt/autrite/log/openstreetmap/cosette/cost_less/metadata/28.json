{
    "org": {
        "sql": "SELECT current_nodes.* FROM current_nodes INNER JOIN current_way_nodes ON current_nodes.id = current_way_nodes.node_id WHERE current_way_nodes.way_id = \"$1\" ORDER BY current_way_nodes.sequence_id ASC",
        "cost": 27.89,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT current_nodes.* FROM current_nodes INNER JOIN current_way_nodes ON current_nodes.id = current_way_nodes.node_id WHERE current_way_nodes.way_id = \"$1\" ORDER BY current_way_nodes.sequence_id ASC LIMIT 1",
            "cost": 14.75,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}