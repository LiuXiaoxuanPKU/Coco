{
    "org": {
        "sql": "SELECT 1 AS one FROM note_comments WHERE note_comments.id IS NULL LIMIT \"$1\"",
        "cost": 4.3,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT 1 AS one FROM note_comments WHERE False LIMIT \"$1\"",
            "cost": 0.0,
            "rewrite_types": [
                "RewriteNullPredicate"
            ]
        }
    ]
}