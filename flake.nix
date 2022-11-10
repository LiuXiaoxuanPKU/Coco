{
  description = "ConstrOpt optimizer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    get-flake.url = "github:ursi/get-flake";
    cosette-parser.url = "github:cosette-solver/cosette-parser/experimental";
    cosette-prover.url = "github:cosette-solver/cosette-prover";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    get-flake,
    cosette-parser,
    cosette-prover,
  }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      constropt-extractor = get-flake ./extractor;
      constropt-rewriter = get-flake ./rewriter;
    in {
      devShell = pkgs.mkShell {
        buildInputs = [
          constropt-extractor.defaultPackage.${system}
          constropt-rewriter.defaultPackage.${system}
          cosette-parser.defaultPackage.${system}
          cosette-prover.defaultPackage.${system}
        ];
      };
    }
  );
}
