# install rvm
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
curl -sSL https://get.rvm.io | bash -s stable --rails

# create rvm environment
rvm use 3.0.0@constropt --create
cd extractor
bundle install
cd ..

# # run constraint extractor tests, you should not see any errors
# bash extractor/run_test.sh

# extract constraints
ruby extractor/main.rb --dir data/app_source_code/ --app redmine

# create conda environment
conda create -n rewriter python=3.10
conda activate rewriter
pip install -r rewriter/requirements.txt 

# # run query rewriter tests, you should not see any errors
# cd rewriter/test
# pytest
# cd ../.. # go back to project root

# rewrite queries
python rewriter/src/pipeline.py --app redmine --cnt 1000 --include_eq --data_dir data

python benchmark/bench_rewrite_perf.py --app redmine --data_dir data

python benchmark/plot_rewrite_perf.py --app redmine --data_dir data