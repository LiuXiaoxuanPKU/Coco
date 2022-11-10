{
  description = "ConstrOpt rewriter";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [poetry2nix.overlay];
      };
      package-def = with pkgs; {
        projectDir = ./.;
        python = python310;
        preferWheels = true;
        overrides = pkgs.poetry2nix.overrides.withDefaults (_: prev: {
          mo-future = prev.mo-future.overrideAttrs (_: old: {
            propagatedBuildInputs = old.propagatedBuildInputs ++ [prev.setuptools];
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
      constropt-rewriter = pkgs.poetry2nix.mkPoetryApplication package-def;
      constropt-rewriter-env = pkgs.poetry2nix.mkPoetryEnv package-def;
    in {
      defaultPackage = constropt-rewriter;
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [constropt-rewriter-env poetry postgresql openssl];
      };
    });
}
