{ pkgs, lib, config, variables, ... }: {

  options = {
    sway.enable = lib.mkEnableOption "Enable sway home-manager configuration";
  };

  config = lib.mkIf config.sway.enable {
    services.gnome-keyring.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.swayfx;
      checkConfig = false;
      config = {
        modifier = "Mod4";
        terminal = "alacritty";
        menu = "rofi -show combi";
        defaultWorkspace = null;
        
        gaps = {
          inner = 8;
          outer = 4;
        };

        fonts = {
          names = [ "JetBrainsMono Nerd Font Mono" ];
          size = 10.0;
        };

        colors = {
          focused = {
            border = "#4C566A";
            background = "#4C566A";
            text = "#D8DEE9";
            indicator = "#4C566A";
            childBorder = "#4C566A";
          };
          unfocused = {
            border = "#4C566A";
            background = "#4C566A";
            text = "#D8DEE9";
            indicator = "#4C566A";
            childBorder = "#4C566A";
          };
          urgent = {
            border = "#BF616A";
            background = "#BF616A";
            text = "#D8DEE9";
            indicator = "#BF616A";
            childBorder = "#BF616A";
          };
        };

        keybindings = {
          "Mod4+Shift+q" = "kill";
          "Mod4+Shift+c" = "reload";
          "Mod4+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";
          
          "Mod4+h" = "focus left";
          "Mod4+j" = "focus down";
          "Mod4+k" = "focus up";
          "Mod4+l" = "focus right";
          
          "Mod4+Left" = "focus left";
          "Mod4+Down" = "focus down";
          "Mod4+Up" = "focus up";
          "Mod4+Right" = "focus right";
          
          "Mod4+Shift+h" = "move left";
          "Mod4+Shift+j" = "move down";
          "Mod4+Shift+k" = "move up";
          "Mod4+Shift+l" = "move right";
          
          "Mod4+Shift+Left" = "move left";
          "Mod4+Shift+Down" = "move down";
          "Mod4+Shift+Up" = "move up";
          "Mod4+Shift+Right" = "move right";
          
          "Mod4+v" = "splitv";
          "Mod4+b" = "splith";
          "Mod4+f" = "fullscreen toggle";
          "Mod4+s" = "layout stacking";
          "Mod4+w" = "layout tabbed";
          "Mod4+e" = "layout toggle split";
          
          "Mod4+Shift+space" = "floating toggle";
          "Mod4+space" = "focus mode_toggle";
          "Mod4+a" = "focus parent";
          
          "Mod4+1" = "workspace number 1";
          "Mod4+2" = "workspace number 2";
          "Mod4+3" = "workspace number 3";
          "Mod4+4" = "workspace number 4";
          "Mod4+5" = "workspace number 5";
          "Mod4+6" = "workspace number 6";
          "Mod4+7" = "workspace number 7";
          "Mod4+8" = "workspace number 8";
          "Mod4+9" = "workspace number 9";
          "Mod4+0" = "workspace number 10";
          
          "Mod4+Shift+1" = "move container to workspace number 1; workspace number 1";
          "Mod4+Shift+2" = "move container to workspace number 2; workspace number 2";
          "Mod4+Shift+3" = "move container to workspace number 3; workspace number 3";
          "Mod4+Shift+4" = "move container to workspace number 4; workspace number 4";
          "Mod4+Shift+5" = "move container to workspace number 5; workspace number 5";
          "Mod4+Shift+6" = "move container to workspace number 6; workspace number 6";
          "Mod4+Shift+7" = "move container to workspace number 7; workspace number 7";
          "Mod4+Shift+8" = "move container to workspace number 8; workspace number 8";
          "Mod4+Shift+9" = "move container to workspace number 9; workspace number 9";
          "Mod4+Shift+0" = "move container to workspace number 10; workspace number 10";
          
          "Mod4+r" = "mode resize";
          "Mod4+d" = "exec rofi -show combi";
          "Mod4+Tab" = "exec rofi -show window";
          "Mod4+Return" = "exec alacritty";
          "Mod4+Shift+x" = "exec swaylock -f -i ~/.config/wallpapers/wallpaper.png --effect-blur 7x5 --indicator --indicator-radius 100 --indicator-thickness 7 --ring-color 4c566a --key-hl-color 88c0d0 --bs-hl-color bf616a --inside-color 2e344088 --ring-ver-color 5e81ac --inside-ver-color 2e344088 --ring-wrong-color bf616a --inside-wrong-color 2e344088 --line-color 00000000 --separator-color 00000000 --clock --timestr '%H:%M:%S' --datestr '' --text-color eceff4 --font 'JetBrainsMono Nerd Font' --font-size 24";
          "Mod4+Shift+v" = "~/.config/rofi/clipman.sh"
          
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          
          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        };

        modes = {
          resize = {
            "h" = "resize shrink width 10 px or 10 ppt";
            "j" = "resize grow height 10 px or 10 ppt";
            "k" = "resize shrink height 10 px or 10 ppt";
            "l" = "resize grow width 10 px or 10 ppt";
            
            "Left" = "resize shrink width 10 px or 10 ppt";
            "Down" = "resize grow height 10 px or 10 ppt";
            "Up" = "resize shrink height 10 px or 10 ppt";
            "Right" = "resize grow width 10 px or 10 ppt";
            
            "Return" = "mode default";
            "Escape" = "mode default";
            "Mod4+r" = "mode default";
          };
        };

        bars = [ ];

        window = {
          border = 2;
          titlebar = false;
          commands = [
            {
              criteria = { app_id = "pavucontrol"; };
              command = "floating enable";
            }
            {
              criteria = { class = "Pavucontrol"; };
              command = "floating enable";
            }
            {
              criteria = { app_id = "blueman-manager"; };
              command = "floating enable";
            }
            {
              criteria = { class = "Blueman-manager"; };
              command = "floating enable";
            }
          ];
        };

        floating = {
          border = 2;
          titlebar = false;
        };

        startup = [
          { command = "dex --autostart --environment sway"; always = false; }
          { command = "swaybg -i ~/.config/wallpapers/wallpaper.png -m fill"; always = true; }
          { command = "systemctl --user restart mako"; always = false; }
          { command = "waybar"; always = false; }
          { command = "swaymsg workspace 1"; }
          { command = "sh -c 'sleep 2 && systemctl --user start kanshi.service'"; always = false; }
        ];
      };

      extraConfig = ''
        output * bg ~/.config/wallpapers/wallpaper.png fill
        
        # Keyboard layout configuration
        input type:keyboard {
            xkb_layout "${variables.keyboard-layout}"
            xkb_options "grp:alt_shift_toggle"
        }
        
        # SwayFX specific settings - Rounded corners
        corner_radius 3
        
        # Shadows
        shadows enable
        shadow_blur_radius 20
        shadow_color #00000099
        
        # Window blur
        blur enable
        blur_xray disable
        blur_passes 2
        blur_radius 5
        
        # Dimming inactive windows
        default_dim_inactive 0.1
        dim_inactive_colors.unfocused #000000FF
        dim_inactive_colors.urgent #BF616AFF
        
        # Layer effects for waybar and rofi
        layer_effects "waybar" blur disable; shadows disable; corner_radius 1
        layer_effects "rofi" blur enable; shadows enable; corner_radius 5
      '';
    };

    gtk = {
      enable = true;
      
      theme = {
        name = "Nordic";
        package = pkgs.nordic;
      };
      
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };

    home.pointerCursor = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      size = 24;
      gtk.enable = true;
    };

    # Qt configuration for Wayland
    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "adwaita-dark";
    };

    home.file = {
      ".config/wallpapers/wallpaper.png".source = ../../../../wallpaper/wallpaper.png;
    };

    home.packages = with pkgs; [
      swaylock-effects
      swayidle
      waybar
      rofi
      mako
      wl-clipboard
      grim
      slurp
      brightnessctl
      networkmanagerapplet
      nerd-fonts.jetbrains-mono
      udiskie
      clipman
      nordic
    ];
  };
}