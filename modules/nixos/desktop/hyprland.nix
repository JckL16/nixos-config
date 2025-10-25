# modules/nixos/desktop/hyprland.nix

{ pkgs, lib, config, ... }: {
  options = {
    hyprland.enable = lib.mkEnableOption "Enable hyprland window manager";
  };
  config = lib.mkIf config.hyprland.enable {
    services.printing.enable = true;
    
    security.polkit.enable = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };  

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZON_WL = "1";
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
      wayland
      kitty
      waybar
      rofi
    ];
    
    services.udisks2.enable = true;
  };
}
