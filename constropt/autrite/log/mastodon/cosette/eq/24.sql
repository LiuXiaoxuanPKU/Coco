{
    "org": {
        "sql": "SELECT DISTINCT follow_requests.id AS alias_0, accounts.id FROM accounts LEFT OUTER JOIN follow_requests ON follow_requests.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE accounts.suspended_at IS NULL AND follow_requests.target_account_id = \"$1\" ORDER BY follow_requests.id DESC LIMIT \"$2\"",
        "cost": 291.94
    },
    "rewrites": [
        {
            "sql": "SELECT follow_requests.id AS alias_0, accounts.id FROM accounts LEFT OUTER JOIN follow_requests ON follow_requests.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE accounts.suspended_at IS NULL AND follow_requests.target_account_id = \"$1\" ORDER BY follow_requests.id DESC LIMIT \"$2\"",
            "cost": 291.93,
            "rewrite_types": [
                "RemoveDistinct",
                "ReplaceOuterJoin"
            ]
        },
        {
            "sql": "SELECT follow_requests.id AS alias_0, accounts.id FROM accounts INNER JOIN follow_requests ON follow_requests.account_id = accounts.id LEFT OUTER JOIN account_stats ON account_stats.account_id = accounts.id WHERE accounts.suspended_at IS NULL AND follow_requests.target_account_id = \"$1\" ORDER BY follow_requests.id DESC LIMIT \"$2\"",
            "cost": 291.93,
            "rewrite_types": [
                "RemoveDistinct",
                "ReplaceOuterJoin"
            ]
        }
    ]
}