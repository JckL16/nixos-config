# modules/nixos/programs/steam.nix

{ pkgs, lib, config, ... }: {
  options = {
    steam.enable = 
      lib.mkEnableOption "Enable Steam system configuration";
  };
  
  config = lib.mkIf config.steam.enable {
    programs.steam = {
      enable = true;
      
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      
      # Conditionally add gamemode if enabled
      package = if config.gamemode.enable then
        pkgs.steam.override {
          extraPkgs = pkgs: with pkgs; [
            gamemode
          ];
        }
      else
        pkgs.steam;
    };
  };
}