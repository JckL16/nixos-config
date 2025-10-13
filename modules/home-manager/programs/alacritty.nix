# modules/home-manager/alacritty.nix

{ pkgs, lib, config, variables, ... }: {
  
  options = {
    alacritty.enable = 
      lib.mkEnableOption "Enable alacritty terminal";
  };

  config = lib.mkIf config.alacritty.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        colors = {
          bright = {
            black = "#4C566A";
            blue = "#81A1C1";
            cyan = "#8FBCBB";
            green = "#A3BE8C";
            magenta = "#B48EAD";
            red = "#BF616A";
            white = "#ECEFF4";
            yellow = "#EBCB8B";
          };
          cursor = {
            cursor = "#D8DEE9";
            text = "#2E3440";
          };
          normal = {
            black = "#3B4252";
            blue = "#81A1C1";
            cyan = "#88C0D0";
            green = "#A3BE8C";
            magenta = "#B48EAD";
            red = "#BF616A";
            white = "#E5E9F0";
            yellow = "#EBCB8B";
          };
          primary = {
            background = "#2E3440";
            foreground = "#D8DEE9";
          };
          selection = {
            background = "#D8DEE9";
            text = "#2E3440";
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
            family = "JetBrainsMono Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            family = "JetBrainsMono Nerd Font Mono";
            style = "Italic";
          };
          normal = {
            family = "JetBrainsMono Nerd Font Mono";
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