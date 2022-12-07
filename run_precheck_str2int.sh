APPS=('openstreetmap' 'forem' 'mastodon'\
        'openproject' 'redmine' 'spree')
for APP in "${APPS[@]}"
do
  ruby extractor/main.rb --dir data/app_source_code/ --app "$APP"
  python rewriter/src/bench_str2int_num.py --app "$APP"
done