# modules/home-manager/programs/gamemode.nix

{ pkgs, lib, config, ... }: {
  options = {
    gamemode.enable = 
      lib.mkEnableOption "Enable GameMode home-manager configuration";
  };
  
  config = lib.mkIf config.gamemode.enable {
    # GameMode package
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
    
    # Environment variables
    home.sessionVariables = {
      # Enable gamemode client library
      LD_PRELOAD = lib.mkDefault "${pkgs.gamemode}/lib/libgamemodeauto.so.0";
    };
    
    # Optional: Create a desktop entry for gamemode-enabled Steam
    xdg.desktopEntries = lib.mkIf config.steam.enable {
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