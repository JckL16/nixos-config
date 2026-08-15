# modules/home-manager/theme/default.nix
#
# Theme module — declares options and applies the preset selected by variables.theme.
#
# Switch themes by changing variables.theme in variables.nix:
#   theme = "gruvbox";   # "nord" | "gruvbox" | "dracula" | "tokyo-night"
#
# All options support per-host overrides:
#   theme.colors.accent = "#ff0000";   # overrides just the accent color

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
      # ── Polar Night palette slots ───────────────────────────────────────────
      nord0  = mkColorOpt "#2E3440"; nord1  = mkColorOpt "#3B4252";
      nord2  = mkColorOpt "#434C5E"; nord3  = mkColorOpt "#4C566A";
      # ── Snow Storm ─────────────────────────────────────────────────────────
      nord4  = mkColorOpt "#D8DEE9"; nord5  = mkColorOpt "#E5E9F0";
      nord6  = mkColorOpt "#ECEFF4";
      # ── Frost ──────────────────────────────────────────────────────────────
      nord7  = mkColorOpt "#8FBCBB"; nord8  = mkColorOpt "#88C0D0";
      nord9  = mkColorOpt "#81A1C1"; nord10 = mkColorOpt "#5E81AC";
      # ── Aurora ─────────────────────────────────────────────────────────────
      nord11 = mkColorOpt "#BF616A"; nord12 = mkColorOpt "#D08770";
      nord13 = mkColorOpt "#EBCB8B"; nord14 = mkColorOpt "#A3BE8C";
      nord15 = mkColorOpt "#B48EAD";

      # ── Semantic aliases ────────────────────────────────────────────────────
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

      # ── RGB triplets for rgba() in CSS ──────────────────────────────────────
      # Usage: rgba(${config.theme.colors.backgroundRgb}, 0.85)
      backgroundRgb    = mkColorOpt "46, 52, 64";
      backgroundAltRgb = mkColorOpt "59, 66, 82";
      borderRgb        = mkColorOpt "76, 86, 106";
      accentRgb        = mkColorOpt "136, 192, 208";
      textDimRgb       = mkColorOpt "216, 222, 233";
      urgentRgb        = mkColorOpt "191, 97, 106";
    };

    font = {
      name   = mkStrOpt "JetBrainsMono Nerd Font";
      # Size for HyprPanel (rem); other UIs use their own sizes.
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

  # Apply the selected preset as mkDefault so hosts can still override.
  config = {
    theme.colors = lib.mapAttrs (_: v: lib.mkDefault v) preset.colors;
    theme.font   = lib.mapAttrs (_: v: lib.mkDefault v) preset.font;
    theme.gtk    = lib.mapAttrs (_: v: lib.mkDefault v) preset.gtk;
  };
}
