# modules/home-manager/git.nix

{ pkgs, lib, config, variables, ... }: {

  options = {
    git.enable = 
      lib.mkEnableOption "Enable git";
  };

  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;
      userName = variables.gitUsername;
      userEmail = variables.gitEmail;
    };
  };
  
}