{ pkgs, lib, config, variables, ... }: {
  options = {
    wireshark.enable =
      lib.mkEnableOption "Enable Wireshark packet capture and add the main user to the wireshark group";
  };

  config = lib.mkIf config.wireshark.enable {
    programs.wireshark.enable = true;
    users.users."${variables.username}".extraGroups = [ "wireshark" ];
  };
}
