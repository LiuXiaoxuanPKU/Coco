This folder includes code for constraint extraction.
To extract constraints, under the project root folder(not the extractor folder), run:
```
ruby main.rb [options]
        --dir DATADIR
        --app APPNAME
```
DATADIR should be the parent folder of the folder that contains the app source code.
In the repo, the folder is `/data`.
The output is a json file that records all extracted constraints.

ConstrOpt reads all the application source code, and builds an AST for each model file. Each model in Rails (which has a corresponding table in the database) is defined as a node. The dependencies between nodels represent the class relationships (e.g., foreign key, class inheritance). Therefore, ConstrOpt will build a graph with each node representing each model, and edges representing class relationships. The `traversor ` will visit each model (node) and extract constraints accordingly.
| file | description|
| ----------- | ----------- |
| builtin_extractor.rb | Extract Builtin Validation |
| class_inheritance_extractor.rb | Extract Class Inheritance |
| state_machine_extractor.rb | Extract State Machine |
| hasone_belongto_extractor.rb | Extract has_one/belong_to relationship |
| db_extractor | Extract Database constraints |
| traversor.rb | Traversor used to visit different models |
| constraint.rb | Class definition for different types of constraints |