{ pkgs, lib, config, ... }: {
  options = {
    gamemode.enable = 
      lib.mkEnableOption "Enable GameMode home-manager configuration";
  };
  
  config = lib.mkIf config.gamemode.enable {

    home.packages = with pkgs; [
      gamemode
    ];
    

    home.shellAliases = {

      gm = "gamemoderun";
      

      gamemode-status = "gamemoded --status";
      

      gamemode-test = "gamemoderun vkcube";
    };
  };
}