{ pkgs, lib, config, variables, ... }:
let
  f = config.theme.font;

  # Same base16 palette as nvim (modules/home-manager/programs/command-line/nvim) —
  # decoupled from variables.theme so the terminal keeps distinct, non-purple
  # syntax-like colors instead of the monochrome theme's shades of grey.
  base00 = "#252525"; base01 = "#2d2d2d"; base02 = "#3b3b3b"; base03 = "#6e6e6e";
  base04 = "#ababab"; base05 = "#d0d0d0"; base06 = "#e3e3e3"; base07 = "#f7f7f7";
  base08 = "#e06c75"; base0A = "#e5c07b"; base0B = "#98c379";
  base0C = "#56b6c2"; base0D = "#61afef"; base0E = "#7f9bbf";
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

          normal = {
            black   = base01;
            red     = base08;
            green   = base0B;
            yellow  = base0A;
            blue    = base0D;
            magenta = base0E;
            cyan    = base0C;
            white   = base04;
          };
          bright = {
            black   = base03;
            red     = base08;
            green   = base0B;
            yellow  = base0A;
            blue    = base0D;
            magenta = base0E;
            cyan    = base0C;
            white   = base07;
          };
          primary = {
            background = base00;
            foreground = base05;
          };
          cursor = {
            cursor = base05;
            text   = base00;
          };
          selection = {
            background = base05;
            text       = base00;
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