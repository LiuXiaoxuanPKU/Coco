SELECT distinct(name) from users where name = $1 
SELECT distinct(name) from users where name = 'lily' LIMIT 1
SELECT distinct(name) from users where name = $1 and age=15 and gender=$2
SELECT distinct(name) from users where name = $1 or age=15 and gender=$2
SELECT * from users INNER JOIN projects where projects.id = users.project_id and projects.id = 1
SELECT * from users INNER JOIN projects INNER JOIN members where projects.id = users.project_id and (projects.id = 1 or members.id > 1)