# modules/home-manager/desktop/hyprland/hyprpanel.nix
#
# HyprPanel — AGS-based bar with animated popups, calendar, media controls,
# network manager UI, notification center, and audio mixer.
# Replaces Waybar and Mako.
#
# Config schema sourced from:
#   /nix/store/7h5rb2vvfg00i76vjw86jqc1d8icp3v2-source/src/configuration/

{ pkgs, lib, config, variables, ... }:

let
  c = config.theme.colors;
  f = config.theme.font;

  # modules.scss is loaded by HyprPanel after its main SCSS for user overrides.
  # Using pkgs.writeText + activation-script copy avoids the GLib ELOOP that
  # occurs when HyprPanel's readFile() follows multi-level nix-store symlinks.
  hyprpanelModulesScss = pkgs.writeText "hyprpanel-modules.scss" ''
    /* Systray popup menus are styled via gtk3.extraCss in gtk-theme.nix
       since they belong to external GTK apps, not HyprPanel itself. */

    /* Calendar: today marker as bottom border + no background.
       GTK3 box-shadow inset is unreliable; border-bottom is the safe way
       to get an underline that stays centred under the number. */
    .calendar-menu-widget:selected {
      background-color: transparent;
      border-bottom: 2px solid ${c.accent};
      color: ${c.accent};
      font-weight: bold;
      border-radius: 0;
    }

    /* Systray right-click popup menus.
       SNI tray menus render inside HyprPanel's own GTK context so
       modules.scss applies directly. */
    window.popup {
      background-color: transparent;
    }

    window.popup menu {
      background-color: rgba(${c.backgroundRgb}, 0.92);
      border-radius: 6px;
      border: 1px solid rgba(${c.borderRgb}, 0.5);
      padding: 4px;
      color: ${c.textBright};
      font-size: 12px;
    }

    window.popup menu menuitem {
      border-radius: 4px;
      padding: 5px 12px;
      color: ${c.textBright};
      font-size: 12px;
    }

    window.popup menu menuitem label {
      font-size: 12px;
    }

    window.popup menu menuitem:hover {
      background-color: rgba(${c.backgroundAltRgb}, 0.85);
    }

    window.popup menu menuitem:disabled {
      color: rgba(${c.textDimRgb}, 0.4);
    }

    window.popup menu separator {
      background-color: rgba(${c.borderRgb}, 0.4);
      min-height: 1px;
      margin: 3px 6px;
    }

    /* Bar modules: fixed minimum width so the bar does not shift when values
       change between narrow (e.g. "8G") and wide (e.g. "12.34G") text. */
    .module-label.cpu {
      min-width: 2.8em;
    }

    .module-label.ram {
      min-width: 3.5em;
    }

    .module-label.cpu-temp {
      min-width: 2.8em;
    }

    /* Media controls: active state for shuffle/loop.
       HyprPanel's monochrome SCSS uses the same colour for active and inactive,
       so we override it here with the accent tint. */
    .media-indicator-control-button.enabled.active {
      background-color: rgba(${c.accentRgb}, 0.25);
      color: ${c.accent};
    }

    .media-indicator-control-button.enabled.active:hover {
      background-color: rgba(${c.accentRgb}, 0.4);
    }

    /* Notification popups: gap from floating bar and right screen edge */
    .notifications-window {
      margin-top: 2.8em;
      margin-right: 1.5em;
    }
  '';
