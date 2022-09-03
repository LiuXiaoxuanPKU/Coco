{
    "org": {
        "sql": "SELECT favourites.account_id FROM favourites WHERE favourites.status_id = \"$1\"",
        "cost": 11.4
    },
    "rewrites": [
        {
            "sql": "SELECT favourites.account_id FROM favourites WHERE favourites.status_id = \"$1\" LIMIT 1",
            "cost": 6.3,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}