# modules/nixos/core/swap-file.nix

{ pkgs, lib, config, ... }: {
  options = {
    swap-file = {
      enable = lib.mkEnableOption "Enable swap file";
      
      size = lib.mkOption {
        type = lib.types.int;
        default = 16 * 1024;
        description = "Size of the swap file in MiB";
        example = 8192;
      };
    };
  };
  
  config = lib.mkIf config.swap-file.enable {
    swapDevices = [{
      device = "/var/lib/swapfile";
      size = config.swap-file.size;
    }];
  };
}