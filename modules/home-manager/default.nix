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
    ./programming
  ];

  # Default enables
  git.enable = lib.mkDefault true;
  sway.enable = lib.mkDefault false;
  alacritty.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault false;
  libreoffice.enable = lib.mkDefault false;
  onlyoffice.enable = lib.mkDefault false;
  nvim.enable = lib.mkDefault true;

  # Programming languages
  rust.enable = lib.mkDefault false;
  c-cpp.enable = lib.mkDefault false;
  python-dev.enable = lib.mkDefault false;
}