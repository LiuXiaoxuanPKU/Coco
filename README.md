# `ConstrOpt`
This is the official repository for [Leveraging Applicaton Data Constraints to Optimize Database-Backed Web Applications](https://arxiv.org/abs/2205.02954) by Xiaoxuan Liu, Shuxian Wang, Mengzhu Sun, Sharon Lee, Sicheng Pan, Joshua Wu, Cong Yan, Junwen Yang, and Alvin Chueng. 
Here we present `ConstrOpt`, the first tool that identifies data relationships by analyzing the programs that generate and maintain the persist data. Once identified,`ConstrOpt` leverages the found constraints to optimize the application's physical design and query execution by rewriting queries. Instead of developing a fixed set of predefined rewriting rules, `ConstrOpt` employs an enumerate-test-verify technique to automatically exploit the discovered data constraints to improve query execution. 
![experiment image](https://github.com/LiuXiaoxuanPKU/ConstrOpt/blob/main/figures/7.2/redmine.pdf)

## Run Experiment
All experiments we did in the paper are under `/autrite` directory. For re-run experiements on redmine, openprojects, and forem, run the following under the root directory. `/autrite/benchmark` directory contains util functions for experiment evaluation. 
```
python3 autrite/pipeline.py --app <appname>
python3 autrite/pipline.py --app redmine  # example
```
The following is the version information we use for apps in our experiments.
| Application | Ruby Version | Release Version/Tag                             |
|-------------|--------------|-------------------------------------------------|
| ConstrOpt   | 3.0.1        | NA                                              |
| Redmine     | 3.0.0        | commit cfba76019b31e22e2de4b1a8b99b201fc31ada29 |
| Dev.to      | 2.7.2        | commit cfba76019b31e22e2de4b1a8b99b201fc31ada29 |
| Openproject | 2.7.4        | commit cfba76019b31e22e2de4b1a8b99b201fc31ada29 |

## Constraint Extractor
### Install third party libraries
under constr_extractor folder, run
``` 
bundler insatll
```
### Run tests
For running constrains extraction tests, run `rspec spec/extractor_spec.rb` under constr_extractor folder. All code sections take care of constraints extraction is under `/constropt/constr_extractor/` directory. 

## Query Rewriter
ConstrOpt employs an enumerate-test-verify technique to automatically exploit the discovered data constraints to improve query execution. Each resulting rewrite is provably equivalent semantically to the original query. 
### How to run Rewriter tests
Under root directory, run
```
python3 tests/tests.py # run all tests
```