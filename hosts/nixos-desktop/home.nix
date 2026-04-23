# hosts/nixos-desktop/home.nix

{ config, pkgs, pkgs-unstable, ... }:
{

  # Enabled the hyprland config for this user
  hyprland.enable = true;

  # Enabled user specific configuration for gaming
  steam.enable = true;
  gamemode.enable = true;
  minecraft.enable = true;

  zen-browser.enable = true;

  winbox.enable = true;

  rust.enable = true;
  python-dev.enable = true;
  python-dev.packages = [ "tqdm" ];
  go.enable = true;

  cyber.enable = true;

  virt-manager.enable = true;

  home.packages = with pkgs; [
    obsidian
    spotify
    vscode
    discord-ptb
    caligula
    nmap
    nixos-anywhere
    jq
    signal-desktop-bin
    qbittorrent
    claude-code
    minikube
    kubectl
    ticktick
    ] ++ [
    pkgs-unstable.protonmail-desktop
  ];

}
