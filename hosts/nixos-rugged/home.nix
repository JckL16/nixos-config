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
    caligula
    todoist-electron
    ticktick
    thunderbird
  ] ++ [
    pkgs-unstable.protonmail-desktop
  ];

}
