# modules/home-manager/desktop/hyprland/clipman.nix
# cliphist — Wayland clipboard history daemon.
# Captures everything written via wl-copy (apps, screenshots, etc.).
# Picker: cliphist list | walker --dmenu | cliphist decode | wl-copy

{ pkgs, lib, config, ... }: {
  config = lib.mkIf config.hyprland.enable {
    home.packages = with pkgs; [ cliphist ];

    # Capture clipboard events via wl-paste --watch, store in cliphist.
    # wl-clipboard is already in home.packages from hyprland.nix.
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

    # Clipboard picker: list history, pick with walker dmenu, decode and copy.
    home.file.".config/walker/clipboard.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # cliphist list: "ID\tpreview" — awk reverses to "preview\tID"
        # so walker -l 0 shows preview as label, -V 1 returns ID (same pattern as windows.sh)
        id=$(cliphist list | awk 'BEGIN{FS=OFS="\t"} {print $2, $1}' \
          | walker --dmenu -p 'Paste' -t $'\t' -l 0 -V 1)
        [ -n "$id" ] && cliphist list | grep -Pm1 "^$id\t" | cliphist decode | wl-copy
      '';
    };
  };
}
