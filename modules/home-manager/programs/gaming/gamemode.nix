# modules/home-manager/programs/gamemode.nix
{ pkgs, lib, config, ... }: {
  options = {
    gamemode.enable = 
      lib.mkEnableOption "Enable GameMode home-manager configuration";
  };
  
  config = lib.mkIf config.gamemode.enable {
    # OBSERVE: For this module to work with steam you also have to specify the games to run with gamemoderun
    # you can do this by adding "gamemoderun %command%" to the launch command for each game.
    # Right click on the game, go to properties, then set launch options.

    # GameMode client package
    home.packages = with pkgs; [
      gamemode
    ];
    
    # Shell aliases for GameMode
    home.shellAliases = {
      # Launch applications with gamemode
      gm = "gamemoderun";
      
      # Check gamemode status
      gamemode-status = "gamemoded --status";
      
      # Test gamemode with a simple app
      gamemode-test = "gamemoderun vkcube";
    };
  };
}