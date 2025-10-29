# hosts/nixos-desktop/home.nix

{ config, pkgs, ... }:
{

  hyprland.enable = true;

  steam.enable = true;
  gamemode.enable = true;
  minecraft.enable = true;

  libreoffice.enable = true;

  home.packages = with pkgs; [
    obsidian
    spotify
    vscode
    discord-ptb
  ];

}
