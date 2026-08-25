# modules/nixos/core/networking.nix

{ variables, ... }: {

  # Networking
  networking.networkmanager.enable = true;
  users.users."${variables.username}".extraGroups = [ "networkmanager" ];

  # NM-wait-online blocks boot for 5+ seconds waiting for a connection that
  # most services don't need. Services that genuinely require the network
  # declare After=network-online.target themselves.
  systemd.services.NetworkManager-wait-online.enable = false;

}
