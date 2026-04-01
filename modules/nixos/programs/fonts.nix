# modules/nixos/programs/fonts.nix

{ pkgs, lib, config, ... }: {

  options = {
    fonts-config.enable =
      lib.mkEnableOption "Enable common system fonts for browsers and applications";
  };

  config = lib.mkIf config.fonts-config.enable {
    fonts.fontDir.enable = true;
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "DejaVu Serif" ];
        sansSerif = [ "Inter" "Noto Sans" "DejaVu Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "DejaVu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
      subpixel.rgba = "rgb";
    };

    # X11 font path for XWayland (needed for legacy apps like Zoom)
    environment.systemPackages = [ pkgs.xorg.xset ];
    environment.sessionVariables = {
      XFONTSEL_FONT = "-*-helvetica-medium-r-*-*-14-*-*-*-*-*-*-*";
    };
    services.xserver.fontPath = "/run/current-system/sw/share/X11/fonts";

    fonts.packages = with pkgs; [
      # Web/UI fonts for browsers
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      liberation_ttf
      dejavu_fonts
      inter
      roboto
      source-sans
      source-serif
      font-awesome
      # X11 fonts required by legacy apps (Zoom, etc.)
      xorg.fontmiscmisc
      xorg.fontadobe75dpi
      xorg.fontadobe100dpi
    ];
  };

}
