
# modules/nixos/programs/docker.nix

{ pkgs, lib, config, variables, ... }: {
  options = {
    docker.enable = 
      lib.mkEnableOption "Enable docker and add the main user to the docker group";
  };
  
  config = lib.mkIf config.docker.enable {
    virtualisation.docker.enable = true;

    users.users."${variables.username}".extraGroups = [ "docker" ];
  };
}
