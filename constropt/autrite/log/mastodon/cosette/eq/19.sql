{
    "org": {
        "sql": "SELECT DISTINCT follows.id AS alias_0, accounts.id FROM accounts LEFT OUTER JOIN follows ON follows.target_account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE 1 = 1 AND follows.account_id = \"$1\" ORDER BY follows.id DESC LIMIT \"$2\"",
        "cost": 16.63,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT follows.id AS alias_0, accounts.id FROM accounts LEFT OUTER JOIN follows ON follows.target_account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE 1 = 1 AND follows.account_id = \"$1\" ORDER BY follows.id DESC LIMIT \"$2\"",
            "cost": 16.62,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT follows.id AS alias_0, accounts.id FROM accounts INNER JOIN follows ON follows.target_account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE 1 = 1 AND follows.account_id = \"$1\" ORDER BY follows.id DESC LIMIT \"$2\"",
            "cost": 16.62,
            "rewrite_types": [
                "RemoveDistinct",
                "ReplaceOuterJoin"
            ]
        }
    ]
}