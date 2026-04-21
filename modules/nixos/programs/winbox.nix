# modules/nixos/programs/winbox.nix
{ pkgs, pkgs-unstable, lib, config, ... }:

{
  options = {
    winbox.enable = 
      lib.mkEnableOption "Enable Winbox (MikroTik configuration tool)";
  };
  
  config = lib.mkIf config.winbox.enable {
    # Makes sure that winbox can access mac services by opening the firewall
    programs.winbox = {
      enable = true;
      openFirewall = true;
      package = pkgs-unstable.winbox4;
    };
  };
}
