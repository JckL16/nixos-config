# hosts/nixos-rugged/home.nix

{ config, pkgs, pkgs-unstable, lib, ... }:
{

  hyprland.enable = true;

  # Lid close does nothing
  wayland.windowManager.hyprland.settings.bindl = lib.mkForce [];

  # Enabled user specific configuration for gaming
  steam.enable = true;
  gamemode.enable = true;

  zen-browser.enable = true;

  python-dev.enable = true;
  python-dev.packages = [ "requests" "numpy" "pandas" "matplotlib" ];
  rust.enable = true;
  c-cpp.enable = true;
  go.enable = true;

  cyber.enable = true;

  virt-manager.enable = true;

  onlyoffice.enable = true;

  home.packages = with pkgs; [
    obsidian
    signal-desktop-bin
    discord-ptb
    ttyper
    qbittorrent
    claude-code
    caligula
    ticktick
    thunderbird
    manim
    vscode
    onedrive
  ] ++ [
      pkgs-unstable.protonmail-desktop
      pkgs-unstable.spotify
      pkgs-unstable.zoom-us
  ];

}
