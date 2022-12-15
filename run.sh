#!/usr/bin/env bash
# $data_dir: Source folder $2: Application name

export COSETTE_SMT_TIMEOUT=100000
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
    echo Initializing database folder...
    initdb -U "$PGUSER" --auth=trust --no-locale --encoding=UTF8
  fi
  if ! pg_ctl status; then
    echo Starting local PostgreSQL database...
    pg_ctl start -l "$PGHOST/postgres.log" -o "--unix_socket_directories='$PGHOST' --listen_addresses=''"
  fi

  # Trap to stop database
  trap "{ pg_ctl stop; exit; }" SIGINT SIGTERM EXIT

  mkdir -p "$data_dir/dump"
  if [[ ! -f "$data_dir/dump/$2.dump" ]]; then
    echo Downloading dataset...
    ia download "constropt-$2-dump" "$2.dump" --no-directories --destdir="$data_dir/dump"
  fi
  echo Restoring database...
  pg_restore -d $PGDATABASE -C -j 16 -x -O -c "$data_dir/dump/$2.dump"

  echo Extracting constraints...
  constropt-extractor --dir "$data_dir/app_source_code/" --app "$2" --for_rewrite

  rm -rf "$data_dir/rewrites/$2" && mkdir "$data_dir/rewrites/$2"
  echo Rewrting queries...
  constropt-rewriter "$data_dir" "$2" --cnt 100000 --include-eq

  echo Running benchmarks...
  constropt-benchmark "$data_dir" "$2" --include-eq

  echo Generating plots...
  python plots/plot_rewrite_perf.py --data_dir "$data_dir" --app "$2" > "out_$2"
else
  echo "Please provide the data directory and application name."
fi
