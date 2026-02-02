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
        ./hosts/nixos-laptop/hardware-configuration.nix
        ./hosts/nixos-laptop/configuration.nix
        ./modules/nixos
        home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.nixos-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit self home-manager inputs;
        variables = import ./variables.nix;
      };
      modules = [
        ./hosts/nixos-desktop/hardware-configuration.nix
        ./hosts/nixos-desktop/configuration.nix
        ./modules/nixos
        home-manager.nixosModules.home-manager
      ];
    };

    # Per-host displayScale overrides:
    # nixos-laptop: variables = (import ./variables.nix) // { displayScale = 1.5; };
    # nixos-desktop: variables = (import ./variables.nix) // { displayScale = 1; };

    nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit self home-manager inputs;
        variables = (import ./variables.nix) // {
          bootDevice = "/dev/vda";
          isBIOS = true;
          displayScale = 1;
        };
      };
      modules = [
        ./hosts/nixos-vm/hardware-configuration.nix
        ./hosts/nixos-vm/configuration.nix
        ./modules/nixos
        home-manager.nixosModules.home-manager
      ];
    };

    homeManagerModules.default = ./modules/home-manager;
  };
}
