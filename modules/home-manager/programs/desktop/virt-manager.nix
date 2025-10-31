# modules/home-manager/programs/desktop/virt-manager.nix

{ config, pkgs, lib, ... }:

{
  
  options = {
    virt-manager.enable =
      lib.mkEnableOption "Enable virt-manager and installs dependencies. OBS you have to enable virtualisation on the system level";
  };
  
  config = lib.mkIf config.virt-manager.enable {

    home.packages = with pkgs; [
      virt-manager
      virt-viewer
      spice 
      spice-gtk
      spice-protocol
      qemu
      win-virtio
      win-spice
    ];

    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
