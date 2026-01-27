# hosts/nixos-vm/home.nix

{ config, pkgs, ... }:
{

  hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "Virtual-1, 1920x1080@60,0x0,1"
    ];
  };

  cyber.enable = true;

  home.packages = with pkgs; [

  ];

}
