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
    disko = {
      url = "github:nix-community/disko";
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

  outputs = { self, nixpkgs, home-manager, disko, ... }@inputs:
    let
      mkSystem = {
        hostname,
        system ? "x86_64-linux",
        extraVars ? {},
        extraModules ? [],
        withDisko ? true,
        withHardwareConfig ? true
      }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs;
            variables = (import ./variables.nix) // extraVars;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules =
            nixpkgs.lib.optionals withDisko [ disko.nixosModules.disko ]
            ++ nixpkgs.lib.optionals withHardwareConfig [ ./hosts/${hostname}/hardware-configuration.nix ]
            ++ [
              ./hosts/${hostname}/configuration.nix
              ./modules/nixos
              home-manager.nixosModules.home-manager
            ]
            ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        nixos-laptop = mkSystem { hostname = "nixos-laptop"; };

        nixos-desktop = mkSystem { hostname = "nixos-desktop"; };

        nixos-rugged = mkSystem {
          hostname = "nixos-rugged";
          extraVars = { displayScale = 1; };
        };

        # Per-host displayScale overrides:
        # nixos-laptop: extraVars = { displayScale = 1.5; };
        # nixos-desktop: extraVars = { displayScale = 1; };

        nixos-vm = mkSystem {
          hostname = "nixos-vm";
          extraVars = { bootDevice = "/dev/vda"; isBIOS = true; displayScale = 1; };
        };

        nixos-wsl = mkSystem {
          hostname = "nixos-wsl";
          withDisko = false;
          withHardwareConfig = false;
          extraModules = [ inputs.nixos-wsl.nixosModules.default ];
        };
      };

      homeManagerModules.default = ./modules/home-manager;
    };
}
