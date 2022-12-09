import os
import sys
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "src"))

import rule
from config import RewriteQuery, get_path, FileType
import loader
from mo_sql_parsing import parse, format
from rewriter import Rewriter
from constraint import *

def test_get_constraints():
    constraints = [UniqueConstraint("users", ["id"], False, 'builtin', None),
                   UniqueConstraint(
                       "projects", ["id"], False, 'builtin', None),
                   InclusionConstraint("users", "id", False, [1, 2]),
                   UniqueConstraint(
                       "members", ["name"], False, 'builtin', None),
                   UniqueConstraint("users", ["name"], False, 'builtin', None)]
    q_before_str = "select distinct (*) from users where id \
                        in (select distinct user_id from projects)"
    rewriter = Rewriter()
    q = RewriteQuery(q_before_str, parse(q_before_str))
    constraints = rewriter.get_q_constraints(constraints, q.q_obj)
    assert(len(constraints) == 2)


def test_get_rules():
    constraints = [UniqueConstraint("users", ["id"], False, 'builtin', None),
                   NumericalConstraint("projects", "id", False, 0, 100),
                   InclusionConstraint("users", "id", False, [1, 2])]
    rewriter = Rewriter()
    rules = rewriter.get_rules(constraints)
    assert(len(set(rules)) == 4)


def compare_helper(constraints, q_str):
    rewriter = Rewriter()
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    print("------------------------Start Rewrite------------------------")
    print("Before:\n", format(parse(q_str)))
    print("After:", len(rewritten_queries))
    for q in rewritten_queries:
        print(q.q_raw)
    if len(rewritten_queries) > 0:
        print(len(rewritten_queries[0].q_raw))
    print("------------------------Finish Rewrite------------------------")


def test_simple_enumerate():
    constraints = [UniqueConstraint("users", ["id"], False, 'builtin', None)]
    q_before_str = "select distinct (*) from users where id in (select distinct user_id from projects)"
    compare_helper(constraints, q_before_str)


def test_redmine_enumerate():
    constraints = loader.read_constraints(get_path(FileType.CONSTRAINT, "redmine", "data"), include_all=False)
    q_before_str = "SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.status = 2 AND members.project_id = 1 AND users.status = 2 AND users.status = 2 AND users.type IN ('User', 'User');"
    compare_helper(constraints, q_before_str)


def test_add_limit_one_rewrite():
    constraints = [UniqueConstraint("R", ["a", "b"], False, "builtin", "")]
    rewriter = Rewriter()
    rules = [rule.AddLimitOne]
    rewriter.set_rules(rules)

    q_str = 'select * from R where a = 1'
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 0)

    q_str = 'select * from R where a = 1 and b = 1'
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 1)

    q_str = 'select a from R where b = 1 order by a'
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 1)

    q_str = 'select a from R where b = 1 and c = 1'
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 1)

    q_str = 'select a from R1 where b = 1 and c = 1'
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 0)


def test_rewrite_types():
    c1 = PresenceConstraint("R", "a", False)
    c2 = PresenceConstraint("R", "b", False)
    constraints = [c1, c2]
    rewriter = Rewriter()
    rules = [rule.RewriteNullPredicate]
    rewriter.set_rules(rules)

    q_str = 'select * from R where a is NULL and b is NULL'
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 3)
    assert(rewritten_queries[0].rewrites == [rule.RewriteNullPredicate(c1)] or
           rewritten_queries[0].rewrites == [rule.RewriteNullPredicate(c2)])
    assert(rewritten_queries[1].rewrites == [rule.RewriteNullPredicate(c2)] or
           rewritten_queries[1].rewrites == [rule.RewriteNullPredicate(c1)])
    assert(rewritten_queries[2].rewrites == [rule.RewriteNullPredicate(c1), rule.RewriteNullPredicate(c2)] or
           rewritten_queries[2].rewrites == [rule.RewriteNullPredicate(c2), rule.RewriteNullPredicate(c1)])
    
def test_rewrite_spree():
    constraints = loader.read_constraints(get_path(FileType.CONSTRAINT, "spree"))
    sql = 'SELECT DISTINCT spree_stock_locations.* FROM spree_stock_locations INNER JOIN spree_stock_items ON spree_stock_items.deleted_at IS NULL AND spree_stock_items.stock_location_id = spree_stock_locations.id WHERE spree_stock_locations.active = \"$1\" AND spree_stock_items.variant_id IN (\"$2\", \"$3\")'
    compare_helper(constraints, sql)
    sql = 'SELECT DISTINCT spree_shipping_categories.* FROM spree_shipping_categories INNER JOIN spree_products ON spree_products.deleted_at IS NULL AND spree_products.shipping_category_id = spree_shipping_categories.id INNER JOIN spree_variants ON spree_variants.deleted_at IS NULL AND spree_variants.product_id = spree_products.id WHERE spree_variants.id = 4289;'
    compare_helper(constraints, sql)
    sql = 'SELECT COUNT(DISTINCT spree_option_values.option_type_id) FROM spree_option_values WHERE spree_option_values.id IN (7878, 3936);'
    compare_helper(constraints, sql)
    sql = 'SELECT COUNT(DISTINCT spree_option_values.option_type_id) FROM spree_option_values WHERE spree_option_values.id = 4493;'
    compare_helper(constraints, sql)
    sql = 'SELECT DISTINCT spree_stock_locations.* FROM spree_stock_locations INNER JOIN spree_stock_items ON spree_stock_items.deleted_at IS NULL AND spree_stock_items.stock_location_id = spree_stock_locations.id WHERE spree_stock_locations.active = True AND spree_stock_items.variant_id = 4620;'
    compare_helper(constraints, sql)
    sql = "SELECT 1 AS one FROM spree_products INNER JOIN friendly_id_slugs ON friendly_id_slugs.deleted_at IS NULL AND friendly_id_slugs.sluggable_type = $1 AND friendly_id_slugs.sluggable_id = spree_products.id WHERE spree_products.id IS NOT NULL AND friendly_id_slugs.sluggable_type = 'Spree::Product' AND friendly_id_slugs.slug = 'product-593-398' LIMIT $2"
    print(len(sql))
    compare_helper(constraints, sql)
    
def test_rewrite_mastodon():
    constraints = loader.read_constraints(get_path(FileType.CONSTRAINT, "mastodon", "data"), include_all=False, remove_pk=False)
    sql = 'SELECT oauth_applications.* FROM oauth_applications WHERE oauth_applications.id IN (SELECT DISTINCT oauth_access_tokens.application_id FROM oauth_access_tokens WHERE oauth_access_tokens.resource_owner_id = 865 AND oauth_access_tokens.revoked_at IS NULL)'
    compare_helper(constraints, sql)
    
def test_rewrite_openstreetmap():
    constraints = loader.read_constraints(get_path(FileType.CONSTRAINT, "openstreetmap", "data"), include_all=False, remove_pk=False)
    sql = 'SELECT 1 AS "one" FROM users INNER JOIN friends ON users.id = friends.friend_user_id INNER JOIN users AS befriendees_friends ON befriendees_friends.id = friends.friend_user_id WHERE friends.user_id = 4863 AND users.status IN (\'pending\', \'pending\') LIMIT 1;'
    compare_helper(constraints, sql)
    
if __name__ == "__main__":
    # test_get_constraints()
    # test_get_rules()
    # test_simple_enumerate()
    # test_redmine_enumerate()
    # test_add_limit_one_rewrite()
    # test_rewrite_types()
    # test_rewriter_spree()
    # test_rewrite_mastodon()
    test_rewrite_openstreetmap()
