{
  description = "ConstrOpt rewriter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosette-parser.url = "github:cosette-solver/cosette-parser/experimental";
    cosette-prover.url = "github:cosette-solver/cosette-prover";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, cosette-parser, cosette-prover }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [poetry2nix.overlay];
      };
      package-def = with pkgs; {
        projectDir = ./.;
        python = python310;
        overrides = pkgs.poetry2nix.overrides.withDefaults (_: prev: {
          mo-future = prev.mo-future.overrideAttrs (_: old: {
            propagatedBuildInputs = old.propagatedBuildInputs ++ [ prev.setuptools ];
          });
          clize = prev.clize.overrideAttrs (_: old: {
            propagatedBuildInputs = old.propagatedBuildInputs ++ [ prev.setuptools prev.setuptools-scm prev.wheel ];
          });
          z3-solver = prev.z3-solver.overridePythonAttrs (old: {
            dontUseCmakeConfigure = true;
            nativeBuildInputs = [ pkgs.cmake ] ++ old.nativeBuildInputs;
            propagatedBuildInputs = old.propagatedBuildInputs ++ [ prev.setuptools ];
            preConfigure = ''
            substituteInPlace setup.py --replace "'Z3_LINK_TIME_OPTIMIZATION' : True" "'Z3_LINK_TIME_OPTIMIZATION' : False"
            '';
          });
        });
      };
      constropt-rewriter-env = pkgs.poetry2nix.mkPoetryEnv package-def;
      constropt-rewriter = pkgs.poetry2nix.mkPoetryApplication (package-def // {
        propagatedBuildInputs = [
          cosette-parser.packages.${system}.default
          cosette-prover.packages.${system}.default
        ];
      });
    in {
      packages.default = constropt-rewriter;
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          constropt-rewriter-env poetry postgresql openssl
          cosette-parser.packages.${system}.default
          cosette-prover.packages.${system}.default
        ];
      };
    });
}
