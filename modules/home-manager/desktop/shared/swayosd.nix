# modules/home-manager/shared/swayosd.nix

{ pkgs, lib, config, ... }: {

  config = lib.mkIf (config.sway.enable || config.hyprland.enable) {
    home.packages = with pkgs; [
      swayosd
    ];

    home.file.".config/swayosd/style.css".text = ''
      window {
        border-radius: 12px;
        background-color: rgba(46, 52, 64, 0.85);
        border: 2px solid rgba(76, 86, 106, 0.6);
      }

      #level {
        background-color: rgba(76, 86, 106, 0.4);
        border-radius: 8px;
      }

      #level trough {
        background-color: rgba(59, 66, 82, 0.3);
        border-radius: 8px;
      }

      #level progress {
        background-color: rgba(136, 192, 208, 0.8);
        border-radius: 8px;
      }

      label {
        color: rgb(216, 222, 233);
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
        font-weight: bold;
      }
    '';

  };
}