SELECT distinct(name) from users where name = $1
SELECT distinct(name) from users where name = $1 and age=15 and gender=$2