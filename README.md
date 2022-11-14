# ConstrOpt Overview
This is the official repository for [Leveraging Applicaton Data Constraints to Optimize Database-Backed Web Applications](https://arxiv.org/abs/2205.02954) by Xiaoxuan Liu, Shuxian Wang, Mengzhu Sun, Sicheng Pan, Ge Li, Siddharth Jha, Cong Yan, Junwen Yang, and Alvin Chueng. 
Here we present `ConstrOpt`, the first tool that identifies data relationships by analyzing the programs that generate and maintain the persist data. Once identified,`ConstrOpt` leverages the found constraints to optimize the application's physical design and query execution by rewriting queries. Instead of developing a fixed set of predefined rewriting rules, `ConstrOpt` employs an enumerate-test-verify technique to automatically exploit the discovered data constraints to improve query execution. 

# Install and Run
requirements: make sure you have conda and postgres set up
Run
```
bash run.sh
```
under the project root directory. You should see performance figures under `data/figures` directory.

# Code structure
| folder | description|
| ----------- | ----------- |
| extractor | Constraint Extraction |
| rewriter | Rewrite queries based on input constraints. Rewriting queries is performed in three steps: enumerate rewrites with rules, estimate cost, and run tests to filter out incorrect rewrites. The output is a file that records the original query and its rewrites. |
| cosette-parser | parse the original and rewritten pairs, generate input for cosette-solver |
| cosette-prover | formally verify the equivalence of query pairs |