{
    "org": {
        "sql": "SELECT spree_products.id AS t0_r0, spree_products.name AS t0_r1, spree_products.description AS t0_r2, spree_products.available_on AS t0_r3, spree_products.deleted_at AS t0_r4, spree_products.slug AS t0_r5, spree_products.meta_description AS t0_r6, spree_products.meta_keywords AS t0_r7, spree_products.tax_category_id AS t0_r8, spree_products.shipping_category_id AS t0_r9, spree_products.created_at AS t0_r10, spree_products.updated_at AS t0_r11, spree_products.promotionable AS t0_r12, spree_products.meta_title AS t0_r13, spree_products.discontinue_on AS t0_r14, spree_products.public_metadata AS t0_r15, spree_products.private_metadata AS t0_r16, spree_products_taxons.id AS t1_r0, spree_products_taxons.product_id AS t1_r1, spree_products_taxons.taxon_id AS t1_r2, spree_products_taxons.position AS t1_r3, spree_products_taxons.created_at AS t1_r4, spree_products_taxons.updated_at AS t1_r5 FROM spree_products LEFT OUTER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id = \"$1\" ORDER BY spree_products_taxons.position ASC",
        "cost": 28.08,
        "rewrite_types": []
    },
    "rewrites": [
        {
            "sql": "SELECT spree_products.id AS t0_r0, spree_products.name AS t0_r1, spree_products.description AS t0_r2, spree_products.available_on AS t0_r3, spree_products.deleted_at AS t0_r4, spree_products.slug AS t0_r5, spree_products.meta_description AS t0_r6, spree_products.meta_keywords AS t0_r7, spree_products.tax_category_id AS t0_r8, spree_products.shipping_category_id AS t0_r9, spree_products.created_at AS t0_r10, spree_products.updated_at AS t0_r11, spree_products.promotionable AS t0_r12, spree_products.meta_title AS t0_r13, spree_products.discontinue_on AS t0_r14, spree_products.public_metadata AS t0_r15, spree_products.private_metadata AS t0_r16, spree_products_taxons.id AS t1_r0, spree_products_taxons.product_id AS t1_r1, spree_products_taxons.taxon_id AS t1_r2, spree_products_taxons.position AS t1_r3, spree_products_taxons.created_at AS t1_r4, spree_products_taxons.updated_at AS t1_r5 FROM spree_products LEFT OUTER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id = \"$1\" ORDER BY spree_products_taxons.position ASC LIMIT 1",
            "cost": 28.07,
            "rewrite_types": [
                "AddLimitOne"
            ]
        },
        {
            "sql": "SELECT spree_products.id AS t0_r0, spree_products.name AS t0_r1, spree_products.description AS t0_r2, spree_products.available_on AS t0_r3, spree_products.deleted_at AS t0_r4, spree_products.slug AS t0_r5, spree_products.meta_description AS t0_r6, spree_products.meta_keywords AS t0_r7, spree_products.tax_category_id AS t0_r8, spree_products.shipping_category_id AS t0_r9, spree_products.created_at AS t0_r10, spree_products.updated_at AS t0_r11, spree_products.promotionable AS t0_r12, spree_products.meta_title AS t0_r13, spree_products.discontinue_on AS t0_r14, spree_products.public_metadata AS t0_r15, spree_products.private_metadata AS t0_r16, spree_products_taxons.id AS t1_r0, spree_products_taxons.product_id AS t1_r1, spree_products_taxons.taxon_id AS t1_r2, spree_products_taxons.position AS t1_r3, spree_products_taxons.created_at AS t1_r4, spree_products_taxons.updated_at AS t1_r5 FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id WHERE spree_products.deleted_at IS NULL AND spree_products_taxons.taxon_id = \"$1\" ORDER BY spree_products_taxons.position ASC LIMIT 1",
            "cost": 28.07,
            "rewrite_types": [
                "AddLimitOne",
                "ReplaceOuterJoin"
            ]
        }
    ]
}