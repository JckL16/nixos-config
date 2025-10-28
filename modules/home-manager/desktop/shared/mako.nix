# modules/home-manager/shared/mako.nix

{ pkgs, lib, config, ... }: {
  
  config = lib.mkIf (config.sway.enable || config.hyprland.enable) {
    services.mako = {
      enable = true;
      settings = {
        font = "JetBrainsMono Nerd Font Mono 10";
        background-color = "#2E3440";
        border-color = "#4C566A";
        text-color = "#D8DEE9";
        border-size = 1;        border-radius = 3;
        padding = "8";
        margin = "8";
        max-visible = 5;
        sort = "-time";
        group-by = "app-name";
      };
      extraConfig = ''
        [app-name="Spotify"]
        default-timeout=10000

        [app-name="blueman"]
        default-timeout=5000

        [app-name="Discord"]
        default-timeout=10000

        [app-name="Steam"]
        default-timeout=10000
      '';
    };
  };
}