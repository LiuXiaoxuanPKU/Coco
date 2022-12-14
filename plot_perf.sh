APPS=('openstreetmap' 'forem' 'mastodon'\
        'redmine' 'spree')
for APP in "${APPS[@]}"
do
  python plots/plot_rewrite_perf.py --app "$APP"  --data_dir data > "out_$APP"
done