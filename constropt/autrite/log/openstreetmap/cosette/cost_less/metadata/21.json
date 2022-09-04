{
    "org": {
        "sql": "SELECT 1 AS one FROM friends INNER JOIN users ON users.id = friends.friend_user_id WHERE friends.user_id = \"$1\" AND users.status IN (\"$2\", \"$3\") AND friends.friend_user_id = \"$4\" LIMIT \"$5\"",
        "cost": 19.66,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM friends WHERE friends.user_id = \"$1\" AND friends.friend_user_id = \"$4\" LIMIT \"$5\"",
            "cost": 11.34,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}