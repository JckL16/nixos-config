# hosts/nixos-laptop/home.nix

{ config, pkgs, ... }:
{

  # Enables the user level config of hyprland
  hyprland.enable = true;

  # Enables user level config for gaming
  steam.enable = true;
  gamemode.enable = true;
  minecraft.enable = true;

  # Installs the libreoffice suite for the user
  libreoffice.enable = true;

  # Installs python and some utility programs for the user
  python-dev.enable = true;
  rust.enable = true;
  c-cpp.enable = true;

  # cyber.all = true;

  virt-manager.enable = true;

  home.packages = with pkgs; [
    obsidian
    spotify
    vscode
    anki
    signal-desktop
  ];

}
