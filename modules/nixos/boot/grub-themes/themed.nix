# modules/nixos/boot/grub-themes/themed.nix
#
# Unified GRUB theme builder — reads variables.theme and builds a matching
# GRUB theme from the same color presets used by home-manager.
# Replaces the old grub.nordic-theme module.
#
# Enable with:  grub.theme.enable = true;
# Resolution:   grub.theme.resolution = "2560x1440";  (default: "1920x1080")

{ pkgs, lib, config, variables, ... }:

let
  cfg     = config.grub.theme;
  presets = import ../../../home-manager/theme/presets.nix;
  preset  = presets.${variables.theme or "nord"};
  c       = preset.colors;

  # Strip leading # so ImageMagick and Hyprland get bare hex like "2E3440".
  hex = h: builtins.substring 1 6 h;

  grubTheme = pkgs.stdenv.mkDerivation {
    pname   = "grub2-theme-${variables.theme or "nord"}";
    version = "1.0.0";

    src = pkgs.runCommand "empty-src" {} "mkdir -p $out";

    nativeBuildInputs = [ pkgs.imagemagick ];

    buildPhase = ''
      mkdir -p theme

      # Background: radial gradient, lighter surface in centre fading to base bg
      ${pkgs.imagemagick}/bin/convert \
        -size ${cfg.resolution} \
        radial-gradient:"#${hex c.surface}"-"#${hex c.background}" \
        -type TrueColor \
        -define png:bit-depth=8 -define png:color-type=2 \
        PNG24:theme/background.png

      # Menu panel background (rounded rectangle)
      ${pkgs.imagemagick}/bin/convert \
        -size 1150x650 \
        "xc:#${hex c.backgroundAlt}" \
        \( +clone -alpha extract \
           -draw 'fill black polygon 0,0 0,8 8,0 fill white circle 8,8 8,0' \
           \( +clone -flip \) -compose Multiply -composite \
           \( +clone -flop \) -compose Multiply -composite \
        \) -alpha off -compose CopyOpacity -composite \
        -type TrueColorAlpha \
        -define png:bit-depth=8 -define png:color-type=6 \
        PNG32:theme/menu_bg.png

      # Selection highlight (rounded rectangle)
      ${pkgs.imagemagick}/bin/convert \
        -size 1080x40 \
        "xc:#${hex c.surface}" \
        \( +clone -alpha extract \
           -draw 'fill black polygon 0,0 0,8 8,0 fill white circle 8,8 8,0' \
           \( +clone -flip \) -compose Multiply -composite \
           \( +clone -flop \) -compose Multiply -composite \
        \) -alpha off -compose CopyOpacity -composite \
        -type TrueColorAlpha \
        -define png:bit-depth=8 -define png:color-type=6 \
        PNG32:theme/select_c.png
    '';

    installPhase = ''
      mkdir -p $out
      cp -r theme/* $out/

      cat > $out/theme.txt <<EOFTHEME
# GRUB theme — ${variables.theme or "nord"}
# Generated from the active theme preset in variables.nix

title-text: ""
desktop-image: "background.png"
desktop-color: "${c.backgroundRgb}"
terminal-font: "Unifont Regular 16"

+ boot_menu {
  left = 18%
  top = 25%
  width = 64%
  height = 45%
  item_font = "Unifont Regular 16"
  item_color = "${c.textDimRgb}"
  selected_item_color = "${c.accentRgb}"
  item_height = 40
  item_padding = 15
  item_spacing = 8
  selected_item_pixmap_style = "select_*.png"
  icon_width = 32
  icon_height = 32
  item_icon_space = 15
}

+ progress_bar {
  id = "__timeout__"
  left = 18%
  top = 73%
  height = 30
  width = 64%
  font = "Unifont Regular 14"
  text_color = "${c.textDimRgb}"
  fg_color = "${c.accentRgb}"
  bg_color = "${c.backgroundAltRgb}"
  border_color = "${c.borderRgb}"
  text = "@TIMEOUT_NOTIFICATION_LONG@"
}

+ image {
  left = 15%
  top = 20%
  width = 70%
  height = 60%
  file = "menu_bg.png"
}

+ label {
  top = 85%
  left = 0
  width = 100%
  height = 20
  text = "${variables.theme or "nord"}"
  color = "${c.textDimRgb}"
  align = "center"
  font = "Unifont Regular 12"
}
EOFTHEME
    '';

    meta = with lib; {
      description = "GRUB theme matching the ${variables.theme or "nord"} desktop theme";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };

in {
  options.grub.theme = {
    enable = lib.mkEnableOption "Enable themed GRUB boot menu";

    resolution = lib.mkOption {
      type    = lib.types.str;
      default = "1920x1080";
      example = "2560x1440";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader.grub = {
      theme        = grubTheme;
      gfxmodeEfi   = cfg.resolution;
      gfxmodeBios  = cfg.resolution;
      splashImage  = null;
      extraConfig  = ''
        terminal_output gfxterm
        set gfxmode=${cfg.resolution}
        insmod all_video
        insmod gfxterm
        insmod png
      '';
    };

    environment.systemPackages = [ pkgs.imagemagick ];
  };
}
