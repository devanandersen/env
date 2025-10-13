{
  description = "Dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }:
    let
      mkDarwinConfig = username: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./home.nix
          agenix.homeManagerModules.default
          { home.username = username; }
        ];
      };
    in {
      homeConfigurations = {
        "devan" = mkDarwinConfig "devan";
        "devanandersen" = mkDarwinConfig "devanandersen";
        "devanandersen@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home.nix
            agenix.homeManagerModules.default
            { home.username = "devanandersen"; }
          ];
        };
      };
    };
}