{
    "org": {
        "sql": "SELECT COUNT(*) FROM users INNER JOIN friends ON users.id = friends.friend_user_id INNER JOIN users AS befriendees_friends ON befriendees_friends.id = friends.friend_user_id WHERE friends.user_id = \"$1\" AND users.status IN (\"$2\", \"$3\")",
        "cost": 29.23,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT COUNT(*) FROM users INNER JOIN friends ON users.id = friends.friend_user_id WHERE friends.user_id = \"$1\" AND users.status IN (\"$2\", \"$3\")",
            "cost": 27.97,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}