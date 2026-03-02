# hosts/nixos-rugged/home.nix
#

{ config, pkgs, lib, ... }:
{

  hyprland.enable = true;

  # Default lid-close to do nothing (toggle with Super+Shift+O)
  wayland.windowManager.hyprland.settings.exec-once = [
    "echo 0 > ~/.config/hypr/lid-suspend-enabled"
  ];

  python-dev.enable = true;
  python-dev.packages = [ "requests" "numpy" "pandas" ];
  rust.enable = true;
  c-cpp.enable = true;

  cyber.enable = true;

  virt-manager.enable = true;

  onlyoffice.enable = true;

  home.packages = with pkgs; [
    obsidian
    spotify
    signal-desktop-bin
    discord-ptb
    ttyper
    qbittorrent
    claude-code
  ];

}
