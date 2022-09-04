{
    "org": {
        "sql": "SELECT mentions.id, mentions.account_id FROM mentions INNER JOIN accounts ON accounts.id = mentions.account_id INNER JOIN users ON users.account_id = accounts.id INNER JOIN follows ON accounts.id = follows.account_id WHERE mentions.status_id = \"$1\" AND follows.target_account_id = \"$2\" AND accounts.domain IS NULL AND users.current_sign_in_at > '2022-07-30 06:45:50.262098' ORDER BY mentions.id ASC LIMIT \"$3\"",
        "cost": 29.33,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT mentions.id, mentions.account_id FROM mentions INNER JOIN accounts ON accounts.id = mentions.account_id INNER JOIN follows ON accounts.id = follows.account_id WHERE mentions.status_id = \"$1\" AND follows.target_account_id = \"$2\" AND accounts.domain IS NULL ORDER BY mentions.id ASC LIMIT \"$3\"",
            "cost": 28.75,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT mentions.id, mentions.account_id FROM mentions INNER JOIN accounts ON accounts.id = mentions.account_id INNER JOIN users ON users.account_id = accounts.id WHERE mentions.status_id = \"$1\" AND accounts.domain IS NULL AND users.current_sign_in_at > '2022-07-30 06:45:50.262098' ORDER BY mentions.id ASC LIMIT \"$3\"",
            "cost": 29.24,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}