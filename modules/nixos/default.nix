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

  # Display managers (greetd is auto-enabled by hyprland, ly can be enabled manually)
  ly.enable = lib.mkDefault false;

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

  # Winbox for configuring and working with mikrotik routers and switches
  winbox.enable = lib.mkDefault false;

  # Some settings concerning virtualization and gueast agents
  virtualisation.enable = lib.mkDefault false;
  qemu-guest-agent.enable = lib.mkDefault false;
  virtualbox-guest-agent.enable = lib.mkDefault false;

  # To set up a postgres database for the metasploit framework
  metasploit-db.enable = lib.mkDefault false;

  # Enableing the system to work with a yubikey
  yubikey.enable = lib.mkDefault true;

  # VeraCrypt disk encryption
  veracrypt.enable = lib.mkDefault true;

  # Common system fonts for browsers and applications
  fonts-config.enable = lib.mkDefault true;
}
