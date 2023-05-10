# Coco Overview
This is the official repository for [Leveraging Applicaton Data Constraints to Optimize Database-Backed Web Applications](https://arxiv.org/abs/2205.02954) by Xiaoxuan Liu, Shuxian Wang, Mengzhu Sun, Sicheng Pan, Ge Li, Siddharth Jha, Cong Yan, Junwen Yang, and Alvin Chueng. 
Here we present `Coco`, the first tool that identifies data relationships by analyzing the programs that generate and maintain the persist data. Once identified,`Coco` leverages the found constraints to optimize the application's physical design and query execution by rewriting queries. Instead of developing a fixed set of predefined rewriting rules, `Coco` employs an enumerate-test-verify technique to automatically exploit the discovered data constraints to improve query execution. 

# Install and Run
requirements: we need a linux system to run `Coco`
1. Install nix, the package manager
```
sh <(curl -L https://nixos.org/nix/install) --daemon
```
And enable the Nix flake feature which we rely on
```
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```
2. Run the end-to-end pipeline
```
nix run . -- <DATA> <APP>
```
DATA is the data directory that includes application source code (data/app_source_code), sqls that define app scheme (data/app_create_sql/), and app queries (data/queries/) to be optimized. In the repo, the DATA should be set to `./data`.
APP is the application name, which can be set to `redmine`, `forem`, `mastodon`, `openproject`, `openstreetmap`, `spree`.

<!-- If should see benchmark results as follows under data directory after running `bash run.sh data redmine`:
![Readme perf](imgs/ "Redmine rewrite performance") -->

# Code structure
| folder | description|
| ----------- | ----------- |
| extractor | Constraint Extraction. |
| rewriter | Rewrite queries based on input constraints. Rewriting queries is performed in the following steps: enumerate rewrites with rules, estimate cost, run tests to filter out incorrect rewrites, collect the queries that pass the test and prepare into inputs for prover, and formally verify the equivalence of query pairs.|
| data | Input and output data.| 
