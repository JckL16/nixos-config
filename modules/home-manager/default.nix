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
  nvim.enable = lib.mkDefault true;
  alacritty.enable = lib.mkDefault true;

  steam.enable = lib.mkDefault false;
  gamemode.enable = lib.mkDefault false;
  minecraft.enable = lib.mkDefault false;

  libreoffice.enable = lib.mkDefault false;
  onlyoffice.enable = lib.mkDefault false;
  
  sway.enable = lib.mkDefault false;
  hyprland.enable = lib.mkDefault false;

  # Programming languages
  rust.enable = lib.mkDefault false;
  c-cpp.enable = lib.mkDefault false;
  python-dev.enable = lib.mkDefault false;
}
