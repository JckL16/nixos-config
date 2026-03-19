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
  # GNOME works better without 3D acceleration (needed for snapshots)
  gnome.enable = true;
  # hyprland.enable = true;  # Requires 3D acceleration

  # Guest-agent for the vm
  qemu-guest-agent.enable = true;

  # intel-graphics.enable = true;  # Not needed for VM - uses virtio-gpu

  # Security tools
  metasploit-db.enable = true;  # PostgreSQL database for Metasploit
  docker.enable = true;         # For vulnerable containers (e.g., VulnHub)

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
