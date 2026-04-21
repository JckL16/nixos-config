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
            # Only set device if disko is NOT enabled (disko handles this)
            device = lib.mkIf (!config.diskoConfig.enable) variables.bootDevice;
            efiSupport = !variables.isBIOS;
            useOSProber = true;
            configurationLimit = 5;
        };
        efi.canTouchEfiVariables = !variables.isBIOS;
        timeout = 5;
    };
  };

}
