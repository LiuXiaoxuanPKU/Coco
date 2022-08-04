SELECT 1 AS one FROM "wiki_pages" WHERE LOWER("wiki_pages"."title") = LOWER($1) AND "wiki_pages"."wiki_id" IS NULL LIMIT $2
SELECT 1 AS one FROM "members" WHERE "members"."user_id" IS NULL AND "members"."project_id" = $1 LIMIT $2
SELECT 1 AS one FROM "issue_relations" WHERE "issue_relations"."issue_to_id" IS NULL AND "issue_relations"."issue_from_id" = $1 LIMIT $2
SELECT "time_entries".* FROM "time_entries" WHERE "time_entries"."issue_id" IS NULL ORDER BY "time_entries"."id" ASC LIMIT $1
SELECT "members".* FROM "members" INNER JOIN "projects" ON "projects"."id" = "members"."project_id" WHERE "members"."user_id" = $1 AND "projects"."status" != $2 AND "members"."project_id" IS NULL ORDER BY "members"."id" ASC LIMIT $3
SELECT 1 AS one FROM "wiki_pages" WHERE "wiki_pages"."title" IS NULL AND "wiki_pages"."wiki_id" = $1 LIMIT $2
SELECT 1 AS one FROM "watchers" WHERE "watchers"."user_id" = $1 AND "watchers"."watchable_type" = $2 AND "watchers"."watchable_id" IS NULL LIMIT $3
SELECT "wikis".* FROM "wikis" WHERE "wikis"."project_id" IS NULL LIMIT $1
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."status" = $1 AND (members.project_id = 1) AND "users"."status" = $2 AND "users"."status" = $3 AND "users"."type" IN ($4, $5) ORDER BY users.type DESC, users.firstname, users.lastname, users.id
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (LOWER(email_addresses.address) IN ('testuser@example.org'))
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 5)
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('dlopper@somenet.foo')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."status" = $1 AND (members.project_id = 1) AND "users"."status" = $2 AND "users"."status" = $3 AND "users"."type" IN ($4, $5) LIMIT $6
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 4)
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."status" = $1 AND (members.project_id = 1) AND "users"."status" = $2 AND "users"."status" = $3 AND "users"."type" IN ($4, $5)
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('foo@bar.net')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 3)
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 1)
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (LOWER(email_addresses.address) IN ('r@mycompanyname.com'))
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 2)
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('jdoe@example.net')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."status" = $1 AND (members.project_id = 1) AND "users"."status" = $2 AND "users"."type" IN ($3, $4) LIMIT $5
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('jsmith@somenet.foo')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (LOWER(email_addresses.address) IN ('redmine@somenet.foo','dlopper@somenet.foo'))
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (LOWER(email_addresses.address) IN ('redmine@somenet.foo'))
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('john.doe@somenet.foo')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('foo@example.org')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('invalid@somenet.foo')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('anotheraddress@foo.bar')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 50) ORDER BY users.firstname, users.lastname, users.id
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 6)
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 8) ORDER BY users.firstname, users.lastname, users.id
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 2) ORDER BY users.firstname, users.lastname, users.id
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('foo@example.com')) ORDER BY "users"."id" ASC LIMIT $3
SELECT DISTINCT "users".* FROM "users" INNER JOIN "members" ON "members"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND (members.project_id = 1) ORDER BY users.firstname, users.lastname, users.id
SELECT DISTINCT "users".* FROM "users" INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id" WHERE "users"."type" IN ($1, $2) AND (LOWER(email_addresses.address) IN ('newuser@foo.bar')) ORDER BY "users"."id" ASC LIMIT $3
SELECT "issue_relations".* FROM "issue_relations" WHERE "issue_relations"."issue_from_id" = $1 AND "issue_relations"."issue_to_id" = $2 AND "issue_relations"."relation_type" = $3 AND "issue_relations"."delay" = $4
SELECT "email_addresses".* FROM "email_addresses" WHERE "email_addresses"."address" = $1
SELECT "users".* FROM "users" WHERE "users"."type" IN ($1, $2) AND "users"."login" = $3
SELECT "issue_relations".* FROM "issue_relations" WHERE "issue_relations"."issue_from_id" = $1 AND "issue_relations"."issue_to_id" = $2
SELECT "users".* FROM "users" WHERE "users"."type" IN ($1, $2) AND "users"."status" = $3 AND "users"."login" = $4
SELECT "issue_relations".* FROM "issue_relations" WHERE "issue_relations"."issue_from_id" = $1 AND "issue_relations"."issue_to_id" = $2 AND "issue_relations"."relation_type" IN ($3, $4)
SELECT "issue_relations".* FROM "issue_relations" WHERE "issue_relations"."issue_from_id" = $1 AND "issue_relations"."issue_to_id" = $2 AND "issue_relations"."delay" = $3 AND "issue_relations"."relation_type" = $4
SELECT "issue_statuses".* FROM "issue_statuses" WHERE (default_done_ratio >= 0)
