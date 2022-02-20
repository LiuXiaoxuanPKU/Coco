SELECT issue_statuses.* FROM issue_statuses WHERE (default_done_ratio >= 0)
SELECT 1 AS one FROM wiki_pages WHERE LOWER(wiki_pages.title) = LOWER($1) AND wiki_pages.wiki_id IS NULL LIMIT $2
SELECT 1 AS one FROM members WHERE members.user_id IS NULL AND members.project_id = $1 LIMIT $2
SELECT 1 AS one FROM issue_relations WHERE issue_relations.issue_to_id IS NULL AND issue_relations.issue_from_id = $1 LIMIT $2
SELECT members.* FROM members INNER JOIN projects ON projects.id = members.project_id WHERE members.user_id = $1 AND projects.status != $2 AND members.project_id IS NULL ORDER BY members.id ASC LIMIT $3
SELECT 1 AS one FROM wiki_pages WHERE wiki_pages.title IS NULL AND wiki_pages.wiki_id = $1 LIMIT $2
SELECT 1 AS one FROM watchers WHERE watchers.user_id = $1 AND watchers.watchable_type = $2 AND watchers.watchable_id IS NULL LIMIT $3