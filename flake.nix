{
  description = "Install dependencies to build and run the docker image";
  inputs = {
    nixpkgs = {
      # Nixpkgs 25.05
      url = "github:NixOS/nixpkgs/5b5be50345d4113d04ba58c444348849f5585b4a";
    };
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
          packages = with pkgs; [
            typst # To build the report
            pdf2svg
            git-annex # To pull the old dataset
            python313Full #For deepmriprep and plot scripts
            tk # For deepmriprep-gui

            /*
            pkg-config.out
            cairo.dev # For niftiview
            */

            docker # For SLANT and MaCRUISE

            # Optional linters
            nixd
            ruff
            alejandra
          ];
        };
      }
    );
}
