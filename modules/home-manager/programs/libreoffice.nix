# modules/home-manager/libreoffice.nix

{ pkgs, lib, config, variables, ... }: {

  options = {
    libreoffice.enable = 
      lib.mkEnableOption "Enable the libreoffice suite";
  };

  config = lib.mkIf config.libreoffice.enable {
    home.packages = with pkgs; [
      libreoffice-fresh
      hunspell
      hunspellDicts.en_US
      hunspellDicts.sv_SE
      languagetool  # Grammar and style checker
    ];
  };
  
}