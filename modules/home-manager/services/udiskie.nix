# modules/home-manager/services/udiskie.nix

{ pkgs, ... }: {

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };
}