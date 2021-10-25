# Constraint Extraction
- Inclusion constraints
- design the if condition representation for unique/presence constraints
- Extract database constraints
- Map constraint class name to table name

# Query Rewrite
Currently, query rewrite is missing lots of cases, we need to first test if the current rewrite strategy can pass old rewritten cases

## Fix Parsing Failure
- [Error] Fail to parse  SELECT DISTINCT "news"."created_on", "news"."id" FROM "news" INNER JOIN "projects" ON "projects"."id" = "news"."project_id" INNER JOIN "attachments" ON "attachments"."container_type" = $1 AND "attachments"."container_id" = "news"."id" WHERE (((projects.status <> 9 AND EXISTS (SELECT 1 AS one FROM enabled_modules em WHERE em.project_id = projects.id AND em.name='news')) AND ((projects.is_public = TRUE AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (6,13)))))) AND (news.project_id IN (1)) AND (((attachments.filename ILIKE '%search_attachments%') OR (attachments.description ILIKE '%search_attachments%'))) ORDER BY "news"."created_on" DESC, "news"."id" DESC
- [Error] Fail to parse  SELECT DISTINCT "documents"."created_on", "documents"."id" FROM "documents" INNER JOIN "projects" ON "projects"."id" = "documents"."project_id" INNER JOIN "attachments" ON "attachments"."container_type" = $1 AND "attachments"."container_id" = "documents"."id" WHERE (((projects.status <> 9 AND EXISTS (SELECT 1 AS one FROM enabled_modules em WHERE em.project_id = projects.id AND em.name='documents')) AND ((projects.is_public = TRUE AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (6,13)))))) AND (documents.project_id IN (1)) AND (((attachments.filename ILIKE '%search_attachments%') OR (attachments.description ILIKE '%search_attachments%'))) ORDER BY "documents"."created_on" DESC, "documents"."id" DESC
- [Error] Fail to parse  SELECT DISTINCT "wiki_pages"."created_on", "wiki_pages"."id" FROM "wiki_pages" INNER JOIN "wiki_contents" ON "wiki_contents"."page_id" = "wiki_pages"."id" INNER JOIN "wikis" ON "wikis"."id" = "wiki_pages"."wiki_id" INNER JOIN "projects" ON "projects"."id" = "wikis"."project_id" INNER JOIN "attachments" ON "attachments"."container_type" = $1 AND "attachments"."container_id" = "wiki_pages"."id" WHERE (((projects.status <> 9 AND EXISTS (SELECT 1 AS one FROM enabled_modules em WHERE em.project_id = projects.id AND em.name='wiki')) AND ((projects.is_public = TRUE AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (6,13)))))) AND (wikis.project_id IN (1)) AND (((attachments.filename ILIKE '%search_attachments%') OR (attachments.description ILIKE '%search_attachments%'))) ORDER BY "wiki_pages"."created_on" DESC, "wiki_pages"."id" DESC
- [Error] Fail to parse  SELECT DISTINCT "messages"."created_on", "messages"."id" FROM "messages" INNER JOIN "boards" ON "boards"."id" = "messages"."board_id" INNER JOIN "projects" ON "projects"."id" = "boards"."project_id" INNER JOIN "attachments" ON "attachments"."container_type" = $1 AND "attachments"."container_id" = "messages"."id" WHERE (((projects.status <> 9 AND EXISTS (SELECT 1 AS one FROM enabled_modules em WHERE em.project_id = projects.id AND em.name='boards')) AND ((projects.is_public = TRUE AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (6,13)))))) AND (boards.project_id IN (1)) AND (((attachments.filename ILIKE '%search_attachments%') OR (attachments.description ILIKE '%search_attachments%'))) ORDER BY "messages"."created_on" DESC, "messages"."id" DESC

## Add Limit 1
- support unique constraints with multiple columns
- support nested queries for add limit 1

## Remove Distinct
- support unique constraints with multiple columns

## Remove Predicate
- Use z3 to remove predicates

## String to Enumeration
- Debug: it's missing lots, lots of cases

# End to End Experiment
- replace parameters with exact values
- logic for lookup table
- populate redmine tables again
