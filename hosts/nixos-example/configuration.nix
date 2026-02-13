# hosts/nixos-example/configuration.nix
#
# System-level configuration for your host.
# Uncomment options below to enable them. For details on each module
# see CONTENT.md in the repository root.

{ config, pkgs, home-manager, inputs, variables, ... }: {

  imports = [
    home-manager.nixosModules.home-manager
  ];

  # ==========================================================================
  # Hostname — change this to match your host
  # ==========================================================================
  networking.hostName = "nixos-example";

  # ==========================================================================
  # Bootloader
  # GRUB is enabled by default and works for both EFI and BIOS systems.
  # For BIOS, set bootDevice and isBIOS in flake.nix (see INSTALL.md).
  # To use systemd-boot instead (EFI only), disable GRUB and enable it below.
  # ==========================================================================
  # grub.enable = false;
  # systemd-boot.enable = true;
  # grub.nordic-theme.enable = true;

  # ==========================================================================
  # Desktop Environment — pick one
  # ==========================================================================
  hyprland.enable = true;
  # gnome.enable = true;

  # ==========================================================================
  # Display Manager
  # greetd is enabled by default when using Hyprland. Uncomment below to
  # switch to ly (when available) or to explicitly disable greetd.
  # ==========================================================================
  # greetd.enable = false;
  # ly.enable = true;

  # ==========================================================================
  # Graphics Drivers — uncomment the one matching your hardware
  # ==========================================================================
  # intel-graphics.enable = true;
  # amd-graphics.enable = true;
  # nvidia-graphics.enable = true;

  # ==========================================================================
  # Gaming
  # These enable the system-level components. Also enable the matching
  # options in home.nix for full functionality.
  # ==========================================================================
  # steam.enable = true;
  # gamemode.enable = true;

  # ==========================================================================
  # Virtualisation & Containers
  # ==========================================================================
  # virtualisation.enable = true;   # libvirt/QEMU KVM
  # docker.enable = true;

  # ==========================================================================
  # Networking Tools
  # ==========================================================================
  # winbox.enable = true;           # MikroTik Winbox

  # ==========================================================================
  # Security
  # ==========================================================================
  # metasploit-db.enable = true;    # PostgreSQL database for Metasploit

  # ==========================================================================
  # VM Guest Agents — only needed when running inside a virtual machine
  # ==========================================================================
  # qemu-guest-agent.enable = true;
  # virtualbox-guest-agent.enable = true;

  # ==========================================================================
  # Core Defaults (enabled automatically, override here if needed)
  # ==========================================================================
  # audio.enable = false;              # Disable PipeWire audio
  # bluetooth.enable = false;          # Disable Bluetooth
  # swap-file.enable = false;          # Disable swap file
  # swap-file.size = 8192;             # Change swap size (MiB), default 16384
  # garbage-collection.enable = false; # Disable weekly nix store cleanup

  # ==========================================================================
  # Home Manager — connects user-level config (home.nix)
  # You should not need to change this section.
  # ==========================================================================
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
