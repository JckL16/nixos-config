# modules/nixos/users.nix

{ pkgs, variables, ... }: {

  users.users."${variables.username}" = {
    isNormalUser = true;
    description = variables.description;
    extraGroups = [ "wheel" ];
    packages = [];
    shell = pkgs.zsh;
  };

}
