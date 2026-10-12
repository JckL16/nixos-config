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

    # udisks2/udiskie hardcode /run/media/$USER as the removable-media mount base and
    # don't support a custom path directly — redirect it via symlink so auto-mounted
    # drives land under ~/mount alongside the SMB shares (see modules/nixos/programs/smb-mount.nix).
    systemd.tmpfiles.rules = [
      "d /home/${variables.username}/mount 0755 ${variables.username} users -"
      "d /home/${variables.username}/mount/media 0755 ${variables.username} users -"
      "L+ /run/media/${variables.username} - - - - /home/${variables.username}/mount/media"
    ];

    services.upower = {
      enable = true;
      usePercentageForPolicy = true;
    };
    users.users."${variables.username}".extraGroups = [ "input" "video" "render" ];
  };
}