in
{
  config = lib.mkIf config.hyprland.enable {

    # 1. Wipe before linkGeneration so home-manager can lay down a fresh symlink.
    home.activation.cleanHyprpanelConfig =
      lib.hm.dag.entryBefore [ "linkGeneration" ] ''
        rm -rf "$HOME/.config/hyprpanel"
      '';

    # 2. After linkGeneration, replace the nix-store symlinks with real file copies.
    #    GLib (used by HyprPanel) raises ELOOP when following the multi-level
    #    symlink chain into the nix store. Plain file copies sidestep this
    #    and let HyprPanel write GUI changes back to config.json freely.
    home.activation.copyHyprpanelConfig =
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        mkdir -p "$HOME/.config/hyprpanel"
        config="$HOME/.config/hyprpanel/config.json"
        if [ -L "$config" ]; then
          cp --no-preserve=all --dereference "$config" "$config.tmp" \
            && mv "$config.tmp" "$config"
        fi
        cp "${hyprpanelModulesScss}" "$HOME/.config/hyprpanel/modules.scss"
      '';

    programs.hyprpanel = {
      enable = true;

      # Start via exec-once (hyprland.nix) rather than systemd,
      # consistent with how the rest of the desktop is launched.
      systemd.enable = false;

      settings = {

        # Disable wallpaper management — swaybg handles this
        wallpaper.enable = false;

        # Disable matugen (wallpaper-based dynamic color generation)
        theme.matugen = false;

        # ─── Bar layout ─────────────────────────────────────────────────────
        bar.layouts."*" = {
          left   = [ "dashboard" "workspaces" "windowtitle" "media" ];
          middle = [ "clock" ];
          right  = [ "volume" "network" "bluetooth" "cpu" "ram" "cpuTemp" ]
                  ++ lib.optional config.hyprland.battery "battery"
                  ++ [ "systray" "notifications" ];
        };

        # ─── Bar modules ────────────────────────────────────────────────────

        bar.launcher = {
          autoDetectIcon = false;
          # builtins.fromJSON is the only way to produce a \uXXXX Unicode char
          # in Nix — Nix strings don't support \u escapes but JSON does.
          icon           = builtins.fromJSON ''"\uf313"'';   # NixOS snowflake
        };

        bar.workspaces = {
          show_numbered = true;
          workspaces    = 0;   # dynamic: only show workspaces that exist
        };

        bar.windowtitle = {
          label           = true;
          truncation      = true;
          truncation_size = 35;
        };

        bar.media = {
          show_active_only = true;
          truncation       = true;
          truncation_size  = 40;
          format           = "{artist: - }{title}";
        };

        bar.volume.label = true;

        bar.network = {
          label           = true;
          truncation      = true;
          truncation_size = 20;
          showWifiInfo    = true;
        };

        bar.bluetooth.label = false;

        bar.battery = {
          label             = true;
          hideLabelWhenFull = false;
        };

        # round = true → integer percentages, no decimals
        # Note: these live under customModules, not bar directly
        bar.customModules.cpu = {
          label           = true;
          round           = true;
          pollingInterval = 2000;
        };

        bar.customModules.ram = {
          label           = true;
          labelType       = "used";
          pollingInterval = 2000;
        };

        bar.customModules.cpuTemp = {
          label           = true;
          sensor          = "auto";
          unit            = "metric";
          round           = true;
          pollingInterval = 2000;
        };

        # Clock — date and time in middle, no icon
        bar.clock = {
          format   = "%Y-%m-%d  V%V  %H:%M";
          showIcon = false;
        };

        bar.notifications = {
          show_total        = false;
          hideCountWhenZero = false;
        };

        # ─── Popup menus ────────────────────────────────────────────────────

        menus.clock = {
          time = {
            military    = true;
            hideSeconds = false;
          };
          weather.enabled = false;
        };

        menus.media = {
          preferredPlayer = "spotify";
          hideAuthor      = false;
        };

        menus.power = {
          confirmation = false;
          sleep        = "systemctl suspend";
          reboot       = "systemctl reboot";
          logout       = "hyprctl dispatch exit";
          shutdown     = "systemctl poweroff";
        };

        menus.volume.raiseMaximumVolume = false;

        menus.dashboard = {
          powermenu = {
            confirmation = false;
            sleep        = "systemctl suspend";
            reboot       = "systemctl reboot";
            logout       = "hyprctl dispatch exit";
            shutdown     = "systemctl poweroff";
            avatar.name  = variables.username;
          };
          # Keep system stats pills at the bottom
          stats = {
            enabled    = true;
            enable_gpu = false;
          };
          # Keep quick-toggle controls (dark mode, DND, etc.)
          controls.enabled = true;
          # Left card: screen, screenshot, search.
          # Right card always shows hardcoded Settings + Recording buttons.
          shortcuts = {
            enabled = true;
            left = {
              shortcut1 = { icon = "󰍹"; tooltip = "Display Settings"; command = "nwg-displays"; };
              shortcut2 = { icon = "󰄀"; tooltip = "Screenshot";        command = "grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png && notify-send 'Screenshot' 'Region saved'"; };
              shortcut3 = { icon = "󰍉"; tooltip = "Search Apps";       command = "walker"; };
              shortcut4 = { icon = "󰑩"; tooltip = "Toggle Hotspot"; command = "bash -c 'if nmcli -t -f NAME connection show --active | grep -q Hotspot; then nmcli connection down Hotspot; else nmcli connection up Hotspot; fi'"; };
            };
            right = {
              shortcut1 = { icon = "󰙯"; tooltip = "Discord"; command = "discord-ptb"; };
              shortcut2 = { icon = ""; tooltip = "Proton Mail"; command = "protonmail-desktop"; };
            };
          };
          directories.enabled = false;
        };

        # ─── Notifications ──────────────────────────────────────────────────

        notifications = {
          displayedTotal = 5;
          clearDelay     = 3000;
          position       = "top right";
          active_monitor = true;
        };

        # ─── Theme ──────────────────────────────────────────────────────────
        # Colors sourced from config.theme.colors (see modules/home-manager/theme/).

        theme.font = {
          name   = f.name;
          size   = f.size;
          weight = f.weight;
        };

        theme.bar = {
          floating      = true;
          border_radius = "0.4em";
          outer_spacing = "0.5em";
          margin_top    = "0.4em";
          margin_sides  = "0.3em";
          background    = "rgba(0, 0, 0, 0)";
          border.location = "none";
          border.color    = c.border;

          buttons = {
            style              = "default";
            enableBorders      = false;
            borderColor        = c.accent;
            background         = "rgba(0,0,0,0)";
            background_opacity = 0;
            hover              = c.backgroundAlt;
            radius             = "0.4em";
            padding_x          = "0.4rem";
            spacing            = "0.4em";
            text               = c.accent;
            icon               = c.accent;

            clock.text            = c.accent;
            clock.background      = "rgba(0,0,0,0)";
            clock.icon_background = "rgba(0,0,0,0)";

            workspaces = {
              active     = c.accent;
              available  = c.textDim;
              occupied   = c.warning;
              hover      = c.backgroundAlt;
              background = "rgba(0,0,0,0)";
            };

            dashboard.background = "rgba(0,0,0,0)";
            dashboard.border     = c.accent;
            dashboard.icon       = c.accent;

            windowtitle.background      = "rgba(0,0,0,0)";
            windowtitle.icon_background = "rgba(0,0,0,0)";
            windowtitle.text            = c.accent;
            windowtitle.icon            = c.accent;

            media.background      = "rgba(0,0,0,0)";
            media.icon_background = "rgba(0,0,0,0)";
            media.border          = c.accent;
            media.text            = c.accent;
            media.icon            = c.accent;

            volume.background      = "rgba(0,0,0,0)";
            volume.icon_background = "rgba(0,0,0,0)";
            volume.border          = c.accent;
            volume.text            = c.accent;
            volume.icon            = c.accent;

            network.background      = "rgba(0,0,0,0)";
            network.icon_background = "rgba(0,0,0,0)";
            network.border          = c.accent;
            network.text            = c.accent;
            network.icon            = c.accent;

            bluetooth.background      = "rgba(0,0,0,0)";
            bluetooth.icon_background = "rgba(0,0,0,0)";
            bluetooth.border          = c.accent;
            bluetooth.text            = c.accent;
            bluetooth.icon            = c.accent;

            battery.background      = "rgba(0,0,0,0)";
            battery.icon_background = "rgba(0,0,0,0)";
            battery.border          = c.accent;
            battery.text            = c.accent;
            battery.icon            = c.accent;

            systray.background  = "rgba(0,0,0,0)";
            systray.customIcon  = c.accent;
            systray.border      = c.accent;

            notifications.background      = "rgba(0,0,0,0)";
            notifications.icon_background = "rgba(0,0,0,0)";
            notifications.border          = c.accent;
            notifications.icon            = c.accent;
            notifications.total           = c.accent;

            modules.cpu.background      = "rgba(0,0,0,0)";
            modules.cpu.icon_background = "rgba(0,0,0,0)";
            modules.cpu.border          = c.accent;
            modules.cpu.text            = c.accent;
            modules.cpu.icon            = c.accent;

            modules.ram.background      = "rgba(0,0,0,0)";
            modules.ram.icon_background = "rgba(0,0,0,0)";
            modules.ram.border          = c.accent;
            modules.ram.text            = c.accent;
            modules.ram.icon            = c.accent;

            modules.cpuTemp.background      = "rgba(0,0,0,0)";
            modules.cpuTemp.icon_background = "rgba(0,0,0,0)";
            modules.cpuTemp.border          = c.accent;
            modules.cpuTemp.text            = c.accent;
            modules.cpuTemp.icon            = c.accent;

            modules.microphone.border = c.accent;
            modules.microphone.text   = c.accent;
            modules.microphone.icon   = c.accent;

            modules.netstat.border = c.accent;
            modules.netstat.text   = c.accent;
            modules.netstat.icon   = c.accent;

            modules.kbLayout.border = c.accent;
            modules.kbLayout.text   = c.accent;
            modules.kbLayout.icon   = c.accent;

            modules.updates.border = c.accent;
            modules.updates.text   = c.accent;
            modules.updates.icon   = c.accent;

            modules.weather.border = c.accent;
            modules.weather.text   = c.accent;
            modules.weather.icon   = c.accent;

            modules.power.border = c.accent;
            modules.power.icon   = c.accent;

            modules.hyprsunset.border = c.accent;
            modules.hyprsunset.text   = c.accent;
            modules.hyprsunset.icon   = c.accent;

            modules.worldclock.border = c.accent;
            modules.worldclock.text   = c.accent;
            modules.worldclock.icon   = c.accent;
          };
        };

        # ─── Popup menus theme ──────────────────────────────────────────────
        theme.bar.menus = {
          monochrome  = false;
          background  = "rgba(${c.backgroundRgb}, 0.55)";
          cards       = c.backgroundAlt;
          card_radius = "0.4em";
          text        = c.textBright;
          dimtext     = c.textDim;
          feinttext   = c.surface;
          label       = c.accent;
          buttons.default  = c.accent;
          buttons.text     = c.background;
          buttons.radius   = "0.4em";
        };

        # ─── Per-popup-menu colors (each has independent defaults) ──────────
        # HyprPanel uses nested objects: card.color, background.color, border.color
        # (not card_color / background_color / border_color — those are silently ignored).
        theme.bar.menus.menu = {

          clock = {
            card.color       = c.backgroundAlt;
            background.color = "rgba(${c.backgroundRgb}, 0.55)";
            border.color     = c.border;
            text             = c.textBright;
            time.time        = c.accent;
            time.timeperiod  = c.textDim;
            calendar.yearmonth   = c.accent;
            calendar.weekdays    = c.textDim;
            calendar.paginator   = c.accent;
            calendar.currentday  = c.accent;
            calendar.days        = c.textBright;
            calendar.contextdays = c.border;
          };

          dashboard = {
            card.color       = c.backgroundAlt;
            background.color = "rgba(${c.backgroundRgb}, 0.55)";
            border.color     = c.border;
            profile.name     = c.textBright;
            powermenu = {
              shutdown = c.urgent;
              restart  = c.warning;
              logout   = c.success;
              sleep    = c.accentBlue;
              confirmation = {
                card        = c.backgroundAlt;
                background  = c.background;
                border      = c.border;
                label       = c.accent;
                body        = c.textBright;
                confirm     = c.success;
                deny        = c.urgent;
                button_text = c.background;
              };
            };
            shortcuts.background = c.accent;
            shortcuts.text       = c.background;
            controls = {
              disabled                 = c.border;
              wifi.background          = c.accent;
              wifi.text                = c.background;
              bluetooth.background     = c.accent;
              bluetooth.text           = c.background;
              notifications.background = c.accent;
              notifications.text       = c.background;
              volume.background        = c.accent;
              volume.text              = c.background;
              input.background         = c.accent;
              input.text               = c.background;
            };
            monitors.bar_background = c.surface;
            monitors.cpu.icon    = c.accent;
            monitors.cpu.bar     = c.accent;
            monitors.cpu.label   = c.accent;
            monitors.ram.icon    = c.accent;
            monitors.ram.bar     = c.accent;
            monitors.ram.label   = c.accent;
          };

          volume = {
            card.color       = c.backgroundAlt;
            background.color = "rgba(${c.backgroundRgb}, 0.55)";
            border.color     = c.border;
            label.color      = c.accent;
            text             = c.textBright;
          };

          network = {
            card.color       = c.backgroundAlt;
            background.color = "rgba(${c.backgroundRgb}, 0.55)";
            border.color     = c.border;
            label.color      = c.accent;
            text             = c.textBright;
          };

          bluetooth = {
            card.color       = c.backgroundAlt;
            background.color = "rgba(${c.backgroundRgb}, 0.55)";
            border.color     = c.border;
            label.color      = c.accent;
            text             = c.textBright;
          };

          battery = {
            card.color       = c.backgroundAlt;
            background.color = "rgba(${c.backgroundRgb}, 0.55)";
            border.color     = c.border;
            label.color      = c.accent;
            text             = c.textBright;
          };

          notifications = {
            background             = "rgba(${c.backgroundRgb}, 0.55)";
            card                   = c.backgroundAlt;
            border                 = c.border;
            label                  = c.accent;
            no_notifications_label = c.textDim;
            clear                  = c.urgent;
            switch.enabled         = c.accent;
            pager.button           = c.accent;
            scrollbar.color        = c.border;
          };

          media = {
            background.color = "rgba(${c.backgroundRgb}, 0.55)";
            card.color       = c.backgroundAlt;
            border.color     = c.border;
          };
        };

        theme.notification = {
          background = "rgba(${c.backgroundRgb}, 0.75)";
          label      = c.textBright;
          border     = c.border;
          time       = c.textDim;
          text       = c.textBright;
          labelicon  = c.accent;
          actions = {
            background = c.backgroundAlt;
            text       = c.textBright;
          };
          close_button = {
            background = c.urgent;
            label      = c.textBright;
          };
        };

        theme.osd = {
          enable         = false;
          orientation    = "vertical";
          location       = "right";
          bar_color      = c.accent;
          icon_container = c.border;
          icon           = c.textBright;
          label          = c.textBright;
        };
      };
    };

    # pavucontrol — advanced audio routing, opened via volume right-click
    # glib-networking — GIO TLS/HTTP backend; lets HyprPanel fetch Spotify album art
    home.packages = with pkgs; [ pavucontrol glib-networking ];
  };
}
