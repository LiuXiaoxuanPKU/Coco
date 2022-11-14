ConstrOpt employs an enumerate-test-verify technique to automatically exploit the discovered data constraints to improve query execution. This folder includes the logic of enumeration and testing, the output is a json file that records all the rewrites of a given query.

```
python pipeline.py [-h] [--app APP] [--db] [--only_rewrite] [--cnt CNT] [--include_eq] [--data_dir DATA_DIR]
```

| file | description|
| ----------- | ----------- |
| config.py | Config input/output path, this file needs to be set correctly to make the program run |
| pipeline.py | The pipeline to read constraints, enumerate rewrite, estimate cost, run tests, and dump results |
| constraint.py | Class definition for different types of constraints |
| rule.py | Different rewrite rules |
| loader.py | Helper functions to load input |
| test_verifier.py | Run tests to check the correctness of rewrites |