{
    "org": {
        "sql": "SELECT custom_emojis.* FROM custom_emojis LEFT OUTER JOIN custom_emoji_categories ON custom_emoji_categories.id = custom_emojis.category_id WHERE custom_emojis.domain IS NULL ORDER BY custom_emoji_categories.name ASC, custom_emojis.shortcode ASC",
        "cost": 471.2,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT custom_emojis.* FROM custom_emojis INNER JOIN custom_emoji_categories ON custom_emoji_categories.id = custom_emojis.category_id WHERE custom_emojis.domain IS NULL ORDER BY custom_emoji_categories.name ASC, custom_emojis.shortcode ASC LIMIT 1",
            "cost": 396.28,
            "rewrite_types": [
                "AddLimitOne",
                "ReplaceOuterJoin"
            ]
        }
    ]
}