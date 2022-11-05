# install rvm
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
curl -sSL https://get.rvm.io | bash -s stable --rails

# create rvm environment
rvm use 3.0.0@constropt --create
cd extractor
bundle install
cd ..

# extract constraints
ruby extractor/main.rb --dir data/ --app redmine