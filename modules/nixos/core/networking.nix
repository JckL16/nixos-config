# modules/nixos/core/networking.nix

{ variables, ... }: {

  # Networking
  networking.networkmanager.enable = true;
  users.users."${variables.username}".extraGroups = [ "networkmanager" ];

}