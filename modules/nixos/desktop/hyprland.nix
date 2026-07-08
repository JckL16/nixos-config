# modules/nixos/desktop/hyprland.nix

{ pkgs, lib, config, variables, ... }: {
  options = {
    hyprland.enable = lib.mkEnableOption "Enable hyprland window manager";
  };
  config = lib.mkIf config.hyprland.enable {
    # Enable greetd display manager by default
    greetd.enable = lib.mkDefault true;

    services.printing.enable = true;

    security.polkit.enable = true;
    security.pam.services.hyprlock = {};

    # Let Hyprland handle lid switch instead of systemd
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

    # UPower — required for HyprPanel battery widget.
    # usePercentageForPolicy makes the DisplayDevice aggregate by averaging
    # individual battery percentages instead of summing raw energy values,
    # which fixes the >100% display on dual-battery systems.
    services.upower = {
      enable = true;
      usePercentageForPolicy = true;
    };
    users.users."${variables.username}".extraGroups = [ "input" "video" "render" ];
  };
}
