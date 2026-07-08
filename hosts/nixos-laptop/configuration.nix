# hosts/nixos-laptop/configuration.nix

{ config, pkgs, pkgs-unstable, inputs, variables, ... }: {

  # Disko disk configuration (enable only during fresh install)
  diskoConfig = {
    enable = true;
    device = "/dev/nvme0n1";
    encryption.enable = true;
    swapSize = "16G";
  };

  # Set the Bootloader theme (grub is enabled by default)
  grub.nordic-theme.enable = true;

  # Ryzen 3000 APU quirks
  boot.kernelParams = [ "idle=nomwait" "iommu=soft" ];

  # Hostname
  networking.hostName = "nixos-laptop";

  # Desktop environment
  hyprland.enable = true;

  # Enabling virtualisation for the system
  virtualisation.enable = true;
  docker.enable = true;

  # Graphics drivers
  amd-graphics.enable = true;
  steam.enable = true;
  gamemode.enable = true;

  # Metasploit database (used with cyber.enable)
  metasploit-db.enable = true;

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs variables pkgs-unstable;
    };
    users."${variables.username}" = {
      imports = [
        ./home.nix
        inputs.self.outputs.homeModules.default
      ];
    };
  };

}
