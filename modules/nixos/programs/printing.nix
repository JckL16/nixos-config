{ pkgs, lib, config, variables, ... }: {
  options = {
    printing.enable =
      lib.mkEnableOption "Enable printing support via CUPS with network printer discovery";
  };

  config = lib.mkIf config.printing.enable {
    services.printing.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    environment.systemPackages = [ pkgs.system-config-printer ];

    users.users."${variables.username}".extraGroups = [ "lp" ];
  };
}
