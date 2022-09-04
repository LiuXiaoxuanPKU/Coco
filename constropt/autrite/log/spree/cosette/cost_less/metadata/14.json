{
    "org": {
        "sql": "SELECT spree_taxons.* FROM spree_taxons INNER JOIN spree_prototype_taxons ON spree_taxons.id = spree_prototype_taxons.taxon_id WHERE spree_prototype_taxons.prototype_id = \"$1\"",
        "cost": 24.93,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_taxons.* FROM spree_taxons INNER JOIN spree_prototype_taxons ON spree_taxons.id = spree_prototype_taxons.taxon_id WHERE spree_prototype_taxons.prototype_id = \"$1\" LIMIT 1",
            "cost": 12.75,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}