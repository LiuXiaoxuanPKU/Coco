{
    "org": {
        "sql": "SELECT DISTINCT users.* FROM users INNER JOIN user_roles ON user_roles.user_id = users.id WHERE user_roles.role = \"$1\"",
        "cost": 1613.88,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT users.* FROM users INNER JOIN user_roles ON user_roles.user_id = users.id WHERE user_roles.role = \"$1\"",
            "cost": 1201.71,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        }
    ]
}