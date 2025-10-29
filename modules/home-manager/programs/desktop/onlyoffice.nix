# modules/home-manager/programs/onlyoffice.nix

{ pkgs, lib, config, ... }: {
  options = {
    onlyoffice.enable =
      lib.mkEnableOption "Enable the OnlyOffice desktop editors";
  };
  
  config = lib.mkIf config.onlyoffice.enable {
    home.packages = with pkgs; [
      onlyoffice-bin
    ];
  };
}