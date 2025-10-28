# modules/nixos/boot/grub-themes/nordic-theme.nix
{ pkgs, lib, config, ... }:

let
  cfg = config.grub.nordic-theme;
  
  # Get the wallpaper path
  wallpaperSrc = 
    if (cfg.wallpaperPath != null) then
      cfg.wallpaperPath
    else if cfg.useWallpaper then
      ../../../../wallpaper/wallpaper.png
    else
      null;

  # Create the Nordic GRUB theme
  nordicTheme = pkgs.stdenv.mkDerivation {
    pname = "grub2-theme-nordic";
    version = "1.0.0";

    src = pkgs.runCommand "nordic-grub-theme-src" {} ''
      mkdir -p $out
    '';

    nativeBuildInputs = [ pkgs.imagemagick ];

    buildPhase = ''
      mkdir -p theme
      
      ${if wallpaperSrc != null then ''
        # Copy and resize the wallpaper to match resolution
        ${pkgs.imagemagick}/bin/convert "${wallpaperSrc}" \
          -resize ${cfg.resolution}^ \
          -gravity center \
          -extent ${cfg.resolution} \
          -type TrueColor \
          -define png:bit-depth=8 \
          -define png:color-type=2 \
          PNG24:theme/background.png
      '' else ''
        # Create a solid Nordic background
        ${pkgs.imagemagick}/bin/convert \
          -size ${cfg.resolution} \
          "xc:rgb(46,52,64)" \
          -type TrueColor \
          -define png:bit-depth=8 \
          -define png:color-type=2 \
          PNG24:theme/background.png
      ''}
      
      # Create the menu background panel with rounded corners
      ${pkgs.imagemagick}/bin/convert \
        -size 1150x650 \
        "xc:rgba(59,66,82,0.95)" \
        \( +clone -alpha extract \
           -draw 'fill black polygon 0,0 0,8 8,0 fill white circle 8,8 8,0' \
           \( +clone -flip \) -compose Multiply -composite \
           \( +clone -flop \) -compose Multiply -composite \
        \) -alpha off -compose CopyOpacity -composite \
        -type TrueColorAlpha \
        -define png:bit-depth=8 \
        -define png:color-type=6 \
        PNG32:theme/menu_bg.png
      
      # Create selection highlight - subtle background like window module hover
      # Using a slightly darker shade with rounded corners
      ${pkgs.imagemagick}/bin/convert \
        -size 1080x40 \
        "xc:rgba(67,76,94,0.95)" \
        \( +clone -alpha extract \
           -draw 'fill black polygon 0,0 0,8 8,0 fill white circle 8,8 8,0' \
           \( +clone -flip \) -compose Multiply -composite \
           \( +clone -flop \) -compose Multiply -composite \
        \) -alpha off -compose CopyOpacity -composite \
        -type TrueColorAlpha \
        -define png:bit-depth=8 \
        -define png:color-type=6 \
        PNG32:theme/select_c.png
    '';

    installPhase = ''
      mkdir -p $out
      cp -r theme/* $out/
      
      # Create theme.txt with Nordic styling
      cat > $out/theme.txt <<'EOFTHEME'
# Nordic GRUB Theme
# Inspired by Nord color palette

# General settings
title-text: ""
desktop-image: "background.png"
desktop-color: "46, 52, 64"
terminal-font: "Unifont Regular 16"

# Boot menu
+ boot_menu {
  left = 18%
  top = 25%
  width = 64%
  height = 45%
  item_font = "Unifont Regular 16"
  item_color = "216, 222, 233"
  selected_item_color = "136, 192, 208"
  item_height = 40
  item_padding = 15
  item_spacing = 8
  selected_item_pixmap_style = "select_*.png"
  icon_width = 32
  icon_height = 32
  item_icon_space = 15
}

# Menu background panel
+ image {
  left = 15%
  top = 20%
  width = 70%
  height = 60%
  file = "menu_bg.png"
}

# Countdown/Progress bar
+ progress_bar {
  id = "__timeout__"
  left = 18%
  top = 73%
  height = 30
  width = 64%
  font = "Unifont Regular 14"
  text_color = "216, 222, 233"
  fg_color = "136, 192, 208"
  bg_color = "59, 66, 82"
  border_color = "67, 76, 94"
  text = "@TIMEOUT_NOTIFICATION_LONG@"
}

# Footer text
+ label {
  top = 85%
  left = 0
  width = 100%
  height = 20
  text = "Nordic Theme"
  color = "129, 161, 193"
  align = "center"
  font = "Unifont Regular 12"
}
EOFTHEME
    '';

    meta = with lib; {
      description = "Nordic GRUB theme matching the Nordic desktop theme";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };

in {
  options = {
    grub.nordic-theme = {
      enable = lib.mkEnableOption "Enable Nordic GRUB theme";

      resolution = lib.mkOption {
        type = lib.types.str;
        default = "1920x1080";
        description = "Screen resolution for GRUB";
        example = "2560x1440";
      };

      useWallpaper = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use the same wallpaper as your desktop (from wallpaper/wallpaper.png)";
      };

      wallpaperPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Custom path to wallpaper (overrides useWallpaper)";
        example = lib.literalExpression "./custom-wallpaper.png";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader.grub = {
      # Set the Nordic theme
      theme = nordicTheme;
      
      # Set GRUB resolution
      gfxmodeEfi = cfg.resolution;
      gfxmodeBios = cfg.resolution;
      
      # Don't use splashImage as it conflicts with theme
      splashImage = null;
      
      # Additional GRUB configuration
      extraConfig = ''
        # Enable graphical terminal
        terminal_output gfxterm
        
        # Set graphics mode
        set gfxmode=${cfg.resolution}
        insmod all_video
        insmod gfxterm
        insmod png
      '';
    };

    # Ensure necessary packages are available
    environment.systemPackages = with pkgs; [
      imagemagick
    ];
  };
}
