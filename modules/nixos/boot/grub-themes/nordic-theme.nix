# modules/nixos/boot/grub-themes/nordic-theme.nix
{ pkgs, lib, config, ... }:

let
  cfg = config.grub.nordic-theme;
  
  # Nordic color palette matching your sway.nix configuration
  nordicColors = {
    # Polar Night
    nord0 = "#2E3440";
    nord1 = "#3B4252";
    nord2 = "#434C5E";
    nord3 = "#4C566A";
    # Snow Storm
    nord4 = "#D8DEE9";
    nord5 = "#E5E9F0";
    nord6 = "#ECEFF4";
    # Frost
    nord7 = "#8FBCBB";
    nord8 = "#88C0D0";
    nord9 = "#81A1C1";
    nord10 = "#5E81AC";
    # Aurora
    nord11 = "#BF616A";
    nord12 = "#D08770";
    nord13 = "#EBCB8B";
    nord14 = "#A3BE8C";
    nord15 = "#B48EAD";
  };

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
      
      # Create a Nordic-colored gradient background
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 \
        -define gradient:angle=135 \
        gradient:"${nordicColors.nord0}"-"${nordicColors.nord3}" \
        theme/background.png
      
      # Create selection highlight boxes
      ${pkgs.imagemagick}/bin/convert -size 640x32 xc:"${nordicColors.nord10}" \
        -alpha set -channel A -evaluate set 40% \
        theme/select_c.png
      
      ${pkgs.imagemagick}/bin/convert -size 8x32 xc:"${nordicColors.nord10}" \
        -alpha set -channel A -evaluate set 40% \
        theme/select_e.png
      
      ${pkgs.imagemagick}/bin/convert -size 8x32 xc:"${nordicColors.nord10}" \
        -alpha set -channel A -evaluate set 40% \
        theme/select_w.png
    '';

    installPhase = ''
      mkdir -p $out
      cp -r theme/* $out/
      
      # Create theme.txt with Nordic styling
      cat > $out/theme.txt << 'EOF'
# Nordic GRUB Theme
# Inspired by Nord color palette

# General settings
title-text: ""
desktop-image: "background.png"
desktop-color: "${nordicColors.nord0}"
terminal-font: "JetBrainsMono Nerd Font Mono Regular 14"

# Boot menu
+ boot_menu {
  left = 20%
  top = 30%
  width = 60%
  height = 40%
  item_font = "JetBrainsMono Nerd Font Mono Regular 16"
  item_color = "${nordicColors.nord4}"
  selected_item_color = "${nordicColors.nord6}"
  item_height = 36
  item_padding = 12
  item_spacing = 8
  selected_item_pixmap_style = "select_*.png"
  icon_width = 32
  icon_height = 32
  item_icon_space = 12
}

# Countdown/Progress bar
+ progress_bar {
  id = "__timeout__"
  left = 20%
  top = 75%
  height = 28
  width = 60%
  font = "JetBrainsMono Nerd Font Mono Regular 14"
  text_color = "${nordicColors.nord4}"
  fg_color = "${nordicColors.nord8}"
  bg_color = "${nordicColors.nord2}"
  border_color = "${nordicColors.nord3}"
  text = "@TIMEOUT_NOTIFICATION_LONG@"
}

# Footer text
+ label {
  top = 90%
  left = 0
  width = 100%
  height = 20
  text = "Nordic Theme"
  color = "${nordicColors.nord9}"
  align = "center"
  font = "JetBrainsMono Nerd Font Mono Regular 12"
}
EOF
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
      
      # Use JetBrains Mono font to match your desktop
      font = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFont-Regular.ttf";
      fontSize = 14;
      
      # Additional GRUB configuration with Nordic colors
      extraConfig = ''
        # Enable graphical terminal
        terminal_output gfxterm
        
        # Set Nordic color scheme for text mode fallback
        set color_normal=${nordicColors.nord4}/${nordicColors.nord0}
        set color_highlight=${nordicColors.nord6}/${nordicColors.nord10}
        
        # Load graphics and theme
        if loadfont $font ; then
          set gfxmode=${cfg.resolution}
          insmod gfxterm
          insmod vbe
          insmod vga
          insmod videoinfo
          insmod png
        fi
        
        # Set menu colors matching Nordic theme
        set menu_color_normal=${nordicColors.nord4}/${nordicColors.nord0}
        set menu_color_highlight=${nordicColors.nord6}/${nordicColors.nord10}
      '';
      
      # Optional: use your desktop wallpaper
      splashImage = 
        if (cfg.wallpaperPath != null) then
          cfg.wallpaperPath
        else if cfg.useWallpaper then
          ../../../../../wallpaper/wallpaper.png
        else
          null;
    };

    # Ensure necessary fonts are available
    environment.systemPackages = with pkgs; [
      nerd-fonts.jetbrains-mono
      imagemagick
    ];
  };
}