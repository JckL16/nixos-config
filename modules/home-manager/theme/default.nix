# modules/home-manager/theme/default.nix
#
# Theme options — all color and font values used across CSS/style modules.
# Defaults are the Nord palette. To switch themes, override theme.colors.*
# and theme.font.* in your host home.nix or a dedicated theme file.
#
# Switching theme example (per-host in home.nix):
#   theme.colors.background    = "#1e1e2e";  # Catppuccin base
#   theme.colors.backgroundRgb = "30, 30, 46";
#   # ... etc.

{ lib, ... }:
let
  mkColorOpt = default: lib.mkOption { type = lib.types.str; inherit default; };
in {
  options.theme = {

    colors = {
      # ── Polar Night (dark backgrounds) ─────────────────────────────────────
      nord0  = mkColorOpt "#2E3440";
      nord1  = mkColorOpt "#3B4252";
      nord2  = mkColorOpt "#434C5E";
      nord3  = mkColorOpt "#4C566A";

      # ── Snow Storm (light text) ─────────────────────────────────────────────
      nord4  = mkColorOpt "#D8DEE9";
      nord5  = mkColorOpt "#E5E9F0";
      nord6  = mkColorOpt "#ECEFF4";

      # ── Frost (accent blues) ────────────────────────────────────────────────
      nord7  = mkColorOpt "#8FBCBB";
      nord8  = mkColorOpt "#88C0D0";
      nord9  = mkColorOpt "#81A1C1";
      nord10 = mkColorOpt "#5E81AC";

      # ── Aurora (semantic colors) ────────────────────────────────────────────
      nord11 = mkColorOpt "#BF616A";
      nord12 = mkColorOpt "#D08770";
      nord13 = mkColorOpt "#EBCB8B";
      nord14 = mkColorOpt "#A3BE8C";
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

      # ── RGB triplets — for rgba() in CSS (no alpha component) ──────────────
      # Usage: rgba(${c.backgroundRgb}, 0.85)
      backgroundRgb    = mkColorOpt "46, 52, 64";
      backgroundAltRgb = mkColorOpt "59, 66, 82";
      borderRgb        = mkColorOpt "76, 86, 106";
      accentRgb        = mkColorOpt "136, 192, 208";
      textDimRgb       = mkColorOpt "216, 222, 233";
      urgentRgb        = mkColorOpt "191, 97, 106";
    };

    font = {
      name   = lib.mkOption { type = lib.types.str; default = "JetBrainsMono Nerd Font"; };
      # Size used by HyprPanel (rem units); other UIs pick their own sizes.
      size   = lib.mkOption { type = lib.types.str; default = "0.9rem"; };
      weight = lib.mkOption { type = lib.types.int; default = 600; };
    };
  };
}
