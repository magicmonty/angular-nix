{
  description = "Angular Language Server as flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    pre-commit-hooks,
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {
        system,
        self',
        ...
      }: let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs_20;

        angularls = pkgs.callPackage ./angular-language-server {inherit nodejs;};
      in {
        packages.angularls = angularls;

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              statix.enable = true;
              alejandra.enable = true;
            };
          };
        };

        formatter = pkgs.alejandra;

        packages.default = angularls;

        devShells = {
          default = with pkgs;
            mkShell {
              inherit (self'.checks.pre-commit-check) shellHook;
              buildInputs = with pkgs; [nodejs_20 yarn angularls];
            };
        };
      };
    };
}
