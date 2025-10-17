# hosts/nixos-laptop/home.nix

{ config, pkgs, ... }:
{

  sway.enable = true;
  steam.enable = true;

  home.packages = with pkgs; [
    obsidian
    spotify
    vscode
  ];

}