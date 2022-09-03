{
    "org": {
        "sql": "SELECT DISTINCT follows.id AS alias_0, accounts.id FROM accounts LEFT OUTER JOIN follows ON follows.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE follows.target_account_id = \"$1\" ORDER BY follows.id DESC LIMIT \"$2\"",
        "cost": 24.29,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT follows.id AS alias_0, accounts.id FROM accounts LEFT OUTER JOIN follows ON follows.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE follows.target_account_id = \"$1\" ORDER BY follows.id DESC LIMIT \"$2\"",
            "cost": 24.28,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        },
        {
            "sql": "SELECT follows.id AS alias_0, accounts.id FROM accounts INNER JOIN follows ON follows.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE follows.target_account_id = \"$1\" ORDER BY follows.id DESC LIMIT \"$2\"",
            "cost": 24.28,
            "rewrite_types": [
                "RemoveDistinct",
                "ReplaceOuterJoin"
            ]
        }
    ]
}