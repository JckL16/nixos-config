# modules/nixos/bootloader/grub.nix

{ pkgs, lib, config, variables, ... }: {
  
  options = {
    grub.enable = 
      lib.mkEnableOption "Enable grub";
  };

  config = lib.mkIf config.grub.enable {
    boot.loader = {
        grub = {
            enable = true;
            device = variables.bootDevice;
            efiSupport = true;
            useOSProber = true;
        };
        efi.canTouchEfiVariables = true;
        timeout = 5;
    };
  };
  
}