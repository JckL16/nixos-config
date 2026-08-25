# modules/home-manager/desktop/shared/wlogout.nix

{ pkgs, lib, config, variables, ... }:

let
  c = config.theme.colors;
  f = config.theme.font;
  iconSize = builtins.floor (64 * variables.displayScale);

  themedIcons = pkgs.runCommand "wlogout-themed-icons" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out/icons

    for icon in lock logout shutdown reboot; do
      if [ -f ${pkgs.wlogout}/share/wlogout/icons/$icon.png ]; then
        convert ${pkgs.wlogout}/share/wlogout/icons/$icon.png \
          -resize ${toString iconSize}x${toString iconSize} \
          -colorspace gray \
          -fill '${c.textDim}' -tint 100 \
          $out/icons/$icon.png
      fi
    done
  '';
in
{
  config = lib.mkIf config.hyprland.enable {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "pidof hyprlock || hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "logout";
          action = "hyprctl dispatch exit";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
      style = ''
        * {
          background-image: none;
          font-family: "${f.name}";
          font-size: 15px;
        }

        window {
          background-color: rgba(${c.backgroundRgb}, 0.85);
        }

        button {
          color: ${c.textDim};
          background-color: rgba(${c.backgroundAltRgb}, 0.7);
          border: 2px solid ${c.border};
          border-radius: 8px;
          background-repeat: no-repeat;
          background-position: center 40%;
          background-size: 15%;
          margin: 8px;
          padding-top: 7em;
          padding-bottom: 0.5em;
          padding-left: 0.5em;
          padding-right: 0.5em;
          min-width: 100px;
          min-height: 100px;
          transition: all 0.3s ease;
        }

        button:focus, button:active, button:hover {
          background-color: rgba(${c.borderRgb}, 0.8);
          color: ${c.textBright};
          border: 2px solid ${c.accent};
          outline-style: none;
        }

        #lock {
          background-image: image(url("${themedIcons}/icons/lock.png"));
        }

        #logout {
          background-image: image(url("${themedIcons}/icons/logout.png"));
        }

        #shutdown {
          background-image: image(url("${themedIcons}/icons/shutdown.png"));
        }

        #reboot {
          background-image: image(url("${themedIcons}/icons/reboot.png"));
        }
      '';
    };

    home.packages = with pkgs; [
      wlogout
    ];
  };
}
