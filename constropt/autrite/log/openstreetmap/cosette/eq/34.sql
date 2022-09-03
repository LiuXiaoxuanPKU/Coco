{
    "org": {
        "sql": "SELECT diary_comments.* FROM diary_comments INNER JOIN users ON users.id = diary_comments.user_id WHERE diary_comments.diary_entry_id = \"$1\" AND diary_comments.visible = \"$2\" AND users.status IN (\"$3\", \"$4\") ORDER BY diary_comments.id ASC",
        "cost": 1758.53,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT diary_comments.* FROM diary_comments WHERE diary_comments.diary_entry_id = \"$1\" AND diary_comments.visible = \"$2\" ORDER BY diary_comments.id ASC",
            "cost": 701.53,
            "rewrite_types": [
                "RemoveJoin"
            ]
        }
    ]
}