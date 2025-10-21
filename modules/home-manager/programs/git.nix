# modules/home-manager/programs/git.nix

{ pkgs, lib, config, variables, ... }: {

  options = {
    git.enable = 
      lib.mkEnableOption "Enable git";
  };

  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;
      settings.user = {
        name = variables.gitUsername;
        email = variables.gitEmail;
      };
    };
  };
  
}