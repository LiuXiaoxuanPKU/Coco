APPS=('openstreetmap' 'forem' 'mastodon'\
        'openproject' 'redmine' 'spree')
for APP in "${APPS[@]}"
do
  constropt-extractor --dir data/app_source_code/ --app "$APP" --for_rewrite
  mkdir -p data/results/
  python rewriter/src/bench_str2int_num.py --app "$APP"
done