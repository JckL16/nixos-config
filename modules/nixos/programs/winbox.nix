{ pkgs, pkgs-unstable, lib, config, ... }:

{
  options = {
    winbox.enable = 
      lib.mkEnableOption "Enable Winbox (MikroTik configuration tool)";
  };
  
  config = lib.mkIf config.winbox.enable {

    programs.winbox = {
      enable = true;
      openFirewall = true;
      package = pkgs-unstable.winbox4;
    };
  };
}
