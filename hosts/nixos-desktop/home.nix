# hosts/nixos-desktop/home.nix

{ config, pkgs, ... }:
{

  # Enabled the hyprland config for this user
  hyprland.enable = true;

  # Enabled user specific configuration for gaming
  steam.enable = true;
  gamemode.enable = true;
  minecraft.enable = true;

  # Installs the libreoffice suite on the system
  # libreoffice.enable = true;

  home.packages = with pkgs; [
    obsidian
    spotify
    vscode
    discord-ptb
  ];

}
