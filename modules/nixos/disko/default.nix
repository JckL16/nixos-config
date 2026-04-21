# modules/nixos/disko/default.nix
# Shared disko configuration module for all hosts
{ lib, config, ... }:

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

    isBIOS = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use BIOS/MBR instead of UEFI/GPT";
    };
  };

  config = lib.mkIf config.diskoConfig.enable {
    # Configure bootloader based on BIOS vs UEFI
    boot.loader.grub = lib.mkIf config.diskoConfig.isBIOS {
      device = config.diskoConfig.device;
      mirroredBoots = lib.mkForce [];
    };

    disko.devices = {
      disk.main = {
        type = "disk";
        device = config.diskoConfig.device;
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition (only for BIOS systems)
            boot = lib.mkIf config.diskoConfig.isBIOS {
              size = "1M";
              type = "EF02"; # BIOS boot partition
            };

            # EFI System Partition (only for UEFI systems)
            ESP = lib.mkIf (!config.diskoConfig.isBIOS) {
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
                  askPassword = true;
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
  };
}
