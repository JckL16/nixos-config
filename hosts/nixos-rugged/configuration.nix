# hosts/nixos-rugged/configuration.nix
#

{ config, pkgs, pkgs-unstable, home-manager, inputs, variables, ... }: {

  imports = [
    home-manager.nixosModules.home-manager
  ];

  networking.hostName = "nixos-rugged";

  grub.nordic-theme.enable = true;

  hyprland.enable = true;

  greetd.enable = true;

  nvidia-graphics.enable = true;

  steam.enable = true;
  gamemode.enable = true;

  virtualisation.enable = true;   # libvirt/QEMU KVM
  docker.enable = true;

  metasploit-db.enable = true;    # PostgreSQL database for Metasploit

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs variables pkgs-unstable;
    };
    users."${variables.username}" = {
      imports = [
        ./home.nix
        inputs.self.outputs.homeManagerModules.default
      ];
    };
  };

}
