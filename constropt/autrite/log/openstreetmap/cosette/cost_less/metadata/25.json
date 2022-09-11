{
    "org": {
        "sql": "SELECT COUNT(*) FROM friends INNER JOIN users ON users.id = friends.friend_user_id WHERE friends.user_id = \"$1\" AND users.status IN (\"$2\", \"$3\") AND created_at >= '2022-08-29 20:22:41.565818'",
        "cost": 27.98,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT COUNT(*) FROM friends WHERE friends.user_id = \"$1\" AND created_at >= '2022-08-29 20:22:41.565818'",
            "cost": 4.34,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}