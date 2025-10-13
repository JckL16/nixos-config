# modules/home-manager/sway/waybar.nix

{ pkgs, lib, config, ... }: {

  config = lib.mkIf config.sway.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = false;
      
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;
          margin-top = 5;
          margin-left = 10;
          margin-right = 10;
          margin-bottom = 0;
          
          modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ];
          modules-center = [ "clock" ];
          modules-right = [ 
            "wireplumber"
            "network" 
            "cpu" 
            "memory" 
            "temperature"
            "disk"
            "battery" 
            "tray" 
          ];

          # Workspace configuration
          "sway/workspaces" = {
            disable-scroll = false;
            all-outputs = true;
            format = "{name}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              urgent = "";
              default = "";
            };
          };

          # Sway mode (resize, etc.)
          "sway/mode" = {
            format = "<span style=\"italic\">{}</span>";
          };

          # Active window title
          "sway/window" = {
            max-length = 50;
          };

          # Clock
          clock = {
            timezone = "Europe/Stockholm";
            format-alt = " {:%a %d %b  %H:%M}";
            format = " {:%Y-%m-%d}";
            tooltip = false;
          };

          # CPU
          cpu = {
            format = "󰻠 {usage}%";
            tooltip = false;
          };

          # Memory
          memory = {
            format = "󰍛 {}%";
          };

          # Temperature
          temperature = {
            critical-threshold = 80;
            format = "{icon} {temperatureC}°C";
            format-icons = [ "󱃃" "󰔏" "󱃂" ];
          };

          # Disk
          disk = {
            interval = 30;
            format = "󰋊 {percentage_used}%";
            path = "/";
          };

          # Battery
          battery = {
            states = {
              warning = 25;
              critical = 10;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰂄 {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          };

          # Network
          network = {
            format-wifi = "󰖩 {essid} ({signalStrength}%)";
            format-ethernet = "󰈀 {ipaddr}/{cidr}";
            tooltip-format = " {ifname} via {gwaddr}";
            format-linked = " {ifname} (No IP)";
            format-disconnected = " Disconnected";
            format-alt = " {ifname}: {ipaddr}/{cidr}";
          };

          # WirePlumber (PipeWire)
          wireplumber = {
            format = "{icon} {volume}%";
            format-muted = " {volume}%";
            format-icons = [ "" "" ];
            on-click = "pavucontrol";
          };

          # System tray
          tray = {
            spacing = 15;
          };
        };
      };

      style = ''
        * {
            border: none;
            border-radius: 0;
            font-family: "JetBrainsMono Nerd Font Mono";
            font-size: 13px;
            min-height: 0;
        }

        window#waybar {
            background-color: rgba(0, 0, 0, 0.0);
            color: #eceff4;
            transition-property: background-color;
            transition-duration: .5s;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }

        #workspaces button {
            padding: 0 8px;
            background-color: transparent;
            color: #d8dee9;
            border-bottom: 3px solid transparent;
        }

        #workspaces button:hover {
            background: #3b4252;
            box-shadow: inherit;
        }

        #workspaces button.focused {
            background-color: #434c5e;
            color: #88c0d0;
            border-bottom: 3px solid #88c0d0;
        }

        #workspaces button.urgent {
            background-color: #bf616a;
            color: #eceff4;
        }

        #mode {
            background-color: rgba(0, 0, 0, 0);
            color: #bf616a;
            padding: 0 10px;
            margin: 0 5px;
        }

        #window {
            padding: 0 10px;
            color: #d8dee9;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #disk,
        #backlight,
        #network,
        #wireplumber,
        #tray {
            padding: 0 5px;
            margin: 0 3px;
            color: #eceff4;
            background-color: rgba(0, 0, 0, 0);
        }

        #clock {
            color: #88c0d0;
            font-weight: bold;
            padding: 0 15px;
        }

        #battery {
            color: #a3be8c;
        }

        #battery.charging {
            color: #a3be8c;
        }

        #battery.warning:not(.charging) {
            color: #ebcb8b;
        }

        #battery.critical:not(.charging) {
            color: #bf616a;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        @keyframes blink {
            to {
                color: #d08770;
            }
        }

        #cpu {
            color: #8fbcbb;
        }

        #memory {
            color: #b48ead;
        }

        #temperature {
            color: #d08770;
        }

        #temperature.critical {
            color: #bf616a;
        }

        #disk {
            color: #ebcb8b;
        }

        #backlight {
            color: #a3be8c;
        }

        #network {
            color: #81a1c1;
        }

        #network.disconnected {
            color: #bf616a;
        }

        #wireplumber {
            color: #88c0d0;
        }

        #wireplumber.muted {
            color: #4c566a;
        }

        #tray {
            padding: 0 10px 0 5px;
        }

        #tray > .passive {
            -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
            -gtk-icon-effect: highlight;
            color: #bf616a;
        }
      '';
    };

    # Enable required system packages
    home.packages = with pkgs; [
      pavucontrol
    ];
  };
}