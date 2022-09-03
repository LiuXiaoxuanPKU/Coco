{
    "org": {
        "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products.id = spree_products_taxons.product_id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id = \"$1\" ORDER BY spree_products_taxons.position ASC",
        "cost": 28.08,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.* FROM spree_products INNER JOIN spree_products_taxons ON spree_products.id = spree_products_taxons.product_id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id = \"$1\" ORDER BY spree_products_taxons.position ASC LIMIT 1",
            "cost": 28.07,
            "rewrite_types": [
                "AddLimitOne"
            ]
        }
    ]
}