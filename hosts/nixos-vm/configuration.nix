# hosts/nixos-vm/configuration.nix

{ config, pkgs, pkgs-unstable, home-manager, inputs, variables, ... }: {
  
  imports = [
    home-manager.nixosModules.home-manager
  ];

  # Disabled as they dont work in a VM
  audio.enable = false;
  bluetooth.enable = false;

  # Hostname
  networking.hostName = "nixos-vm";

  # Desktop environment
  # gnome.enable = true;
  hyprland.enable = true;

  # Guest-agent for the vm
  qemu-guest-agent.enable = true;

  intel-graphics.enable = true;

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
        inputs.self.outputs.homeManagerModules.default
      ];
    };
  };

}
