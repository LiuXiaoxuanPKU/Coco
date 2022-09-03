{
    "org": {
        "sql": "SELECT spree_products.id FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id IN (\"$1\", \"$2\") GROUP BY spree_products.id HAVING COUNT(spree_products.id) = 2",
        "cost": 78.18,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.id FROM spree_products WHERE spree_products.deleted_at IS NULL GROUP BY spree_products.id HAVING COUNT(spree_products.id) = 2 LIMIT 1",
            "cost": 32.93,
            "rewrite_types": [
                "RemoveJoin",
                "AddLimitOne"
            ]
        }
    ]
}