# hosts/nixos-desktop/configuration.nix

{ config, pkgs, home-manager, inputs, variables, ... }: {
  
  imports = [
    home-manager.nixosModules.home-manager
  ];

  # Enable emulation of ARM systems
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  # Metasploit database (used with cyber.enable)
  metasploit-db.enable = true;

  winbox.enable = true;

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
