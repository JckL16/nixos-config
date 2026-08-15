# modules/home-manager/shared/nordic-theme.nix

{ pkgs, lib, config, ... }:
let
  c = config.theme.colors;
in {

  config = lib.mkIf config.hyprland.enable {
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

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      # Override popup/context menu styling globally so systray right-click
      # menus match the HyprPanel dropdown look (rounded, glassy).
      gtk3.extraCss = ''
        menu {
          background-color: rgba(${c.backgroundRgb}, 0.92);
          border-radius: 6px;
          border: 1px solid rgba(${c.borderRgb}, 0.5);
          padding: 4px;
          color: ${c.textBright};
        }

        menuitem {
          border-radius: 4px;
          padding: 5px 12px;
          color: ${c.textBright};
        }

        menuitem:hover {
          background-color: rgba(${c.backgroundAltRgb}, 0.85);
          color: ${c.textBright};
        }

        menuitem:disabled,
        menuitem:disabled label {
          color: rgba(${c.textDimRgb}, 0.4);
        }

        menu separator {
          background-color: rgba(${c.borderRgb}, 0.4);
          min-height: 1px;
          margin: 3px 6px;
        }
      '';
      
      gtk4.theme = config.gtk.theme;

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    home.pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 20;
      gtk.enable = true;
    };

    # Qt configuration for Wayland
    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "adwaita-dark";
    };

    home.sessionVariables = {
      GTK_THEME = "Nordic";
      GTK_ICON_THEME = "Papirus-Dark";
      QT_QPA_PLATFORM = "wayland";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    home.file = {
      ".config/wallpapers/wallpaper.png".source = ../../../../wallpaper/wallpaper.png;
    };

    home.packages = with pkgs; [
      nordic
      bibata-cursors
      papirus-icon-theme
    ];
  };
}