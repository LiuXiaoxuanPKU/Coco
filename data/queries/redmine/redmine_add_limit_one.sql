SELECT issue_relations.* FROM issue_relations WHERE issue_relations.issue_from_id = $1 AND issue_relations.issue_to_id = $2 AND issue_relations.relation_type = $3 AND issue_relations.delay = $4
SELECT email_addresses.* FROM email_addresses WHERE email_addresses.address = $1
SELECT roles.* FROM roles WHERE  ("name" = $1)
SELECT issue_relations.* FROM issue_relations WHERE issue_relations.issue_from_id = $1 AND issue_relations.issue_to_id = $2 AND issue_relations.relation_type IN ($3, $4)
SELECT issue_relations.* FROM issue_relations WHERE issue_relations.issue_from_id = $1 AND issue_relations.issue_to_id = $2 AND issue_relations.delay = $3 AND issue_relations.relation_type = $4
