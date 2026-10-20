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
    kitty.enable =
      lib.mkEnableOption "Enable kitty terminal";
  };

  config = lib.mkIf config.kitty.enable {
    programs.kitty = {
      enable = true;

      font = {
        name = "${f.name} Mono";
        size = 11;
      };

      settings = {
        # Nerd Fonts' Material Design icon set (fastfetch, etc.) lives in
        # U+F0001-U+F1AF0. Kitty auto-widens PUA glyphs followed by a space to
        # 2 cells, but the "Mono" Nerd Font variant already renders them at a
        # fixed 1 cell — without this, that mismatch shows up as a stray gap
        # after every icon.
        narrow_symbols = "U+f0001-U+f1af0 1";

        background = base00;
        foreground = base05;

        cursor = base05;
        cursor_text_color = base00;
        cursor_shape = "beam";
        cursor_blink_interval = "0.5";
        cursor_stop_blinking_after = "0";

        selection_background = base05;
        selection_foreground = base00;

        color0 = base01; color8  = base03;
        color1 = base08; color9  = base08;
        color2 = base0B; color10 = base0B;
        color3 = base0A; color11 = base0A;
        color4 = base0D; color12 = base0D;
        color5 = base0E; color13 = base0E;
        color6 = base0C; color14 = base0C;
        color7 = base04; color15 = base07;

        scrollback_lines = 10000;
        wheel_scroll_multiplier = "3.0";

        window_padding_width = 10;
        background_opacity = "0.95";
        hide_window_decorations = "no";

        initial_window_width = "100c";
        initial_window_height = "30c";

        # Kitty >=0.49 also persists maximized/fullscreen state via remember_window_size,
        # and Hyprland honors that request — without this, any window that was ever
        # maximized makes every subsequent kitty instance reopen maximized/fullscreen
        # regardless of what else is tiled on the workspace.
        remember_window_size = "no";
      };
    };
  };

}
