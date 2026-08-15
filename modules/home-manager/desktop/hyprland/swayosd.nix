# modules/home-manager/shared/swayosd.nix

{ pkgs, lib, config, ... }:
let
  c = config.theme.colors;
  f = config.theme.font;
in {

  config = lib.mkIf config.hyprland.enable {
    home.packages = with pkgs; [
      swayosd
    ];

    home.file.".config/swayosd/style.css".text = ''
      window {
        border-radius: 12px;
        background-color: rgba(${c.backgroundRgb}, 0.85);
        border: 2px solid rgba(${c.borderRgb}, 0.6);
      }

      #level {
        background-color: rgba(${c.borderRgb}, 0.4);
        border-radius: 8px;
      }

      #level trough {
        background-color: rgba(${c.backgroundAltRgb}, 0.3);
        border-radius: 8px;
      }

      #level progress {
        background-color: rgba(${c.accentRgb}, 0.8);
        border-radius: 8px;
      }

      label {
        color: ${c.textDim};
        font-family: "${f.name}";
        font-size: 14px;
        font-weight: bold;
      }
    '';

  };
}