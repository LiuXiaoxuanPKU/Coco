{
  description = "ConstrOpt extractor";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gems = pkgs.bundlerEnv {
          name = "constropt-extractor-env";
          ruby = pkgs.ruby_3_0;
          gemdir = ./.;
        };
        constropt-extractor = pkgs.stdenv.mkDerivation {
          name = "constropt-extractor";
          src = ./.;
          buildInputs = [ gems.wrappedRuby ];
          installPhase = ''
          mkdir -p $out/bin
          cp *.rb $out/bin/
          mv $out/bin/main.rb $out/bin/constropt-extractor
          patchShebangs $out/bin/constropt-extractor
          '';
        };
      in {
        defaultPackage = constropt-extractor;
        devShell = pkgs.mkShell {
          inputsFrom = [ constropt-extractor ];
        };
      }
    );
}
