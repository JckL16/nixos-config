{ lib, config, variables, ... }:
let
  c = config.theme.colors;
  themeName = variables.theme;

  # chroma (code preview syntax highlighter) ships matching styles for some
  # themes; themes without a direct match fall back to a close dark style.
  codeSyntaxMap = {
    nord          = "nord";
    gruvbox       = "gruvbox";
    dracula       = "dracula";
    "tokyo-night" = "tokyonight-night";
  };
  codeSyntaxHighlight = codeSyntaxMap.${themeName} or "doom-one2";
in {

  options = {
    programs.superfile.enableThemeIntegration =
      lib.mkEnableOption "Enable superfile with a theme matching the active system theme";
  };

  config = lib.mkIf config.programs.superfile.enableThemeIntegration {
    # spf writes a default config.toml on first run if none exists yet; force
    # lets home-manager claim/overwrite it instead of refusing to activate.
    xdg.configFile."superfile/config.toml".force = true;

    programs.superfile = {
      enable = true;

      settings = {
        theme = themeName;
      };

      themes.${themeName} = {
        code_syntax_highlight = codeSyntaxHighlight;

        full_screen_fg = c.text;
        full_screen_bg = c.background;

        gradient_color = [ c.accent c.accentBlue ];

        file_panel_fg = c.text;
        file_panel_bg = c.background;
        file_panel_border = c.border;
        file_panel_border_active = c.accent;
        file_panel_top_directory_icon = c.success;
        file_panel_top_path = c.accent;
        file_panel_item_selected_fg = c.accent;
        file_panel_item_selected_bg = c.background;

        footer_fg = c.text;
        footer_bg = c.background;
        footer_border = c.border;
        footer_border_active = c.accent;

        sidebar_fg = c.text;
        sidebar_bg = c.background;
        sidebar_title = c.accentBlue;
        sidebar_border = c.background;
        sidebar_border_active = c.accent;
        sidebar_item_selected_fg = c.accent;
        sidebar_item_selected_bg = c.background;
        sidebar_divider = c.border;

        modal_fg = c.text;
        modal_bg = c.backgroundAlt;
        modal_border_active = c.border;
        modal_cancel_fg = c.background;
        modal_cancel_bg = c.urgent;
        modal_confirm_fg = c.background;
        modal_confirm_bg = c.success;

        help_menu_hotkey = c.accentBlue;
        help_menu_title = c.accent;

        cursor = c.textBright;
        correct = c.success;
        error = c.urgent;
        hint = c.accentBlue;
        cancel = c.warning;
      };
    };
  };

}
