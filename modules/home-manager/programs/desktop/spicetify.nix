# modules/home-manager/programs/desktop/spicetify.nix
#
# Skins the real Spotify client via spicetify-nix using the active theme's
# palette, so it re-themes automatically whenever variables.theme changes.
# Enable per-host with `spotify.enable = true;`. Any `programs.spicetify.*`
# option (theme, spotifyPackage, enabledExtensions, ...) can still be
# overridden per-host on top of this.

{ lib, pkgs, config, inputs, ... }:
let
  colors = config.theme.colors;
  hex = color: lib.removePrefix "#" color;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  options.spotify.enable = lib.mkEnableOption "Spotify, themed via spicetify-nix";

  config = lib.mkIf config.spotify.enable {
    programs.spicetify = {
      enable = true;
      theme = lib.mkDefault spicePkgs.themes.sleek;

      # Keys per Sleek's color.ini legend (github.com/spicetify/spicetify-themes).
      customColorScheme = lib.mkDefault {
        text = hex colors.textBright;
        subtext = hex colors.textDim;
        "nav-active-text" = hex colors.background;
        main = hex colors.background;
        sidebar = hex colors.background;
        player = hex colors.backgroundAlt;
        card = hex colors.backgroundAlt;
        shadow = hex colors.background;
        "main-secondary" = hex colors.surface;
        button = hex colors.accent;
        "button-secondary" = hex colors.accentBlue;
        "button-active" = hex colors.warning;
        "button-disabled" = hex colors.border;
        "nav-active" = hex colors.accent;
        "play-button" = hex colors.accent;
        "tab-active" = hex colors.surface;
        notification = hex colors.backgroundAlt;
        "notification-error" = hex colors.urgent;
        "playback-bar" = hex colors.accent;
        misc = hex colors.textBright;
      };
    };
  };
}
