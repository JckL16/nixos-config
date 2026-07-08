# modules/home-manager/programs/command-line/neofetch.nix
# Migrated from neofetch (removed in nixpkgs 26.05) to fastfetch

{ pkgs, ... }:

{
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "display": {
        "separator": ": ",
        "color": {
          "keys": "cyan",
          "title": "cyan"
        }
      },
      "modules": [
        "title",
        "separator",
        {
          "type": "custom",
          "format": "┌─────────\n Hardware Information \n─────────┐"
        },
        { "type": "os",           "key": "   OS" },
        { "type": "host",         "key": "   Host" },
        { "type": "kernel",       "key": "   Kernel" },
        { "type": "uptime",       "key": "   Uptime" },
        { "type": "packages",     "key": "   Packages" },
        { "type": "shell",        "key": "   Shell" },
        { "type": "display",      "key": "   Resolution" },
        { "type": "de",           "key": "   DE" },
        { "type": "wm",           "key": "   WM" },
        { "type": "wmtheme",      "key": "   WM Theme" },
        { "type": "theme",        "key": "   Theme" },
        { "type": "icons",        "key": "   Icons" },
        { "type": "terminal",     "key": "   Terminal" },
        { "type": "terminalfont", "key": "   Terminal Font" },
        { "type": "cpu",          "key": "   CPU" },
        { "type": "gpu",          "key": "   GPU" },
        {
          "type": "memory",
          "key": "   Memory",
          "format": "{used} / {total} ({percentage}%)"
        },
        {
          "type": "custom",
          "format": "└───────────────────────────────────┘"
        },
        "colors"
      ]
    }
  '';
}
