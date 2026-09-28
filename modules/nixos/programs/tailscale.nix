{ pkgs, lib, config, ... }:

let
  cfg = config.tailscale;
in
{
  options.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN client";

    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing a Tailscale auth key, created manually and
        never committed to git. If set, Tailscale connects automatically on
        boot instead of requiring `tailscale up` / login.
      '';
    };

    useRoutingFeatures = lib.mkOption {
      type = lib.types.enum [ "none" "client" "server" "both" ];
      default = "none";
      description = ''
        Enable subnet routing / exit node support. "client" allows using
        exit nodes/subnet routes advertised by others, "server" allows this
        host to advertise routes/act as an exit node, "both" enables both.
        Setting "server" or "both" also turns on IP forwarding.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the firewall for Tailscale.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      inherit (cfg) authKeyFile useRoutingFeatures openFirewall;
    };

    environment.systemPackages = [
      pkgs.trayscale
    ];
  };
}
