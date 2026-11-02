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
            "SELECT ECacheOBJ, occur_start, occur_end FROM ECacheObjects;" \
            2>/dev/null) || new="[]"
          [ -n "$new" ] || new="[]"

          rows=$(jq -c -n --argjson existing "$rows" --argjson new "$new" --arg cal "$name" \
            '$existing + ($new | map(. + {calendar: $cal}))')
        done
      fi

      echo "$rows" | jq -c '
        def toLocal(d):
          d | strptime("%Y%m%d%H%M%S") | mktime | localtime | strftime("%Y-%m-%dT%H:%M");
        def subtractDay(d):
          (d | strptime("%Y-%m-%d") | mktime) - 86400 | strftime("%Y-%m-%d");
        def unescapeIcs:
          gsub("\\\\n"; " ") | gsub("\\\\,"; ",") | gsub("\\\\;"; ";");
        def icsField(obj; name):
          (((obj // "") | capture(name + "[^:\r\n]*:(?<v>[^\r\n]*)"; "i")) // {v:""}).v | unescapeIcs;
        def icsRawDate(obj; name):
          (((obj // "") | capture(name + "[^:\r\n]*:(?<v>[0-9]{8})(?!T)"; "i")) // {v:null}).v;
        [.[] |
          (icsField(.ECacheOBJ; "SUMMARY")) as $summary |
          select($summary != "") |
          (icsField(.ECacheOBJ; "LOCATION")) as $location |
          (.occur_start // "") as $occStart |
          (if ($occStart | length) >= 8 then
             {raw: $occStart, allDay: (($occStart | length) < 12)}
           else
             (icsRawDate(.ECacheOBJ; "DTSTART")) as $d |
             (if $d != null then {raw: $d, allDay: true} else null end)
           end) as $startInfo |
          select($startInfo != null) |
          ($startInfo.allDay) as $allDay |
          ($startInfo.raw) as $rawStart |
          (if $allDay then ($rawStart[0:4] + "-" + $rawStart[4:6] + "-" + $rawStart[6:8] + "T00:00") else toLocal($rawStart) end) as $start |
          (.occur_end // "") as $occEnd |
          (if ($occEnd | length) >= 8 then $occEnd
           elif $allDay then icsRawDate(.ECacheOBJ; "DTEND")
           else null
           end) as $rawEnd |
          (if $rawEnd == null then null
           elif ($rawEnd | length) >= 12 then toLocal($rawEnd)
           else ($rawEnd[0:4] + "-" + $rawEnd[4:6] + "-" + $rawEnd[6:8] + "T00:00")
           end) as $end |
          ($start[0:10]) as $startDate |
          (if $end == null then $startDate
           elif $allDay then subtractDay($end[0:10])
           else $end[0:10]
           end) as $endDateRaw |
          (if $endDateRaw < $startDate then $startDate else $endDateRaw end) as $endDate |
          {
            date: $startDate,
            endDate: $endDate,
            allDay: $allDay,
            time: (if $allDay then null else $start[11:16] end),
            endTime: (if $allDay then null elif $end != null then $end[11:16] else null end),
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
