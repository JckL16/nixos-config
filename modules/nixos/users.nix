# modules/nixos/users.nix

{ pkgs, variables, ... }: {

  users.users."${variables.username}" = {
    isNormalUser = true;
    description = variables.description;
    extraGroups = [ "networkmanager" "wheel" "input" "video" "render" "gamemode" "docker" "libvirtd" ];
    packages = [];
    shell = pkgs.zsh;
  };

}
