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
  # modules.scss is loaded by HyprPanel after its main SCSS for user overrides.
  # Using pkgs.writeText + activation-script copy avoids the GLib ELOOP that
  # occurs when HyprPanel's readFile() follows multi-level nix-store symlinks.
  hyprpanelModulesScss = pkgs.writeText "hyprpanel-modules.scss" ''
    /* Systray popup menus are styled via gtk3.extraCss in nordic-theme.nix
       since they belong to external GTK apps, not HyprPanel itself. */

    /* Calendar: today marker as bottom border + no background.
       GTK3 box-shadow inset is unreliable; border-bottom is the safe way
       to get an underline that stays centred under the number. */
    .calendar-menu-widget:selected {
      background-color: transparent;
      border-bottom: 2px solid #88C0D0;
      color: #88C0D0;
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
      background-color: rgba(46, 52, 64, 0.92);
      border-radius: 6px;
      border: 1px solid rgba(76, 86, 106, 0.5);
      padding: 4px;
      color: #ECEFF4;
      font-size: 12px;
    }

    window.popup menu menuitem {
      border-radius: 4px;
      padding: 5px 12px;
      color: #ECEFF4;
      font-size: 12px;
    }

    window.popup menu menuitem label {
      font-size: 12px;
    }

    window.popup menu menuitem:hover {
      background-color: rgba(59, 66, 82, 0.85);
    }

    window.popup menu menuitem:disabled {
      color: rgba(216, 222, 233, 0.4);
    }

    window.popup menu separator {
      background-color: rgba(76, 86, 106, 0.4);
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
       so we override it here with a Nord frost tint. */
    .media-indicator-control-button.enabled.active {
      background-color: rgba(136, 192, 208, 0.25);
      color: #88C0D0;
    }

    .media-indicator-control-button.enabled.active:hover {
      background-color: rgba(136, 192, 208, 0.4);
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
          right  = [ "volume" "network" "bluetooth" ]
                  ++ lib.optional config.hyprland.battery "battery"
                  ++ [ "cpu" "ram" "cpuTemp" "systray" "notifications" ];
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
          label = true;
          round = true;
        };

        bar.customModules.ram = {
          label     = true;
          labelType = "used";   # e.g. "8.24G" (HyprPanel supports 0 or 2 decimals only)
        };

        bar.customModules.cpuTemp = {
          label  = true;
          sensor = "auto";
          unit   = "metric";
          round  = true;
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
              shortcut3 = { icon = "󰍉"; tooltip = "Search Apps";       command = "rofi -show drun"; };
              shortcut4 = { icon = ""; tooltip = ""; command = ""; };
            };
            right = {
              shortcut1 = { icon = ""; tooltip = ""; command = ""; };
              shortcut3 = { icon = ""; tooltip = ""; command = ""; };
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

        # ─── Nord theme ─────────────────────────────────────────────────────
        #
        # Nord palette:
        #   Polar Night: #2E3440  #3B4252  #434C5E  #4C566A
        #   Snow Storm:  #D8DEE9  #E5E9F0  #ECEFF4
        #   Frost:       #8FBCBB  #88C0D0  #81A1C1  #5E81AC
        #   Aurora:      #BF616A  #D08770  #EBCB8B  #A3BE8C  #B48EAD

        theme.font = {
          name   = "JetBrainsMono Nerd Font";
          size   = "0.9rem";
          weight = 600;
        };

        theme.bar = {
          floating      = true;
          border_radius = "0.4em";
          outer_spacing = "0.5em";
          margin_top    = "0.4em";
          margin_sides  = "0.3em";
          background    = "rgba(0, 0, 0, 0)";
          border.location = "none";
          border.color    = "#4C566A";

          buttons = {
            style              = "default";
            enableBorders      = false;
            background         = "rgba(0,0,0,0)";
            background_opacity = 0;
            hover              = "#3B4252";
            radius             = "0.4em";
            padding_x          = "0.4rem";
            spacing            = "0.4em";   # wider gap between right-side modules
            text               = "#ECEFF4";
            icon               = "#88C0D0";

            # Clock text matches the popup clock time colour ($bar-menus-label)
            clock.text = "#88C0D0";

            workspaces = {
              active   = "#88C0D0";   # Nord Frost — active workspace
              occupied = "#EBCB8B";   # Nord Aurora yellow — has windows
              hover    = "#3B4252";
            };
          };
        };

        # ─── Popup menus theme ──────────────────────────────────────────────
        theme.bar.menus = {
          # monochrome = true forces all menus to use background/cards/text
          # instead of per-menu Catppuccin defaults
          monochrome  = true;
          background  = "rgba(46, 52, 64, 0.55)";   # Nord Polar Night, glassy
          cards       = "rgba(46, 52, 64, 0)";       # fully transparent — no pill boxes
          card_radius = "0.4em";
          text        = "#ECEFF4";
          dimtext     = "#D8DEE9";
          label       = "#88C0D0";
        };

        theme.notification = {
          background = "rgba(46, 52, 64, 0.75)";   # glassy, same as menus
          label      = "#ECEFF4";
          border     = "#4C566A";
          time       = "#D8DEE9";
          text       = "#ECEFF4";
          labelicon  = "#88C0D0";
          actions = {
            background = "#3B4252";
            text       = "#ECEFF4";
          };
          close_button = {
            background = "#BF616A";
            label      = "#ECEFF4";
          };
        };

        theme.osd = {
          enable         = false;
          orientation    = "vertical";
          location       = "right";
          bar_color      = "#88C0D0";
          icon_container = "#4C566A";
          icon           = "#ECEFF4";
          label          = "#ECEFF4";
        };
      };
    };

    # pavucontrol — advanced audio routing, opened via volume right-click
    # glib-networking — GIO TLS/HTTP backend; lets HyprPanel fetch Spotify album art
    home.packages = with pkgs; [ pavucontrol glib-networking ];
  };
}
