{
    "org": {
        "sql": "SELECT note_comments.* FROM note_comments LEFT OUTER JOIN users ON users.id = note_comments.author_id WHERE note_comments.visible = \"$1\" AND (users.status IN (\"$2\", \"$3\") OR users.status IS NULL) AND note_comments.note_id IN (\"$4\", \"$5\") ORDER BY note_comments.created_at ASC",
        "cost": 35.68,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT note_comments.* FROM note_comments LEFT OUTER JOIN users ON users.id = note_comments.author_id WHERE note_comments.visible = \"$1\" AND (users.status IN (\"$2\", \"$3\") OR users.status IS NULL) AND note_comments.note_id IN (\"$4\", \"$5\") ORDER BY note_comments.created_at ASC LIMIT 1",
            "cost": 35.67,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}