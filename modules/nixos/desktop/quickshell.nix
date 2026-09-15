{ config, lib, ... }: {
  config = lib.mkIf config.hyprland.enable {
    services.gnome.evolution-data-server.enable = true;
  };
}
