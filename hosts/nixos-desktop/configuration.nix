# hosts/nixos-desktop/configuration.nix

{ config, pkgs, home-manager, inputs, variables, ... }: {
  
  imports = [
    ./amd-desktop.nix
    home-manager.nixosModules.home-manager
  ];

  # Set the bootloader theme (grub is enabled by default)
  grub.nordic-theme.enable = true;

  # Hostname
  networking.hostName = "nixos-desktop";

  # Desktop environment
  hyprland.enable = true;

  # Graphics drivers
  amd-graphics.enable = true;

  # Gaming
  steam.enable = true;
  gamemode.enable = true;
  # Makes sure gamemode can se the GPU on my desktop
  programs.gamemode.settings.gpu.gpu_device = 1;

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
