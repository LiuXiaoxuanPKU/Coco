{
  description = "ConstrOpt optimizer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    get-flake.url = "github:ursi/get-flake";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    get-flake,
  }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      constropt-extractor = get-flake ./extractor;
      constropt-rewriter = get-flake ./rewriter;
      constropt-components = pkgs.symlinkJoin {
        name = "constropt-components";
        paths = [
          constropt-extractor.packages.${system}.default
          constropt-rewriter.packages.${system}.default
        ];
      };
      constropt-run = (pkgs.writeScriptBin "constropt-run" (builtins.readFile ./run.sh)).overrideAttrs(old: rec {
        buildInputs = with pkgs; [ constropt-components postgresql internetarchive ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildCommand = ''
          ${old.buildCommand}
          patchShebangs $out
          wrapProgram $out/bin/constropt-run --prefix-each PATH : "${pkgs.lib.makeBinPath buildInputs}"
        '';
      });
    in rec {
      packages.default = constropt-run;
      devShells.default = pkgs.mkShell {
        inputsFrom = [ constropt-run ];
      };
	  devShell = devShells.default;
    });

  nixConfig = {
    extra-substituters = [ "https://constropt.cachix.org" ];
    extra-trusted-public-keys = [ "constropt.cachix.org-1:4dQuJoRIUutgZkYIOLS81Tj5LxteQcBUrySfZCt2CTA=" ];
  };
}
