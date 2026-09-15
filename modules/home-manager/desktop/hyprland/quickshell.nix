{ pkgs, lib, config, ... }:

let
  c = config.theme.colors;
  f = config.theme.font;

  qsColors = pkgs.writeText "quickshell-bar-colors.json" (builtins.toJSON {
    base      = c.background;
    mantle    = c.backgroundAlt;
    crust     = c.backgroundAlt;
    surface0  = c.backgroundAlt;
    surface1  = c.surface;
    surface2  = c.border;
    overlay0  = c.border;
    overlay1  = c.textDim;
    overlay2  = c.textDim;
    text      = c.textBright;
    subtext0  = c.text;
    subtext1  = c.text;
    blue      = c.accentBlue;
    sapphire  = c.accent;
    peach     = c.warning;
    green     = c.success;
    red       = c.urgent;
    mauve     = c.accent;
    pink      = c.accent;
    yellow    = c.warning;
    maroon    = c.urgent;
    teal      = c.accentBlue;
  });

  qsSettings = pkgs.writeText "quickshell-bar-settings.json" (builtins.toJSON {
    theme = {
      matugen = false;
      fontFamily = f.name;
    };
  });

  edsCalendarEvents = pkgs.writeShellApplication {
    name = "eds-calendar-events";
    runtimeInputs = [ pkgs.sqlite pkgs.jq pkgs.gnugrep pkgs.coreutils ];
    text = ''
      sourcesDir="$HOME/.config/evolution/sources"
      cacheDir="$HOME/.cache/evolution/calendar"

      rows="[]"
      if [ -d "$sourcesDir" ]; then
        for f in "$sourcesDir"/*.source; do
          [ -f "$f" ] || continue
          grep -q "^\[Calendar\]" "$f" || continue
          grep -q "^Enabled=true" "$f" || continue

          id=$(basename "$f" .source)
          dbFile="$cacheDir/$id/cache.db"
          [ -f "$dbFile" ] || continue

          name=$(grep "^DisplayName=" "$f" | head -1 | cut -d= -f2-)
          [ -n "$name" ] || name="$id"

          new=$(sqlite3 -json "$dbFile" \
            "SELECT ECacheOBJ, occur_start, occur_end FROM ECacheObjects WHERE length(occur_start) >= 8;" \
            2>/dev/null) || new="[]"
          [ -n "$new" ] || new="[]"

          rows=$(jq -c -n --argjson existing "$rows" --argjson new "$new" --arg cal "$name" \
            '$existing + ($new | map(. + {calendar: $cal}))')
        done
      fi

      echo "$rows" | jq -c '
        def toLocal(d):
          d | strptime("%Y%m%d%H%M%S") | mktime | localtime | strftime("%Y-%m-%dT%H:%M");
        def unescapeIcs:
          gsub("\\\\n"; " ") | gsub("\\\\,"; ",") | gsub("\\\\;"; ";");
        def icsField(obj; name):
          (((obj // "") | capture(name + "[^:\r\n]*:(?<v>[^\r\n]*)"; "i")) // {v:""}).v | unescapeIcs;
        [.[] |
          (icsField(.ECacheOBJ; "SUMMARY")) as $summary |
          select($summary != "" and (.occur_start // "") != "") |
          (icsField(.ECacheOBJ; "LOCATION")) as $location |
          (if (.occur_start | length) >= 12 then toLocal(.occur_start) else (.occur_start[0:4] + "-" + .occur_start[4:6] + "-" + .occur_start[6:8] + "T00:00") end) as $start |
          ((.occur_end // "") | if length >= 12 then toLocal(.) else null end) as $end |
          {
            date: $start[0:10],
            time: (if (.occur_start | length) >= 12 then $start[11:16] else null end),
            endTime: (if $end != null then $end[11:16] else null end),
            location: $location,
            calendar: .calendar,
            summary: $summary
          }
        ]' \
        || echo "[]"
    '';
  };
in
{
  config = lib.mkIf config.hyprland.enable {
    programs.quickshell = {
      enable = true;
      configs.quickshell = ./quickshell;
      activeConfig = "quickshell";
      systemd.enable = true;
    };

    xdg.configFile."serpantinum/settings.json".source = qsSettings;
    home.file.".local/state/serpantinum/qs_colors.json".source = qsColors;

    home.packages = [ pkgs.wiremix pkgs.bluetui pkgs.gnome-calendar edsCalendarEvents ];
  };
}
