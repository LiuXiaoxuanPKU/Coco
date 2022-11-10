{
  description = "ConstrOpt optimizer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    constropt-extractor.url = "path:./extractor";
    constropt-rewriter.url = "path:./rewriter";
    cosette-parser.url = "git+file:./cosette-parser";
    cosette-prover.url = "git+file:./cosette-prover";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    constropt-extractor,
    constropt-rewriter,
    cosette-parser,
    cosette-prover,
  }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
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
