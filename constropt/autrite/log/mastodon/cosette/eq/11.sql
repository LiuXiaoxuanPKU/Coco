{
    "org": {
        "sql": "SELECT 1 AS one FROM favourites WHERE favourites.status_id IS NULL AND favourites.id <> \"$1\" AND favourites.account_id = \"$2\" LIMIT \"$3\"",
        "cost": 8.31
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM favourites WHERE False AND favourites.id <> \"$1\" AND favourites.account_id = \"$2\" LIMIT \"$3\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}