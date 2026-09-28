{ pkgs, lib, config, ... }:

let
  c = config.theme.colors;
  hyprHex = hex: builtins.substring 1 6 hex;
in {

  config = lib.mkIf config.hyprland.enable {
    wayland.windowManager.hyprland = {
      plugins = [ pkgs.hyprlandPlugins.hyprspace ];

      settings = {
        # The plugin loads asynchronously via exec-once, so the "overview:toggle"
        # dispatcher doesn't exist yet when binds are first parsed at startup.
        # Reload once the plugin has had time to register itself.
        exec-once = [ "sleep 1 && hyprctl reload" ];

        bind = [ "$mod SHIFT, Tab, overview:toggle" ];

        "plugin:overview" = {
          panelColor = "rgba(${hyprHex c.background}dd)";
          panelBorderColor = "rgba(${hyprHex c.border}ee)";
          workspaceActiveBackground = "rgba(${hyprHex c.backgroundAlt}ff)";
          workspaceInactiveBackground = "rgba(${hyprHex c.backgroundAlt}aa)";
          workspaceActiveBorder = "rgba(${hyprHex c.accent}ff)";
          workspaceInactiveBorder = "rgba(${hyprHex c.border}aa)";
          centerAligned = true;
        };
      };
    };
  };
}
