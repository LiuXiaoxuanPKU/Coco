#!/usr/bin/env bash
# $data_dir: Source folder $2: Application name

if [[ $# -eq 2 ]]; then
  # Expand data directory path
  data_dir="$(realpath $1)"

  # Initialize database if necessary
  export PGHOST="$data_dir/postgres"
  export PGDATA="$PGHOST/data"
  export PGDATABASE="postgres"
  export PGUSER="postgres"

  mkdir -p "$PGHOST"
  if [[ ! -d "$PGDATA" ]]; then
    initdb -U "$PGUSER" --auth=trust --no-locale --encoding=UTF8
  fi
  if ! pg_ctl status; then
    pg_ctl start -l "$PGHOST/postgres.log" -o "--unix_socket_directories='$PGHOST' --listen_addresses=''"
  fi

  # Trap to stop database
  trap "{ pg_ctl stop; exit; }" SIGINT SIGTERM EXIT

  mkdir -p "$data_dir/dump"
  if [[ ! -f "$data_dir/dump/$2.dump" ]]; then
    ia download "constropt-$2-dump" "$2.dump" --no-directories --destdir="$data_dir/dump"
  fi
  pg_restore -d $PGDATABASE -C -j 16 -x -O -c "$data_dir/dump/$2.dump"

  # extract constraints
  # constropt-extractor --dir "$data_dir/app_source_code/" --app "$2"

<<<<<<< HEAD

# 1. string to int optimization
python rewriter/src/str2int_pipeline.py --app redmine --cnt 1000 --data_dir data

# 2. query rewrite optimization
python rewriter/src/rewrite_pipeline.py --app redmine --cnt 1000 --include_eq --data_dir data
=======
  # rewrite queries
  constropt-rewriter "$data_dir" "$2" --cnt 10000 --include-eq 
>>>>>>> 07758ae59f299a56f8017e3dc352cd50ae36624f

  # Run benchmark
  constropt-benchmark "$data_dir" "$2" --include-eq
else
  echo "Please provide the data directory and application name."
fi
