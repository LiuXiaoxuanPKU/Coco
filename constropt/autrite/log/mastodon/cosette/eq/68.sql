{
    "org": {
        "sql": "SELECT follows.id FROM follows WHERE follows.target_account_id = \"$1\" AND follows.account_id IN (SELECT accounts.id FROM accounts WHERE accounts.domain IS NULL) AND follows.account_id NOT IN (SELECT accounts.id FROM accounts INNER JOIN follows ON accounts.id = follows.account_id WHERE follows.target_account_id = \"$2\" AND accounts.domain IS NULL ORDER BY follows.id DESC) AND follows.account_id <> \"$3\" ORDER BY follows.id ASC LIMIT \"$4\"",
        "cost": 48.28
    },
    "rewrites": [
        {
            "sql": "SELECT follows.id FROM follows WHERE follows.target_account_id = \"$1\" AND follows.account_id IN (SELECT accounts.id FROM accounts WHERE accounts.domain IS NULL LIMIT 1) AND follows.account_id NOT IN (SELECT accounts.id FROM accounts WHERE accounts.domain IS NULL ORDER BY follows.id DESC LIMIT 1) AND follows.account_id <> \"$3\" ORDER BY follows.id ASC LIMIT \"$4\"",
            "cost": 12.07,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT follows.id FROM follows WHERE follows.target_account_id = \"$1\" AND follows.account_id IN (SELECT accounts.id FROM accounts WHERE accounts.domain IS NULL LIMIT 1) AND follows.account_id NOT IN (SELECT accounts.id FROM accounts INNER JOIN follows ON accounts.id = follows.account_id WHERE follows.target_account_id = \"$2\" AND accounts.domain IS NULL ORDER BY follows.id DESC) AND follows.account_id <> \"$3\" ORDER BY follows.id ASC LIMIT \"$4\"",
            "cost": 40.18,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT follows.id FROM follows WHERE follows.target_account_id = \"$1\" AND follows.account_id IN (SELECT accounts.id FROM accounts WHERE accounts.domain IS NULL LIMIT 1) AND follows.account_id NOT IN (SELECT accounts.id FROM accounts INNER JOIN follows ON accounts.id = follows.account_id WHERE follows.target_account_id = \"$2\" AND accounts.domain IS NULL ORDER BY follows.id DESC LIMIT 1) AND follows.account_id <> \"$3\" ORDER BY follows.id ASC LIMIT \"$4\"",
            "cost": 40.18,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        }
    ]
}