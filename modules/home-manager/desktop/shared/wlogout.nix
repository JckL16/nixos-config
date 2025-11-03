# modules/home-manager/desktop/shared/wlogout.nix

{ pkgs, lib, config, ... }: 

let
  # Create Nord-colored icons using ImageMagick at a specific size
  nordIcons = pkgs.runCommand "wlogout-nord-icons" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out/icons
    
    # Convert default wlogout icons to Nord gray color and resize to 48x48
    for icon in lock logout shutdown reboot; do
      if [ -f ${pkgs.wlogout}/share/wlogout/icons/$icon.png ]; then
        # Convert the icon: resize, make it grayscale, then tint it to Nord color
        convert ${pkgs.wlogout}/share/wlogout/icons/$icon.png \
          -resize 64x64 \
          -colorspace gray \
          -fill '#D8DEE9' -tint 100 \
          $out/icons/$icon.png
      fi
    done
  '';
in
{
  config = lib.mkIf (config.sway.enable || config.hyprland.enable) {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "${pkgs.swaylock-effects}/bin/swaylock -f -i ~/.config/wallpapers/wallpaper.png --effect-blur 7x5 --indicator --indicator-radius 100 --indicator-thickness 7 --ring-color 4c566aff --key-hl-color 88c0d0ff --bs-hl-color bf616aff --inside-color 2e344088 --ring-ver-color 5e81acff --inside-ver-color 2e344088 --ring-wrong-color bf616aff --inside-wrong-color 2e344088 --line-color 00000000 --separator-color 00000000 --clock --timestr '%H:%M:%S' --datestr '' --text-color eceff4ff --font 'JetBrainsMono Nerd Font' --font-size 24";
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
          font-family: "JetBrainsMono Nerd Font";
          font-size: 15px;
        }

        window {
          background-color: rgba(46, 52, 64, 0.85);
        }

        button {
          color: #D8DEE9;
          background-color: rgba(59, 66, 82, 0.7);
          border: 2px solid #4C566A;
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
          background-color: rgba(76, 86, 106, 0.8);
          color: #ECEFF4;
          border: 2px solid #88C0D0;
          outline-style: none;
        }

        #lock {
          background-image: image(url("${nordIcons}/icons/lock.png"));
        }

        #logout {
          background-image: image(url("${nordIcons}/icons/logout.png"));
        }

        #shutdown {
          background-image: image(url("${nordIcons}/icons/shutdown.png"));
        }

        #reboot {
          background-image: image(url("${nordIcons}/icons/reboot.png"));
        }
      '';
    };

    home.packages = with pkgs; [
      wlogout
      swaylock-effects
    ];
  };
}
