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
            useOSProber = true;
            configurationLimit = 5;
        } // lib.optionalAttrs (!config.diskoConfig.enable) {
            # Only set these if disko is NOT enabled (disko handles bootloader config)
            device = variables.bootDevice;
            efiSupport = !variables.isBIOS;
        };
        timeout = 5;
    } // lib.optionalAttrs (!config.diskoConfig.enable) {
        efi.canTouchEfiVariables = !variables.isBIOS;
    };
  };

}
