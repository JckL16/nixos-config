# modules/home-manager/shared/mako.nix

{ pkgs, lib, config, ... }:
let
  copyNotification = pkgs.writeShellScript "mako-copy-notification" ''
    body=$(${pkgs.mako}/bin/makoctl dump | ${pkgs.jq}/bin/jq -r '.[0].body')
    printf '%s' "$body" | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.mako}/bin/makoctl dismiss
  '';
in {

  config = lib.mkIf config.hyprland.enable {
    services.mako = {
      enable = true;
      settings = {
        font = "JetBrainsMono Nerd Font Mono 10";
        background-color = "#2E3440";
        border-color = "#4C566A";
        text-color = "#D8DEE9";
        border-size = 1;
        border-radius = 3;
        padding = "8";
        margin = "8";
        width = 400;
        height = 300;
        max-visible = 5;
        sort = "-time";
        group-by = "app-name";
        default-timeout = 10000;
        "on-button-right" = "exec ${copyNotification}";
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

        [summary~="Battery"]
        default-timeout=0
        group-by=summary

        [summary~="Battery is full"]
        invisible=1

        [urgency=critical]
        default-timeout=0
        border-color=#BF616A
        background-color=#2E3440
      '';
    };
  };
}
