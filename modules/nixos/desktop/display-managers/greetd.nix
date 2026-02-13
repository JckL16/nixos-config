# modules/nixos/desktop/display-managers/greetd.nix

{ pkgs, lib, config, ... }:

let
  theme = builtins.concatStringsSep ";" [
    "border=#4C566A"
    "text=#D8DEE9"
    "prompt=#88C0D0"
    "time=#88C0D0"
    "action=#81A1C1"
    "button=#88C0D0"
    "container=#3B4252"
    "input=#D8DEE9"
  ];

  sessions = "${config.services.displayManager.sessionData.desktops}/share";

  tuigreetCmd = pkgs.writeShellScript "tuigreet-cmd" ''
    exec ${pkgs.tuigreet}/bin/tuigreet \
      --time \
      --remember \
      --remember-session \
      --asterisks \
      --sessions ${sessions}/wayland-sessions \
      --xsessions ${sessions}/xsessions \
      --theme '${theme}'
  '';
in
{
  options = {
    greetd.enable = lib.mkEnableOption "Enable greetd display manager with tuigreet";
  };

  config = lib.mkIf config.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreetCmd}";
          user = "greeter";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter -"
    ];
  };
}
