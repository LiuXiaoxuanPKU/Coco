{
    "org": {
        "sql": "SELECT name, custom_emoji_id, COUNT(*) AS count, (SELECT 1 FROM announcement_reactions AS r WHERE r.account_id = 108774566504673364 AND r.announcement_id = announcement_reactions.announcement_id AND r.name = announcement_reactions.name) IS NOT NULL AS me FROM announcement_reactions WHERE announcement_reactions.announcement_id = \"$1\" GROUP BY announcement_reactions.announcement_id, announcement_reactions.name, announcement_reactions.custom_emoji_id ORDER BY MIN(created_at) ASC",
        "cost": 20.18
    },
    "rewrites": [
        {
            "sql": "SELECT name, custom_emoji_id, COUNT(*) AS count, (SELECT 1 FROM announcement_reactions AS r WHERE r.account_id = 108774566504673364 AND r.announcement_id = announcement_reactions.announcement_id AND r.name = announcement_reactions.name) IS NOT NULL AS me FROM announcement_reactions WHERE announcement_reactions.announcement_id = \"$1\" GROUP BY announcement_reactions.announcement_id, announcement_reactions.name, announcement_reactions.custom_emoji_id ORDER BY MIN(created_at) ASC LIMIT 1",
            "cost": 15.88,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}