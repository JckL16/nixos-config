# flake.nix

{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit self home-manager inputs;
        variables = import ./variables.nix;
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
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
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./hosts/nixos-desktop/hardware-configuration.nix
        ./hosts/nixos-desktop/configuration.nix
        ./modules/nixos
        home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.nixos-rugged = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit self home-manager inputs;
        variables = (import ./variables.nix) // { displayScale = 1; };
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./hosts/nixos-rugged/hardware-configuration.nix
        ./hosts/nixos-rugged/configuration.nix
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
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./hosts/nixos-vm/hardware-configuration.nix
        ./hosts/nixos-vm/configuration.nix
        ./modules/nixos
        home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.nixos-wsl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit self home-manager inputs;
        variables = import ./variables.nix;
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        inputs.nixos-wsl.nixosModules.default
        ./hosts/nixos-wsl/configuration.nix
        ./modules/nixos
        home-manager.nixosModules.home-manager
      ];
    };

    homeManagerModules.default = ./modules/home-manager;
  };
}
