{
    "org": {
        "sql": "SELECT users.* FROM users INNER JOIN friends ON users.id = friends.friend_user_id INNER JOIN users AS befriendees_friends ON befriendees_friends.id = friends.friend_user_id WHERE friends.user_id = \"$1\" AND users.status IN (\"$2\", \"$3\")",
        "cost": 29.21,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT users.* FROM users INNER JOIN friends ON users.id = friends.friend_user_id WHERE friends.user_id = \"$1\" AND users.status IN (\"$2\", \"$3\")",
            "cost": 27.95,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}