{ lib, variables, ... }:
let
  presets = import ./presets.nix;
  preset  = presets.${variables.theme or "nord"};

  mkColorOpt = default: lib.mkOption { type = lib.types.str; inherit default; };
  mkStrOpt   = default: lib.mkOption { type = lib.types.str; inherit default; };
  mkIntOpt   = default: lib.mkOption { type = lib.types.int; inherit default; };
in {
  options.theme = {

    colors = {
      nord0  = mkColorOpt "#2E3440"; nord1  = mkColorOpt "#3B4252";
      nord2  = mkColorOpt "#434C5E"; nord3  = mkColorOpt "#4C566A";
      nord4  = mkColorOpt "#D8DEE9"; nord5  = mkColorOpt "#E5E9F0";
      nord6  = mkColorOpt "#ECEFF4";
      nord7  = mkColorOpt "#8FBCBB"; nord8  = mkColorOpt "#88C0D0";
      nord9  = mkColorOpt "#81A1C1"; nord10 = mkColorOpt "#5E81AC";
      nord11 = mkColorOpt "#BF616A"; nord12 = mkColorOpt "#D08770";
      nord13 = mkColorOpt "#EBCB8B"; nord14 = mkColorOpt "#A3BE8C";
      nord15 = mkColorOpt "#B48EAD";

      background    = mkColorOpt "#2E3440";
      backgroundAlt = mkColorOpt "#3B4252";
      surface       = mkColorOpt "#434C5E";
      border        = mkColorOpt "#4C566A";
      textDim       = mkColorOpt "#D8DEE9";
      text          = mkColorOpt "#E5E9F0";
      textBright    = mkColorOpt "#ECEFF4";
      accent        = mkColorOpt "#88C0D0";
      accentBlue    = mkColorOpt "#81A1C1";
      accentDark    = mkColorOpt "#5E81AC";
      urgent        = mkColorOpt "#BF616A";
      warning       = mkColorOpt "#EBCB8B";
      success       = mkColorOpt "#A3BE8C";

      backgroundRgb    = mkColorOpt "46, 52, 64";
      backgroundAltRgb = mkColorOpt "59, 66, 82";
      borderRgb        = mkColorOpt "76, 86, 106";
      accentRgb        = mkColorOpt "136, 192, 208";
      textDimRgb       = mkColorOpt "216, 222, 233";
      urgentRgb        = mkColorOpt "191, 97, 106";
    };

    font = {
      name   = mkStrOpt "JetBrainsMono Nerd Font";
      size   = mkStrOpt "0.9rem";
      weight = mkIntOpt 600;
    };

    gtk = {
      themeName        = mkStrOpt "Nordic";
      themePackage     = mkStrOpt "nordic";
      iconThemeName    = mkStrOpt "Papirus-Dark";
      iconThemePackage = mkStrOpt "papirus-icon-theme";
      cursorName       = mkStrOpt "Bibata-Modern-Classic";
      cursorPackage    = mkStrOpt "bibata-cursors";
      cursorSize       = mkIntOpt 20;
    };
  };

  config = {
    theme.colors = lib.mapAttrs (_: v: lib.mkDefault v) preset.colors;
    theme.font   = lib.mapAttrs (_: v: lib.mkDefault v) preset.font;
    theme.gtk    = lib.mapAttrs (_: v: lib.mkDefault v) preset.gtk;
  };
}
