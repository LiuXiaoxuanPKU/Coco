APPS=('openstreetmap' 'diaspora' 'discourse' 'forem'\
        'gitlab' 'lobsters' 'loomio' 'mastodon'\
        'onebody' 'openproject' 'redmine' 'rorecommerce'\
        'spree' 'tracks')
for APP in "${APPS[@]}"
do
  echo "=================${APP}=========================="
  constropt-extractor --dir data/app_source_code/ --app "$APP"
done
mkdir data/figures
python plots/plot_constraint_num.py
python plots/plot_constraint_dis.py