{ lib, config, ... }: {

  options = {
    syncthing.enable = lib.mkEnableOption "Enable Syncthing with a tray icon, autostarted on login";
  };

  config = lib.mkIf config.syncthing.enable {
    services.syncthing = {
      enable = true;
      tray = {
        enable = true;
        # Default command adds --wait, which appears to make syncthingtray
        # publish its tray icon in two phases (pre- and post-wait) that
        # Quickshell/HyprPanel's systray doesn't dedupe, showing 2 icons.
        command = "syncthingtray qt-widgets-gui --single-instance";
      };
    };
  };

}
