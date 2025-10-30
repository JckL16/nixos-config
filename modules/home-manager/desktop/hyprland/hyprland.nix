# modules/home-manager/desktop/hyprland/hyprland.nix
{ pkgs, lib, config, variables, ... }: {

  options = {
    hyprland.enable = lib.mkEnableOption "Enable hyprland home-manager configuration";
  };

  config = lib.mkIf config.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      
      settings = {
        # Modifier key
        "$mod" = "SUPER";

        monitor = [
          ",preferred,auto,1"
        ];
        
        # General settings
        general = {
          gaps_in = 4;
          gaps_out = 6;
          border_size = 2;
          "col.active_border" = "rgba(4C566Aee)";
          "col.inactive_border" = "rgba(4C566Aaa)";
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
        };
        
        # Animations
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        misc = {
          disable_hyprland_logo = true;
          font_family = "JetBrains Mono";
        };
        
        # Input configuration
        input = {
          kb_layout = "${variables.keyboard-layout}";
          kb_options = "grp:alt_shift_toggle";
          follow_mouse = 1;
          
          touchpad = {
            natural_scroll = true;
          };
        };
        
        # Dwindle layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        
        # Window rules
        windowrulev2 = [
          "float, class:(org.pulseaudio.pavucontrol)"
          "float, class:(.blueman-manager-wrapped)"
        ];
        
        # Key bindings
        bind = [
          "$mod SHIFT, Q, killactive"
          "$mod SHIFT, C, exec, hyprctl reload"
          "$mod SHIFT, E, exit"
          
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
          
          "$mod, V, togglesplit"
          "$mod, F, fullscreen, 0"
          "$mod, S, togglegroup"
          "$mod, W, changegroupactive, f"
          "$mod, E, togglesplit"
          
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
          
          "$mod, R, submap, resize"
          "$mod, D, exec, rofi -show combi"
          "$mod, Tab, exec, rofi -show window"
          "$mod, Return, exec, alacritty"
          "$mod SHIFT, X, exec, swaylock -f -i ~/.config/wallpapers/wallpaper.png --effect-blur 7x5 --indicator --indicator-radius 100 --indicator-thickness 7 --ring-color 4c566a --key-hl-color 88c0d0 --bs-hl-color bf616a --inside-color 2e344088 --ring-ver-color 5e81ac --inside-ver-color 2e344088 --ring-wrong-color bf616a --inside-wrong-color 2e344088 --line-color 00000000 --separator-color 00000000 --clock --timestr '%H:%M:%S' --datestr '' --text-color eceff4 --font 'JetBrainsMono Nerd Font' --font-size 24"
          "$mod SHIFT, V, exec, ~/.config/rofi/clipman.sh"

          # Volume controls with swayosd
          ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume 2"
          ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -2"
          ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
          ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"

          # Brightness controls with swayosd
          ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
          ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
        ];
        
        # Mouse bindings
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        
        # Startup applications
        exec-once = [
          "dex --autostart --environment hyprland"
          "swaybg -i ~/.config/wallpapers/wallpaper.png -m fill"
          "systemctl --user restart mako"
          "waybar"
          "hyprctl dispatch workspace 1"
          "udiskie --tray --notify --automount &"
          "swayosd-server &"
        ];
        
        # Environment variables
        env = [
          "XCURSOR_THEME,Nordzy-cursors"
          "XCURSOR_SIZE,24"
        ];
      };
      
      # Resize mode using extraConfig (bypasses Nix validation)
      extraConfig = ''
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

    home.packages = with pkgs; [
      rofi
      mako
      grim
      slurp
      brightnessctl
      networkmanagerapplet
      swaybg
      udiskie
      nerd-fonts.jetbrains-mono
    ];

    services.blueman-applet.enable = true;
  };
}
