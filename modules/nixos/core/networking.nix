{ variables, ... }: {

  networking.networkmanager.enable = true;
  users.users."${variables.username}".extraGroups = [ "networkmanager" ];

  systemd.services.NetworkManager-wait-online.enable = false;

}
