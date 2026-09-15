{ pkgs, lib, config, ... }: {
  options = {
    garbage-collection.enable =
      lib.mkEnableOption "Enable garbage collection" // { default = true; };
  };

  config = lib.mkIf config.garbage-collection.enable {

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
}