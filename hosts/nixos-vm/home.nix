# hosts/nixos-vm/home.nix

{ config, pkgs, pkgs-unstable, ... }:
{

  # hyprland.enable = true;  # Disabled - needs 3D acceleration for snapshots
  # wayland.windowManager.hyprland.settings = {
  #   monitor = [
  #     "Virtual-1, 1920x1080@60,0x0,1"
  #   ];
  # };

  cyber.enable = true;

  home.packages = with pkgs; [

  ];

}
