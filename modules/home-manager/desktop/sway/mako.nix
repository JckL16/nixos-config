# modules/home-manager/sway/mako.nix

{ pkgs, lib, config, ... }: {

  config = lib.mkIf config.sway.enable {
    services.mako = {
      enable = true;
      settings = {
        font = "JetBrainsMono Nerd Font Mono 10";
        background-color = "#2E3440";
        border-color = "#4C566A";
        text-color = "#D8DEE9";
        border-size = 1;
        border-radius = 0;
        padding = "8";
        margin = "8";
        max-visible = 5;
        sort = "-time";
      };
    };
  };
}