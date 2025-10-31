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
            efiSupport = !variables.isBIOS;
            useOSProber = true;
            configurationLimit = 5;
        };
        efi.canTouchEfiVariables = !variables.isBIOS;
        timeout = 5;
    };
  };
  
}
