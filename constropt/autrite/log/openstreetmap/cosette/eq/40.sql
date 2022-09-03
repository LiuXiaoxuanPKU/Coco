{
    "org": {
        "sql": "SELECT gpx_files.id AS t0_r0, gpx_files.user_id AS t0_r1, gpx_files.visible AS t0_r2, gpx_files.name AS t0_r3, gpx_files.size AS t0_r4, gpx_files.latitude AS t0_r5, gpx_files.longitude AS t0_r6, gpx_files.timestamp AS t0_r7, gpx_files.description AS t0_r8, gpx_files.inserted AS t0_r9, gpx_files.visibility AS t0_r10, users.email AS t1_r0, users.id AS t1_r1, users.pass_crypt AS t1_r2, users.creation_time AS t1_r3, users.display_name AS t1_r4, users.data_public AS t1_r5, users.description AS t1_r6, users.home_lat AS t1_r7, users.home_lon AS t1_r8, users.home_zoom AS t1_r9, users.pass_salt AS t1_r10, users.email_valid AS t1_r11, users.new_email AS t1_r12, users.creation_ip AS t1_r13, users.languages AS t1_r14, users.status AS t1_r15, users.terms_agreed AS t1_r16, users.consider_pd AS t1_r17, users.auth_uid AS t1_r18, users.preferred_editor AS t1_r19, users.terms_seen AS t1_r20, users.description_format AS t1_r21, users.changesets_count AS t1_r22, users.traces_count AS t1_r23, users.diary_entries_count AS t1_r24, users.image_use_gravatar AS t1_r25, users.auth_provider AS t1_r26, users.home_tile AS t1_r27, users.tou_agreed AS t1_r28 FROM gpx_files INNER JOIN users ON users.id = gpx_files.user_id INNER JOIN gpx_file_tags ON gpx_file_tags.gpx_id = gpx_files.id WHERE gpx_files.visibility IN (\"$1\", \"$2\") AND gpx_files.visible = \"$3\" AND users.display_name = \"$4\" AND gpx_file_tags.tag = \"$5\" AND gpx_files.id = \"$6\" ORDER BY timestamp DESC",
        "cost": 25.08,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT gpx_files.id AS t0_r0, gpx_files.user_id AS t0_r1, gpx_files.visible AS t0_r2, gpx_files.name AS t0_r3, gpx_files.size AS t0_r4, gpx_files.latitude AS t0_r5, gpx_files.longitude AS t0_r6, gpx_files.timestamp AS t0_r7, gpx_files.description AS t0_r8, gpx_files.inserted AS t0_r9, gpx_files.visibility AS t0_r10, users.email AS t1_r0, users.id AS t1_r1, users.pass_crypt AS t1_r2, users.creation_time AS t1_r3, users.display_name AS t1_r4, users.data_public AS t1_r5, users.description AS t1_r6, users.home_lat AS t1_r7, users.home_lon AS t1_r8, users.home_zoom AS t1_r9, users.pass_salt AS t1_r10, users.email_valid AS t1_r11, users.new_email AS t1_r12, users.creation_ip AS t1_r13, users.languages AS t1_r14, users.status AS t1_r15, users.terms_agreed AS t1_r16, users.consider_pd AS t1_r17, users.auth_uid AS t1_r18, users.preferred_editor AS t1_r19, users.terms_seen AS t1_r20, users.description_format AS t1_r21, users.changesets_count AS t1_r22, users.traces_count AS t1_r23, users.diary_entries_count AS t1_r24, users.image_use_gravatar AS t1_r25, users.auth_provider AS t1_r26, users.home_tile AS t1_r27, users.tou_agreed AS t1_r28 FROM gpx_files INNER JOIN users ON users.id = gpx_files.user_id WHERE gpx_files.visibility IN (\"$1\", \"$2\") AND gpx_files.visible = \"$3\" AND users.display_name = \"$4\" AND gpx_files.id = \"$6\" ORDER BY timestamp DESC",
            "cost": 16.64,
            "rewrite_types": [
                "RemoveJoin"
            ]
        },
        {
            "sql": "SELECT gpx_files.id AS t0_r0, gpx_files.user_id AS t0_r1, gpx_files.visible AS t0_r2, gpx_files.name AS t0_r3, gpx_files.size AS t0_r4, gpx_files.latitude AS t0_r5, gpx_files.longitude AS t0_r6, gpx_files.timestamp AS t0_r7, gpx_files.description AS t0_r8, gpx_files.inserted AS t0_r9, gpx_files.visibility AS t0_r10, users.email AS t1_r0, users.id AS t1_r1, users.pass_crypt AS t1_r2, users.creation_time AS t1_r3, users.display_name AS t1_r4, users.data_public AS t1_r5, users.description AS t1_r6, users.home_lat AS t1_r7, users.home_lon AS t1_r8, users.home_zoom AS t1_r9, users.pass_salt AS t1_r10, users.email_valid AS t1_r11, users.new_email AS t1_r12, users.creation_ip AS t1_r13, users.languages AS t1_r14, users.status AS t1_r15, users.terms_agreed AS t1_r16, users.consider_pd AS t1_r17, users.auth_uid AS t1_r18, users.preferred_editor AS t1_r19, users.terms_seen AS t1_r20, users.description_format AS t1_r21, users.changesets_count AS t1_r22, users.traces_count AS t1_r23, users.diary_entries_count AS t1_r24, users.image_use_gravatar AS t1_r25, users.auth_provider AS t1_r26, users.home_tile AS t1_r27, users.tou_agreed AS t1_r28 FROM gpx_files INNER JOIN users ON users.id = gpx_files.user_id WHERE gpx_files.visibility IN (\"$1\", \"$2\") AND gpx_files.visible = \"$3\" AND users.display_name = \"$4\" AND gpx_files.id = \"$6\" ORDER BY timestamp DESC LIMIT 1",
            "cost": 16.64,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        }
    ]
}