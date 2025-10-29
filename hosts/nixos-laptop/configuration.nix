# hosts/nixos-laptop/configuration.nix

{ config, pkgs, home-manager, inputs, variables, ... }: {
  
  imports = [
    ./samsung-laptop.nix
    home-manager.nixosModules.home-manager
  ];

  # Bootloader
  systemd-boot.enable = false;
  grub.enable = true;
  grub.nordic-theme.enable = true;

  # Set to newest kernel to get the samsung-galaxy kernel working
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.systemd.enable = true;  # Use systemd in initrd for better compatibility
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-19" "-T0" ];

  # Hostname
  networking.hostName = "nixos-laptop";

  # Desktop environment
  hyprland.enable = true;

  # Graphics drivers
  intel-graphics.enable = true;
  steam.enable = true;
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
