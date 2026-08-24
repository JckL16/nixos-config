# modules/home-manager/theme/presets.nix
#
# Pure Nix attrset — no pkgs dependency so it can be imported by both
# home-manager modules and NixOS modules (e.g. the GRUB theme builder).
#
# Each entry must define every field that theme/default.nix declares options for,
# since the loader applies mkDefault over the whole attrset.

{
  # ── Nord ───────────────────────────────────────────────────────────────────
  nord = {
    colors = {
      nord0  = "#2E3440"; nord1  = "#3B4252"; nord2  = "#434C5E"; nord3  = "#4C566A";
      nord4  = "#D8DEE9"; nord5  = "#E5E9F0"; nord6  = "#ECEFF4";
      nord7  = "#8FBCBB"; nord8  = "#88C0D0"; nord9  = "#81A1C1"; nord10 = "#5E81AC";
      nord11 = "#BF616A"; nord12 = "#D08770"; nord13 = "#EBCB8B";
      nord14 = "#A3BE8C"; nord15 = "#B48EAD";

      background    = "#2E3440"; backgroundAlt = "#3B4252"; surface = "#434C5E";
      border        = "#4C566A";
      textDim       = "#D8DEE9"; text = "#E5E9F0"; textBright = "#ECEFF4";
      accent        = "#88C0D0"; accentBlue = "#81A1C1"; accentDark = "#5E81AC";
      urgent        = "#BF616A"; warning    = "#EBCB8B"; success    = "#A3BE8C";

      backgroundRgb    = "46, 52, 64";
      backgroundAltRgb = "59, 66, 82";
      borderRgb        = "76, 86, 106";
      accentRgb        = "136, 192, 208";
      textDimRgb       = "216, 222, 233";
      urgentRgb        = "191, 97, 106";
    };

    font = { name = "JetBrainsMono Nerd Font"; size = "0.9rem"; weight = 600; };

    gtk = {
      themeName        = "Nordic";
      themePackage     = "nordic";
      iconThemeName    = "Papirus-Dark";
      iconThemePackage = "papirus-icon-theme";
      cursorName       = "Bibata-Modern-Classic";
      cursorPackage    = "bibata-cursors";
      cursorSize       = 20;
    };
  };

  # ── Gruvbox ────────────────────────────────────────────────────────────────
  gruvbox = {
    colors = {
      nord0  = "#282828"; nord1  = "#3c3836"; nord2  = "#504945"; nord3  = "#665c54";
      nord4  = "#bdae93"; nord5  = "#d5c4a1"; nord6  = "#ebdbb2";
      nord7  = "#8ec07c"; nord8  = "#fe8019"; nord9  = "#83a598"; nord10 = "#076678";
      nord11 = "#fb4934"; nord12 = "#d65d0e"; nord13 = "#fabd2f";
      nord14 = "#b8bb26"; nord15 = "#d3869b";

      background    = "#282828"; backgroundAlt = "#3c3836"; surface = "#504945";
      border        = "#665c54";
      textDim       = "#bdae93"; text = "#d5c4a1"; textBright = "#ebdbb2";
      # Orange is Gruvbox's most distinctive accent; aqua as secondary
      accent        = "#fe8019"; accentBlue = "#83a598"; accentDark = "#076678";
      urgent        = "#fb4934"; warning    = "#fabd2f"; success    = "#b8bb26";

      backgroundRgb    = "40, 40, 40";
      backgroundAltRgb = "60, 56, 54";
      borderRgb        = "102, 92, 84";
      accentRgb        = "254, 128, 25";
      textDimRgb       = "189, 174, 147";
      urgentRgb        = "251, 73, 52";
    };

    font = { name = "JetBrainsMono Nerd Font"; size = "0.9rem"; weight = 600; };

    gtk = {
      themeName        = "adw-gtk3-dark";
      themePackage     = "adw-gtk3";
      iconThemeName    = "Papirus-Dark";
      iconThemePackage = "papirus-icon-theme";
      # Amber cursor matches Gruvbox's warm orange tones
      cursorName       = "Bibata-Modern-Amber";
      cursorPackage    = "bibata-cursors";
      cursorSize       = 20;
    };
  };

  # ── Dracula ────────────────────────────────────────────────────────────────
  dracula = {
    colors = {
      nord0  = "#282a36"; nord1  = "#44475a"; nord2  = "#44475a"; nord3  = "#6272a4";
      nord4  = "#6272a4"; nord5  = "#f8f8f2"; nord6  = "#f8f8f2";
      nord7  = "#8be9fd"; nord8  = "#bd93f9"; nord9  = "#6272a4"; nord10 = "#44475a";
      nord11 = "#ff5555"; nord12 = "#ffb86c"; nord13 = "#f1fa8c";
      nord14 = "#50fa7b"; nord15 = "#ff79c6";

      background    = "#282a36"; backgroundAlt = "#44475a"; surface = "#44475a";
      border        = "#6272a4";
      textDim       = "#6272a4"; text = "#f8f8f2"; textBright = "#f8f8f2";
      # Purple is Dracula's signature accent
      accent        = "#bd93f9"; accentBlue = "#8be9fd"; accentDark = "#6272a4";
      urgent        = "#ff5555"; warning    = "#ffb86c"; success    = "#50fa7b";

      backgroundRgb    = "40, 42, 54";
      backgroundAltRgb = "68, 71, 90";
      borderRgb        = "98, 114, 164";
      accentRgb        = "189, 147, 249";
      textDimRgb       = "98, 114, 164";
      urgentRgb        = "255, 85, 85";
    };

    font = { name = "JetBrainsMono Nerd Font"; size = "0.9rem"; weight = 600; };

    gtk = {
      # No dedicated Dracula GTK package in nixpkgs; adw-gtk3-dark is a clean dark base
      themeName        = "adw-gtk3-dark";
      themePackage     = "adw-gtk3";
      iconThemeName    = "Papirus-Dark";
      iconThemePackage = "papirus-icon-theme";
      cursorName       = "Bibata-Modern-Classic";
      cursorPackage    = "bibata-cursors";
      cursorSize       = 20;
    };
  };

  # ── Tokyo Night ────────────────────────────────────────────────────────────
  "tokyo-night" = {
    colors = {
      nord0  = "#1a1b26"; nord1  = "#24283b"; nord2  = "#292e42"; nord3  = "#414868";
      nord4  = "#565f89"; nord5  = "#a9b1d6"; nord6  = "#c0caf5";
      nord7  = "#73daca"; nord8  = "#7aa2f7"; nord9  = "#7dcfff"; nord10 = "#3d59a1";
      nord11 = "#f7768e"; nord12 = "#ff9e64"; nord13 = "#e0af68";
      nord14 = "#9ece6a"; nord15 = "#bb9af7";

      background    = "#1a1b26"; backgroundAlt = "#24283b"; surface = "#292e42";
      border        = "#414868";
      textDim       = "#565f89"; text = "#a9b1d6"; textBright = "#c0caf5";
      # Blue is Tokyo Night's signature accent
      accent        = "#7aa2f7"; accentBlue = "#7dcfff"; accentDark = "#3d59a1";
      urgent        = "#f7768e"; warning    = "#e0af68"; success    = "#9ece6a";

      backgroundRgb    = "26, 27, 38";
      backgroundAltRgb = "36, 40, 59";
      borderRgb        = "65, 72, 104";
      accentRgb        = "122, 162, 247";
      textDimRgb       = "86, 95, 137";
      urgentRgb        = "247, 118, 142";
    };

    font = { name = "JetBrainsMono Nerd Font"; size = "0.9rem"; weight = 600; };

    gtk = {
      # No dedicated Tokyo Night GTK package in nixpkgs; adw-gtk3-dark is a clean dark base
      themeName        = "adw-gtk3-dark";
      themePackage     = "adw-gtk3";
      iconThemeName    = "Papirus-Dark";
      iconThemePackage = "papirus-icon-theme";
      cursorName       = "Bibata-Modern-Classic";
      cursorPackage    = "bibata-cursors";
      cursorSize       = 20;
    };
  };
}
