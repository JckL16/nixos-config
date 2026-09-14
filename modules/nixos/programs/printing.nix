# modules/nixos/programs/printing.nix

{ pkgs, lib, config, variables, ... }: {
  options = {
    printing.enable =
      lib.mkEnableOption "Enable printing support via CUPS with network printer discovery";
  };

  config = lib.mkIf config.printing.enable {
    services.printing.enable = true;

    # Discover network/shared printers over mDNS (e.g. AirPrint, IPP printers)
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    environment.systemPackages = [ pkgs.system-config-printer ];

    users.users."${variables.username}".extraGroups = [ "lp" ];
  };
}
