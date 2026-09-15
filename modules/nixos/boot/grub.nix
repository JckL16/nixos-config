{ pkgs, lib, config, variables, ... }: {

  options = {
    grub.enable =
      lib.mkEnableOption "Enable grub";
  };

  config = lib.mkIf config.grub.enable (lib.mkMerge [

    {
      boot.loader = {
        grub = {
          enable = true;
          useOSProber = true;
          configurationLimit = lib.mkDefault 5;
        };
        timeout = 5;
      };
    }

    (lib.mkIf (!config.diskoConfig.enable) (
      if variables.isBIOS then {

        boot.loader.grub.devices = [ variables.bootDevice ];
        boot.loader.grub.efiSupport = false;
      } else {

        boot.loader.grub.device = "nodev";
        boot.loader.grub.efiSupport = true;
        boot.loader.grub.mirroredBoots = [{
          devices = [ "nodev" ];
          path = "/boot";
        }];
        boot.loader.efi.canTouchEfiVariables = true;
      }
    ))
  ]);

}
