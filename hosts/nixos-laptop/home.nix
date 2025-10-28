# hosts/nixos-laptop/home.nix

{ config, pkgs, ... }:
{

  hyprland.enable = true;
  steam.enable = true;
  gamemode.enable = true;

  libreoffice.enable = true;

  python-dev.enable = true;
  python-dev.includeDataScience = true;

  home.packages = with pkgs; [
    obsidian
    spotify
    vscode
  ];

}