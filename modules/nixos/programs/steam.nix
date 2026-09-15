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