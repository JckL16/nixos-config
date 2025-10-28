# modules/home-manager/programs/gamemode.nix
{ pkgs, lib, config, ... }: {
  options = {
    gamemode.enable = 
      lib.mkEnableOption "Enable GameMode home-manager configuration";
  };
  
  config = lib.mkIf config.gamemode.enable {
    # GameMode client package
    home.packages = with pkgs; [
      gamemode
    ];
    
    # Shell aliases for GameMode
    home.shellAliases = {
      # Launch applications with gamemode
      gm = "gamemoderun";
      
      # Check gamemode status
      gamemode-status = "gamemoded -s";
      
      # Test gamemode with a simple app
      gamemode-test = "gamemoderun vkcube";
      
      # Launch common apps with gamemode
      steam-gm = "gamemoderun steam";
    };
    
    # Optional: Create a desktop entry for gamemode-enabled Steam
    xdg.desktopEntries = lib.mkIf (config.steam.enable or false) {
      steam-gamemode = {
        name = "Steam (GameMode)";
        comment = "Launch Steam with GameMode optimizations";
        icon = "steam";
        exec = "gamemoderun steam %U";
        categories = [ "Game" ];
        terminal = false;
      };
    };
  };
}