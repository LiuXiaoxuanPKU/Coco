APPS=('openstreetmap' 'forem' 'mastodon'\
        'openproject' 'redmine' 'spree')
for APP in "${APPS[@]}"
do
  constropt-rewriter "data" "$APP" --cnt 100000 --include-eq --only-rewrite
done

python plots/plot_rewrite_threshold.py