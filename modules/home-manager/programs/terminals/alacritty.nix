# modules/home-manager/programs/alacritty.nix

{ pkgs, lib, config, variables, ... }:
let
  c = config.theme.colors;
  f = config.theme.font;
in {

  options = {
    alacritty.enable =
      lib.mkEnableOption "Enable alacritty terminal";
  };

  config = lib.mkIf config.alacritty.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        colors = {
          # 16-color palette mapped through the nord0-nord15 theme slots.
          # Each theme preset assigns these to its closest palette equivalents.
          normal = {
            black   = c.nord1;   # slightly-lighter background
            red     = c.nord11;
            green   = c.nord14;
            yellow  = c.nord13;
            blue    = c.nord9;
            magenta = c.nord15;
            cyan    = c.nord7;
            white   = c.nord5;
          };
          bright = {
            black   = c.nord3;   # visible-but-muted (borders/comments)
            red     = c.nord11;
            green   = c.nord14;
            yellow  = c.nord13;
            blue    = c.nord9;
            magenta = c.nord15;
            cyan    = c.nord8;   # primary accent as bright cyan
            white   = c.nord6;
          };
          primary = {
            background = c.background;
            foreground = c.textDim;
          };
          cursor = {
            cursor = c.textDim;
            text   = c.background;
          };
          selection = {
            background = c.textDim;
            text       = c.background;
          };
        };
        cursor = {
          blink_interval = 500;
          blink_timeout = 0;
          style = {
            blinking = "On";
            shape = "Beam";
          };
        };
        font = {
          size = 11.0;
          bold = {
            family = "${f.name} Mono";
            style = "Bold";
          };
          italic = {
            family = "${f.name} Mono";
            style = "Italic";
          };
          normal = {
            family = "${f.name} Mono";
            style = "Regular";
          };
          offset = {
            x = 0;
            y = 0;
          };
        };
        scrolling = {
          history = 10000;
          multiplier = 3;
        };
        window = {
          decorations = "full";
          dynamic_padding = true;
          opacity = 0.95;
          startup_mode = "Windowed";
          dimensions = {
            columns = 100;
            lines = 30;
          };
          padding = {
            x = 10;
            y = 10;
          };
        };
        general = {
          live_config_reload = true;
        };
      };
    };
  };

}