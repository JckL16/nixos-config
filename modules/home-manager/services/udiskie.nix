# modules/home-manager/services/udiskie.nix

{ pkgs, ... }: {

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    # tray = "never" — udiskie's GTK tray is unreliable on Wayland (GTK assertion
    # failures cause Broken pipe crashes). Run headless; automount + libnotify
    # notifications (shown in HyprPanel's notification center) cover all use cases.
    tray = "never";
  };
}