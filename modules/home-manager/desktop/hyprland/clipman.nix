{ pkgs, lib, config, ... }: {
  config = lib.mkIf config.hyprland.enable {
    home.packages = with pkgs; [ cliphist ];

    systemd.user.services.cliphist = {
      Unit = {
        Description = "Clipboard history daemon";
        After       = [ "hyprland-session.target" ];
        PartOf      = [ "hyprland-session.target" ];
      };
      Service = {
        Type      = "simple";
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart   = "on-failure";
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };
  };
}
