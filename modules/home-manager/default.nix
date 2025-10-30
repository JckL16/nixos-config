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
    ./cyber
  ];

  # Default enables
  git.enable = lib.mkDefault true;
  nvim.enable = lib.mkDefault true;
  alacritty.enable = lib.mkDefault true;
  
  # Gaming modules
  steam.enable = lib.mkDefault false;
  gamemode.enable = lib.mkDefault false;
  minecraft.enable = lib.mkDefault false;

  # Office suites
  libreoffice.enable = lib.mkDefault false;
  onlyoffice.enable = lib.mkDefault false;

  # Desktop environments
  sway.enable = lib.mkDefault false;
  hyprland.enable = lib.mkDefault false;

  # Programming languages
  rust.enable = lib.mkDefault false;
  c-cpp.enable = lib.mkDefault false;
  python-dev.enable = lib.mkDefault false;

  # Sets of cyber programs
  cyber.all = lib.mkDefault false;
  cyber.binary-exploitation = lib.mkDefault false;
  cyber.cryptography = lib.mkDefault false;
  cyber.forensics = lib.mkDefault false;
  cyber.general = lib.mkDefault false;
  cyber.reverse-engineering = lib.mkDefault false;
  cyber.web-exploitation = lib.mkDefault false;
}
