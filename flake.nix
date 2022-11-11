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
    in rec {
      packages.default = pkgs.symlinkJoin {
        name = "constropt";
        paths = [
          constropt-extractor.packages.${system}.default
          constropt-rewriter.packages.${system}.default
          cosette-parser.packages.${system}.default
          cosette-prover.packages.${system}.default
        ];
      };
      devShells.default = pkgs.mkShell {
        buildInputs = [ packages.default ];
      };
    });

  nixConfig = {
    extra-substituters = [ "https://constropt.cachix.org" ];
    extra-trusted-public-keys = [ "constropt.cachix.org-1:Dy9RIrswrIpwotaY72stGFWdrDPkfldvttgwdt0y+E8=" ];
  };
}
