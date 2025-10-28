# hosts/nixos-desktop/configuration.nix

{ config, pkgs, home-manager, inputs, variables, ... }: {
  
  imports = [
    ./amd-desktop.nix
    home-manager.nixosModules.home-manager
  ];

  # Bootloader
  systemd-boot.enable = false;
  grub.enable = true;
  grub.nordic-theme.enable = true;

  # Hostname
  networking.hostName = "nixos-desktop";

  # Desktop environment
  hyprland.enable = true;

  # Graphics drivers
  amd-graphics.enable = true;
  gamemode.enable = true;

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { 
      inherit inputs variables;
    };
    users."${variables.username}" = {
      imports = [
        ./home.nix
        inputs.self.outputs.homeManagerModules.default
      ];
    };
  };

}