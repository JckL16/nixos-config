# hosts/nixos-wsl/home.nix

{ config, pkgs, pkgs-unstable, ... }:
{

  # Disabled - not applicable to WSL (use Windows Terminal and browser)
  alacritty.enable = false;
  zen-browser.enable = false;

  # Programming environments
  go.enable = true;
  rust.enable = true;
  python-dev.enable = true;
  c-cpp.enable = true;

  # Cyber security tools
  cyber.enable = true;

  home.packages = with pkgs; [

  ];

}
