# [ConstrOpt]
This is the official repository for [Leveraging Applicaton Data Constraints to Optimize Database-Backed Web Applications](https://arxiv.org/abs/2205.02954) by Xiaoxuan Liu, Shuxian Wang, Mengzhu Sun, Sharon Lee, Sicheng Pan, Joshua Wu, Cong Yan, Junwen Yang, and Alvin Chueng. 
Here we present [ConstrOpt], the first tool that identifies data relationships by analyzing the programs that generate and maintain the persist data. Once identified,[ConstrOpt] leverages the found constraints to optimize the application's physical design and query execution by rewriting queries. Instead of developing a fixed set of predefined rewriting rules, [ConstrOpt] employs an enumerate-test-verify technique to automatically exploit the discovered data constraints to improve query execution. 

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