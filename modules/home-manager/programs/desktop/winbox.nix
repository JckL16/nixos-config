# modules/home-manager/programs/winbox.nix
{ pkgs, lib, config, ... }:

{
  options = {
    winbox.enable = 
      lib.mkEnableOption "Enable Winbox (MikroTik configuration tool)";
  };
  
  config = lib.mkIf config.winbox.enable {
    home.packages = with pkgs; [
      (pkgs.writeShellScriptBin "winbox" ''
        export QT_QPA_PLATFORM=xcb
        exec ${pkgs.winbox4}/bin/WinBox "$@"
      '')
    ];
    
    xdg.desktopEntries.winbox = {
      name = "Winbox";
      exec = "winbox";
      icon = "network-wired";
      comment = "MikroTik RouterOS Configuration Tool";
      categories = [ "Network" "System" ];
      terminal = false;
    };
  };
}
