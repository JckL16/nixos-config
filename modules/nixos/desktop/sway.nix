# modules/nixos/desktop/sway.nix

{ pkgs, lib, config, ... }: {
  options = {
    sway.enable = lib.mkEnableOption "Enable sway window manager";
  };
  config = lib.mkIf config.sway.enable {
    # Printing support for Sway
    services.printing.enable = true;
    
    security.polkit.enable = true;
    security.pam.services.swaylock = {};
    
    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      # These packages need system-level installation for proper integration
      extraPackages = with pkgs; [
        swaylock-effects  # Needs PAM integration
        swayidle
        wl-clipboard
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
    
    # Only system-critical packages
    environment.systemPackages = with pkgs; [
      wayland
      qalculate-gtk  # System calculator
    ];
    
    services.udisks2.enable = true;
  };
}
