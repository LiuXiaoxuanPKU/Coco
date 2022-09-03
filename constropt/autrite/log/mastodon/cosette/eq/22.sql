{
    "org": {
        "sql": "SELECT DISTINCT favourites.id AS alias_0, accounts.id FROM accounts LEFT OUTER JOIN favourites ON favourites.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE accounts.suspended_at IS NULL AND favourites.status_id = \"$1\" AND 1 = 1 ORDER BY favourites.id DESC LIMIT \"$2\"",
        "cost": 28.03
    },
    "rewrites": [
        {
            "sql": "SELECT favourites.id AS alias_0, accounts.id FROM accounts LEFT OUTER JOIN favourites ON favourites.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE accounts.suspended_at IS NULL AND favourites.status_id = \"$1\" AND 1 = 1 ORDER BY favourites.id DESC LIMIT \"$2\"",
            "cost": 28.02,
            "rewrite_types": [
                "RemoveDistinct",
                "ReplaceOuterJoin"
            ]
        },
        {
            "sql": "SELECT favourites.id AS alias_0, accounts.id FROM accounts INNER JOIN favourites ON favourites.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE accounts.suspended_at IS NULL AND favourites.status_id = \"$1\" AND 1 = 1 ORDER BY favourites.id DESC LIMIT \"$2\"",
            "cost": 28.02,
            "rewrite_types": [
                "RemoveDistinct",
                "ReplaceOuterJoin"
            ]
        }
    ]
}