{ pkgs, lib, config, ... }: {
  options = {
    sway.enable = lib.mkEnableOption "Enable sway window manager";
  };

  config = lib.mkIf config.sway.enable {
    # Printing support for Sway
    services.printing.enable = true;
    
    security.polkit.enable = true;

    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        rofi
        mako
        waybar
        swaybg
        grim
        slurp
        brightnessctl
        networkmanagerapplet
      ];
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services.displayManager.ly = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      rofi
      mako
      waybar
      swaybg
      swayfx
      grim
      slurp
      brightnessctl
      betterlockscreen
      networkmanagerapplet
      nerd-fonts.jetbrains-mono
      wayland
      wl-clipboard
    ];
  };
}