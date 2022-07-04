# ConstrOpt
ConstrOpt is a library that leverages application data constraints to optimize database-backed web applications. You can find the related paper [here](https://arxiv.org/abs/2205.02954).

## Run Experiment
All experiments we did in the paper are under `/autrite` directory. For re-run experiements on redmine, openprojects, and forem, run `python3 autrite/pipeline.py` in the root directory. 

## Constraint Extractor
### Install third party libraries
under constr_extractor folder, run
``` 
bundler insatll
```
### Run tests
For running constrains extraction tests, run `rspec spec/extractor_spec.rb` under constr_extractor folder. All code sections take care of constraints extraction is under `/constropt/constr_extractor/` directory. 

## Query Rewriter
### Run tests
under root directory, run
````
PYTHONPATH="./" python tests/test_rewrite.py # run all tests
PYTHONPATH="./" python tests/test_rewrite.py TestRewrite.test_fn_name # run a single test with name test_fn_name
````