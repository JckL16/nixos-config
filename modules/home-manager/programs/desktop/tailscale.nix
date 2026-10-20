{ lib, config, ... }: {

  options = {
    tailscale.enable = lib.mkEnableOption "Autostart the Trayscale tray icon on login";
  };

  config = lib.mkIf config.tailscale.enable {
    xdg.configFile."autostart/trayscale.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Trayscale
      Exec=trayscale --hide-window
      Icon=dev.deedles.Trayscale
      Terminal=false
      X-GNOME-Autostart-enabled=true
    '';
  };

}
