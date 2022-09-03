{
    "org": {
        "sql": "SELECT COUNT(*) FROM diary_comments INNER JOIN users ON users.id = diary_comments.user_id WHERE diary_comments.diary_entry_id = \"$1\" AND diary_comments.visible = \"$2\" AND users.status IN (\"$3\", \"$4\")",
        "cost": 1454.71,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT COUNT(*) FROM diary_comments WHERE diary_comments.diary_entry_id = \"$1\" AND diary_comments.visible = \"$2\"",
            "cost": 397.71,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT COUNT(*) FROM diary_comments WHERE diary_comments.diary_entry_id = \"$1\" AND diary_comments.visible = \"$2\" LIMIT 1",
            "cost": 397.71,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        }
    ]
}