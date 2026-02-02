{ pkgs, lib, variables, config, ... }: {

  # System state version
  system.stateVersion = variables.system-state-version;

  # Imports - organized by category
  imports = [
    ./core
    ./hardware
    ./boot
    ./desktop
    ./programs
    ./guest-agents
    ./system-packages.nix
    ./users.nix
  ];

  # Default enables
  audio.enable = lib.mkDefault true;
  bluetooth.enable = lib.mkDefault true;
  swap-file.enable = lib.mkDefault true;
  garbage-collection.enable = lib.mkDefault true;

  # Desktop environments installed system wide
  gnome.enable = lib.mkDefault false;
  hyprland.enable = lib.mkDefault false;

  # Bootloader
  systemd-boot.enable = lib.mkDefault false;
  grub.enable = lib.mkDefault true;
  grub.nordic-theme.enable = lib.mkDefault false;

  # Graphics drivers
  intel-graphics.enable = lib.mkDefault false;
  amd-graphics.enable = lib.mkDefault false;
  nvidia-graphics.enable = lib.mkDefault false;

  # System wide gaming config
  gamemode.enable = lib.mkDefault false;
  steam.enable = lib.mkDefault false;

  winbox.enable = lib.mkDefault false;

  virtualisation.enable = lib.mkDefault false;
  qemu-guest-agent.enable = lib.mkDefault false;
  virtualbox-guest-agent.enable = lib.mkDefault false;

  metasploit-db.enable = lib.mkDefault false;
}
