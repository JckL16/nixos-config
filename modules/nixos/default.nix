{ pkgs, lib, variables, config, ... }: {

  system.stateVersion = variables.system-state-version;

  imports = [
    ./core
    ./hardware
    ./boot
    ./desktop
    ./programs
    ./guest-agents
    ./disko
    ./system-packages.nix
    ./users.nix
  ];

  audio.enable = lib.mkDefault true;
  bluetooth.enable = lib.mkDefault true;
  garbage-collection.enable = lib.mkDefault true;

  gnome.enable = lib.mkDefault false;
  hyprland.enable = lib.mkDefault false;

  ly.enable = lib.mkDefault false;

  systemd-boot.enable = lib.mkDefault false;
  grub.enable = lib.mkDefault true;
  grub.theme.enable = lib.mkDefault false;

  intel-graphics.enable = lib.mkDefault false;
  amd-graphics.enable = lib.mkDefault false;
  nvidia-graphics.enable = lib.mkDefault false;

  gamemode.enable = lib.mkDefault false;
  steam.enable = lib.mkDefault false;

  winbox.enable = lib.mkDefault false;

  virtualisation.enable = lib.mkDefault false;
  qemu-guest-agent.enable = lib.mkDefault false;
  virtualbox-guest-agent.enable = lib.mkDefault false;

  metasploit-db.enable = lib.mkDefault false;

  yubikey.enable = lib.mkDefault true;

  tpm2Unlock.enable = lib.mkDefault false;

  veracrypt.enable = lib.mkDefault true;

  ventoy.enable = lib.mkDefault false;

  fonts-config.enable = lib.mkDefault true;
}
