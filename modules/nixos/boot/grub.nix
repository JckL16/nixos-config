# modules/nixos/bootloader/grub.nix

{ pkgs, lib, config, variables, ... }: {

  options = {
    grub.enable =
      lib.mkEnableOption "Enable grub";
  };

  config = lib.mkIf config.grub.enable (lib.mkMerge [
    # Base GRUB config (always applied)
    {
      boot.loader = {
        grub = {
          enable = true;
          useOSProber = true;
          configurationLimit = 5;
        };
        timeout = 5;
      };
    }

    # Fallback config when disko is NOT enabled
    (lib.mkIf (!config.diskoConfig.enable) (
      if variables.isBIOS then {
        # BIOS: install GRUB to the disk
        boot.loader.grub.devices = [ variables.bootDevice ];
        boot.loader.grub.efiSupport = false;
      } else {
        # UEFI: use mirroredBoots for EFI installation
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
