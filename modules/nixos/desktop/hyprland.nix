{ pkgs, lib, config, variables, ... }: {
  options = {
    hyprland.enable = lib.mkEnableOption "Enable hyprland window manager";
  };
  config = lib.mkIf config.hyprland.enable {

    greetd.enable = lib.mkDefault true;

    security.polkit.enable = true;
    security.pam.services.hyprlock = {};

    services.logind.settings.Login.HandleLidSwitch = "ignore";

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };  

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
    
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
    
    environment.systemPackages = with pkgs; [
      wayland
      kitty
      wl-clipboard
    ];
    
    services.udisks2.enable = true;

    services.upower = {
      enable = true;
      usePercentageForPolicy = true;
    };
    users.users."${variables.username}".extraGroups = [ "input" "video" "render" ];
  };
}
