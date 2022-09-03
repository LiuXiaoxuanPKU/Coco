{
    "org": {
        "sql": "SELECT DISTINCT timestamp AS alias_0, gpx_files.id FROM gpx_files INNER JOIN users ON users.id = gpx_files.user_id INNER JOIN gpx_file_tags ON gpx_file_tags.gpx_id = gpx_files.id WHERE gpx_files.visibility IN (\"$1\", \"$2\") AND gpx_files.visible = \"$3\" AND users.display_name = \"$4\" AND gpx_file_tags.tag = \"$5\" ORDER BY timestamp DESC LIMIT \"$6\"",
        "cost": 18.42,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT timestamp AS alias_0, gpx_files.id FROM gpx_files INNER JOIN users ON users.id = gpx_files.user_id INNER JOIN gpx_file_tags ON gpx_file_tags.gpx_id = gpx_files.id WHERE gpx_files.visibility IN (\"$1\", \"$2\") AND gpx_files.visible = \"$3\" AND users.display_name = \"$4\" AND gpx_file_tags.tag = \"$5\" ORDER BY timestamp DESC LIMIT \"$6\"",
            "cost": 18.41,
            "rewrite_types": [
                "RemoveDistinct"
            ]
        }
    ]
}