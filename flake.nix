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
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            docker
            nixd
            alejandra
          ];
        };
      }
    );
}
