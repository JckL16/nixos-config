# modules/home-manager/desktop/hyprland/hyprland.nix
{ pkgs, lib, config, variables, ... }:
let
  c = config.theme.colors;
  f = config.theme.font;
  # Hyprland color format: rgba(RRGGBBAA) without leading #
  hyprHex = hex: builtins.substring 1 6 hex;
in {

  options = {
    hyprland.enable   = lib.mkEnableOption "Enable hyprland home-manager configuration";
    hyprland.battery  = lib.mkEnableOption "Include battery module in HyprPanel bar";
  };

  config = lib.mkIf config.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      configType = "hyprlang";
      
      settings = {
        # Modifier key
        "$mod" = "SUPER";

        monitor = [
          ",preferred,auto,${toString variables.displayScale}"
        ];
        
        # General settings
        general = {
          gaps_in = 4;
          gaps_out = 6;
          border_size = 2;
          "col.active_border" = "rgba(${hyprHex c.border}ee)";
          "col.inactive_border" = "rgba(${hyprHex c.border}aa)";
          layout = "dwindle";
        };
        
        # Decoration
        decoration = {
          rounding = 3;
          
          blur = {
            enabled = true;
            size = 5;
            passes = 2;
            xray = false;
          };
          
          shadow = {
            enabled = true;
            range = 10;
            render_power = 3;
            color = "rgba(00000099)";
          };

          dim_inactive = true;
          dim_strength = 0.15;
        };
        
        # Animations
        animations = {
          enabled = true;
          bezier = [
            "easeOutQuint, 0.23, 1, 0.32, 1"
            "easeInOutCubic, 0.65, 0, 0.35, 1"
            "linear, 0, 0, 1, 1"
            "almostLinear, 0.5, 0.5, 0.75, 1.0"
            "quick, 0.15, 0, 0.1, 1"
          ];

          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
        };

        misc = {
          disable_hyprland_logo = true;
          font_family = "JetBrains Mono";
          focus_on_activate = true;
        };

        cursor = {
          no_hardware_cursors = true;
          use_cpu_buffer = 1;
        };

        # Input configuration
        input = {
          kb_layout = "${variables.keyboard-layout},us";
          kb_options = "grp:alt_shift_toggle,caps:escape";
          follow_mouse = 1;
          
          touchpad = {
            natural_scroll = true;
          };
        };
        
        # Dwindle layout
        dwindle = {
          preserve_split = true;
        };
        
        # Key bindings
        bind = [
          "$mod SHIFT, Q, killactive"
          "$mod SHIFT, C, exec, hyprctl reload"
          "$mod SHIFT, E, exit"
          "$mod SHIFT, P, exec, pgrep wlogout || wlogout -b 2 -c 2 -r 2 -L 500 -R 500 -T 300 -B 300"
          
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"
          
          "$mod, Left, movefocus, l"
          "$mod, Down, movefocus, d"
          "$mod, Up, movefocus, u"
          "$mod, Right, movefocus, r"
          
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, L, movewindow, r"
          
          "$mod SHIFT, Left, movewindow, l"
          "$mod SHIFT, Down, movewindow, d"
          "$mod SHIFT, Up, movewindow, u"
          "$mod SHIFT, Right, movewindow, r"
          
          "$mod, V, layoutmsg, togglesplit"
          "$mod, F, fullscreen, 0"
          "$mod, S, togglegroup"
          "$mod, W, changegroupactive, f"
          "$mod, E, layoutmsg, togglesplit"
          
          "$mod SHIFT, Space, togglefloating"
          "$mod, Space, focuscurrentorlast"
          
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"
          
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"
          
          # Preselect split direction (dwindle layout)
          "$mod CTRL, H, layoutmsg, preselect l"
          "$mod CTRL, J, layoutmsg, preselect d"
          "$mod CTRL, K, layoutmsg, preselect u"
          "$mod CTRL, L, layoutmsg, preselect r"
          "$mod CTRL, Escape, layoutmsg, preselectreset"

          "$mod, R, submap, resize"
          "$mod, D, exec, walker"
          "$mod SHIFT, D, exec, walker -m websearch"
          "$mod, F1, exec, walker -m hyprlandkeybinds"
          "$mod, Tab, exec, walker -m windows"
          "$mod, Return, exec, alacritty"
          "$mod SHIFT, X, exec, hyprlock"
          "$mod SHIFT, V, exec, ~/.config/walker/clipboard.sh"
          "$mod, T, exec, xdg-open https://"

          # Volume controls with swayosd
          ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
          ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"

          # Screenshot keybindings
          ", Print, exec, grim ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png && notify-send 'Screenshot' 'Full screen saved to ~/Pictures/Screenshots/'"
          "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot' 'Region copied to clipboard'"
          "$mod, Print, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png && notify-send 'Screenshot' 'Region saved to ~/Pictures/Screenshots/'"

          # Mouse workspace switching
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          # Toggle notification center
          "$mod, N, exec, hyprpanel -t notificationsmenu"

          # Toggle lid suspend behavior
          ''$mod SHIFT, O, exec, if [ "$(cat ~/.config/hypr/lid-suspend-enabled 2>/dev/null)" = "0" ]; then echo 1 > ~/.config/hypr/lid-suspend-enabled && notify-send "Lid Suspend" "Lid suspend: ON"; else echo 0 > ~/.config/hypr/lid-suspend-enabled && notify-send "Lid Suspend" "Lid suspend: OFF"; fi''
        ];
        
        # Binds that can be held down
        binde = [
          # Volume controls with swayosd
          ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume 2"
          ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -2"

          # Brightness controls with swayosd
          ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
          ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
        ];
        
        # Mouse bindings
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # Lid switch binding
        bindl = [
          '', switch:on:Lid Switch, exec, if [ "$(cat ~/.config/hypr/lid-suspend-enabled 2>/dev/null)" != "0" ]; then loginctl lock-session; sleep 1; systemctl suspend; fi''
        ];
        
        # Startup applications
        exec-once = [
          "xset fp+ $(readlink -f /run/current-system/sw/share/X11/fonts) && xset fp rehash"
          "mkdir -p ~/Pictures/Screenshots"
          "[ -f ~/.config/hypr/lid-suspend-enabled ] || echo 1 > ~/.config/hypr/lid-suspend-enabled"
          "dex --autostart --environment hyprland"
          "swaybg -i ~/.config/wallpapers/wallpaper.png -m fill"
          "hyprpanel"
          "hyprctl dispatch workspace 1"
          "swayosd-server &"
          "batsignal -b -w 20 -c 10 -d 5 -n BAT0"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "walker --gapplication-service"
        ];
        
        # Environment variables
        env = [
          "XCURSOR_THEME,Bibata-Modern-Classic"
          "XCURSOR_SIZE,20"
          "GTK_ICON_THEME,Papirus-Dark"
        ];
      };
      
      # Resize mode using extraConfig (bypasses Nix validation)
      extraConfig = ''
        # Monitor config managed by nwg-displays (ignored if file doesn't exist)
        source = ~/.config/hypr/monitors.conf

        # Window rules
        windowrule = float on class:^(org.pulseaudio.pavucontrol)$
        windowrule = float on class:^(.blueman-manager-wrapped)$
        windowrule = float on class:^(nm-connection-editor)$
        windowrule = no_blur on fullscreen:1

        # Layer rules - blur and transparency
        layerrule = blur on, ignore_alpha 0.5, match:namespace walker
        # HyprPanel bar layers are named bar-0, bar-1, etc.
        layerrule = blur on, ignore_alpha 0.5, match:namespace bar-[0-9]+
        # HyprPanel popup menus (networkmenu, audiomenu, mediamenu, etc.)
        layerrule = blur on, ignore_alpha 0.5, match:namespace .*menu
        # HyprPanel notification center
        layerrule = blur on, ignore_alpha 0.5, match:namespace notifications-window
        layerrule = blur on, ignore_alpha 1, match:namespace swayosd
        layerrule = blur on, ignore_alpha 1, match:namespace logout_dialog

        # Resize submap
        bind = $mod, R, submap, resize
        
        submap = resize
        binde = , H, resizeactive, -10 0
        binde = , J, resizeactive, 0 10
        binde = , K, resizeactive, 0 -10
        binde = , L, resizeactive, 10 0
        
        binde = , Left, resizeactive, -10 0
        binde = , Down, resizeactive, 0 10
        binde = , Up, resizeactive, 0 -10
        binde = , Right, resizeactive, 10 0
        
        bind = , Return, submap, reset
        bind = , Escape, submap, reset
        bind = $mod, R, submap, reset
        submap = reset
      '';
    };

    # Create monitors.conf if it doesn't exist so Hyprland's source= doesn't error.
    # nwg-displays writes here; we must not use home.file (read-only symlink).
    home.activation.createMonitorsConf = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f "$HOME/.config/hypr/monitors.conf" ]; then
        mkdir -p "$HOME/.config/hypr"
        touch "$HOME/.config/hypr/monitors.conf"
      fi
    '';

    home.file.".config/wallpapers/wallpaper.png".source = ../../../../wallpaper/wallpaper.png;

    home.packages = with pkgs; [
      nwg-displays
      grim
      slurp
      wl-clipboard
      playerctl
      brightnessctl
      networkmanagerapplet
      swaybg
      udiskie
      nerd-fonts.jetbrains-mono
      libnotify
      batsignal
      jq
    ];

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
        };

        background = [
          {
            path = "~/.config/wallpapers/wallpaper.png";
            blur_passes = 2;
            blur_size = 7;
          }
        ];

        input-field = [
          {
            size = "300, 50";
            outline_thickness = 7;
            outer_color = "rgb(${hyprHex c.border})";
            inner_color = "rgba(${hyprHex c.background}88)";
            font_color = "rgb(${hyprHex c.textBright})";
            check_color = "rgb(${hyprHex c.accentDark})";
            fail_color = "rgb(${hyprHex c.urgent})";
            fade_on_empty = false;
            placeholder_text = "";
            font_family = f.name;
            halign = "center";
            valign = "center";
            position = "0, -80";
          }
        ];

        label = [
          {
            text = ''cmd[update:1000] echo "$(date +'%H:%M:%S')"'';
            font_size = 24;
            font_family = f.name;
            color = "rgb(${hyprHex c.textBright})";
            halign = "center";
            valign = "center";
            position = "0, 80";
          }
        ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
      };
    };

    # blueman-applet disabled — HyprPanel has its own bluetooth module in the bar
    services.blueman-applet.enable = false;

    # Suppress blueman's XDG autostart entry so dex doesn't start it.
    # The system blueman package installs /etc/xdg/autostart/blueman.desktop;
    # a Hidden=true override in ~/.config/autostart/ prevents dex from picking it up.
    xdg.configFile."autostart/blueman.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
  };
}
