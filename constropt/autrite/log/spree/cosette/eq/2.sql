{
    "org": {
        "sql": "SELECT spree_dummy_models.* FROM spree_dummy_models WHERE spree_dummy_models.name = 'TestName'",
        "cost": 21.5,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_dummy_models.* FROM spree_dummy_models WHERE spree_dummy_models.name = 'TestName' LIMIT 1",
            "cost": 4.3,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}