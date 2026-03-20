# modules/nixos/core/garbage-collection.nix

{ pkgs, lib, config, ... }: {
  options = {
    garbage-collection.enable =
      lib.mkEnableOption "Enable garbage collection" // { default = true; };
  };

  config = lib.mkIf config.garbage-collection.enable {
    # Automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Automatic store optimization (deduplication)
    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
}