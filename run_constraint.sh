APPS=('diaspora' 'discourse' 'forem'\
        'gitlab' 'lobsters' 'loomio' 'mastodon'\
        'onebody' 'openproject' 'redmine' 'rorecommerce'\
        'spree' 'tracks')
for APP in "${APPS[@]}"
do
  ruby extractor/main.rb --dir data/app_source_code/ --app "$APP"
done
python plots/plot_constraint_num.py
python plots/plot_constraint_dis.py