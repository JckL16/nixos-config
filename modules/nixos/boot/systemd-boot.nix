# modules/nixos/bootloader/systemd-boot.nix

{ pkgs, lib, config, variables, ... }: {
  
  options = {
    systemd-boot.enable = 
      lib.mkEnableOption "Enable systemd-boot";
  };

  config = lib.mkIf config.systemd-boot.enable {
    assertions = [
      {
        assertion = !variables.isBIOS;
        message = "systemd-boot requires UEFI. Set isBIOS = false or use GRUB for BIOS systems.";
      }
    ];

    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
  };
  
}
