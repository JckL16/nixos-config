{ pkgs, lib, variables, config, ... }: {
  
  home.stateVersion = variables.system-state-version;
  home.username = variables.username;
  home.homeDirectory = "/home/${variables.username}";
  
  dconf.enable = true;
  programs.home-manager.enable = true;

  imports = [
    ./programs
    ./services
    ./desktop
  ];

  # Default enables
  git.enable = lib.mkDefault true;
  sway.enable = lib.mkDefault false;
  alacritty.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault false;
}