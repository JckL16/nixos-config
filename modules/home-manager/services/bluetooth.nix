# modules/home-manager/services/bluetooth.nix

{ pkgs, lib, config, ... }: {

  # Only enable blueman-applet if sway is enabled
  config = lib.mkIf config.sway.enable {
    services.blueman-applet.enable = true;
  };

}
