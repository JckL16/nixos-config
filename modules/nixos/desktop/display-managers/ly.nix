# modules/nixos/desktop/display-managers/ly.nix

{ lib, config, ... }: {
  options = {
    ly.enable = lib.mkEnableOption "Enable ly display manager";
  };

  config = lib.mkIf config.ly.enable {
    services.displayManager.ly = {
      enable = true;
    };
  };
}
