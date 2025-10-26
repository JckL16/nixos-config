# modules/nixos/bootloader/systemd-boot.nix

{ pkgs, lib, config, ... }: {
  
  options = {
    systemd-boot.enable = 
      lib.mkEnableOption "Enable systemd-boot";
  };

  config = lib.mkIf config.systemd-boot.enable {
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    boot.loader.efi.canTouchEfiVariables = true;
  };
  
}