# hosts/nixos-laptop/home.nix

{ config, pkgs-unstable,  pkgs, ... }:
{

  # Enables the user level config of hyprland
  hyprland.enable  = true;
  hyprland.battery = true;

  tmux.enable = true;

  # Enables user level config for gaming
  steam.enable = true;
  gamemode.enable = true;
  minecraft.enable = true;

  obsidian.enable = true;

  # Installs the libreoffice suite for the user
  # libreoffice.enable = true;
  onlyoffice.enable = true;

  # Installs python and some utility programs for the user
  python-dev.enable = true;
  python-dev.packages = [ "tqdm" ];
  rust.enable = true;
  c-cpp.enable = true;

  cyber.enable = true;

  virt-manager.enable = true;

  home.packages = with pkgs; [
    spotify
    vscode
    anki
    signal-desktop
    discord-ptb
    ttyper
    qbittorrent
    claude-code
    ticktick
    calibre
    localsend
  ] ++ [
    pkgs-unstable.protonmail-desktop
  ];

}
