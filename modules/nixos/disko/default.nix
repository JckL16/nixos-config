# modules/nixos/disko/default.nix
# Shared disko configuration module for all hosts
{ lib, config, variables, ... }:

{
  options.diskoConfig = {
    enable = lib.mkEnableOption "Enable disko disk configuration";

    device = lib.mkOption {
      type = lib.types.str;
      description = "The disk device to use (e.g., /dev/nvme0n1, /dev/sda)";
      example = "/dev/nvme0n1";
    };

    encryption = {
      enable = lib.mkEnableOption "Enable LUKS encryption";

      luksName = lib.mkOption {
        type = lib.types.str;
        default = "cryptroot";
        description = "Name for the LUKS device";
      };
    };

    swapSize = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Size of swap partition (e.g., '8G'). Set to null for no swap.";
      example = "8G";
    };
  };

  config = lib.mkIf config.diskoConfig.enable (lib.mkMerge [
    # Enable GRUB cryptodisk support when encryption is enabled
    (lib.mkIf config.diskoConfig.encryption.enable {
      boot.loader.grub.enableCryptodisk = true;
    })

    # BIOS bootloader config
    (lib.mkIf variables.isBIOS {
      boot.loader.grub.devices = lib.mkForce [ config.diskoConfig.device ];
      boot.loader.grub.efiSupport = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
    })

    # UEFI bootloader config
    (lib.mkIf (!variables.isBIOS) {
      boot.loader.grub.device = lib.mkForce "nodev";
      boot.loader.grub.efiSupport = lib.mkForce true;
      boot.loader.efi.canTouchEfiVariables = lib.mkForce true;
      boot.loader.grub.mirroredBoots = lib.mkForce [{
        devices = [ "nodev" ];
        path = "/boot";
      }];
    })

    # Disko devices config
    {
    disko.devices = {
      disk.main = {
        type = "disk";
        device = config.diskoConfig.device;
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition (only for BIOS systems)
            boot = lib.mkIf variables.isBIOS {
              size = "1M";
              type = "EF02"; # BIOS boot partition
            };

            # EFI System Partition (only for UEFI systems)
            ESP = lib.mkIf (!variables.isBIOS) {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0022" "dmask=0022" ];
              };
            };

            # Swap partition (optional)
            swap = lib.mkIf (config.diskoConfig.swapSize != null) {
              size = config.diskoConfig.swapSize;
              content = {
                type = "swap";
                randomEncryption = config.diskoConfig.encryption.enable;
              };
            };

            # Root partition - with or without LUKS
            root = {
              size = "100%";
              content =
                if config.diskoConfig.encryption.enable then {
                  type = "luks";
                  name = config.diskoConfig.encryption.luksName;
                  passwordFile = "/tmp/secret.key";
                  extraFormatArgs = [ "--pbkdf" "pbkdf2" ];
                  extraOpenArgs = [ "--allow-discards" ];
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                } else {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
            };
          };
        };
      };
    };
    }
  ]);
}
