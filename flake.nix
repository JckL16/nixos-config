# flake.nix

{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }@inputs: {
    nixosConfigurations.nixos-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit self home-manager inputs;
        variables = import ./variables.nix;
      };
      modules = [
        ./hosts/nixos-laptop/configuration.nix
        ./modules/nixos
        home-manager.nixosModules.home-manager
      ];
    };

    homeManagerModules.default = ./modules/home-manager;
  };
}