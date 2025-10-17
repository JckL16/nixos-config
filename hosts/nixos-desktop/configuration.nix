# hosts/nixos-laptop/configuration.nix

{ config, pkgs, home-manager, inputs, variables, ... }: {
  
  imports = [
    ./amd-desktop.nix
    home-manager.nixosModules.home-manager
  ];

  # Hostname
  networking.hostName = "nixos-desktop";

  # Desktop environment
  sway.enable = true;

  # Graphics drivers
  # intel-graphics.enable = true;
  amd-graphics.enable = true;
  steam.enable = true;

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { 
      inherit inputs variables;
      sway.enable = config.sway.enable;
    };
    users."${variables.username}" = {
      imports = [
        ./home.nix
        inputs.self.outputs.homeManagerModules.default
      ];
    };
  };

}