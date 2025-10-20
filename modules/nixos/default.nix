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
    ./system-packages.nix
    ./users.nix
  ];

  # Default enables
  audio.enable = lib.mkDefault true;
  bluetooth.enable = lib.mkDefault true;
  
  sway.enable = lib.mkDefault false;
  gnome.enable = lib.mkDefault false;

  systemd-boot.enable = lib.mkDefault true;
  grub.enable = lib.mkDefault false;

  intel-graphics.enable = lib.mkDefault false;
  amd-graphics.enable = lib.mkDefault false;
  nvidia-graphics.enable = lib.mkDefault false;

  steam.enable = lib.mkDefault false;
}