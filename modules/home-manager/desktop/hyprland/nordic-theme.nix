# modules/home-manager/shared/nordic-theme.nix

{ pkgs, lib, config, ... }: {

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
      # menus match the HyprPanel dropdown look (Nord colors, rounded, glassy).
      gtk3.extraCss = ''
        menu {
          background-color: rgba(46, 52, 64, 0.92);
          border-radius: 6px;
          border: 1px solid rgba(76, 86, 106, 0.5);
          padding: 4px;
          color: #ECEFF4;
        }

        menuitem {
          border-radius: 4px;
          padding: 5px 12px;
          color: #ECEFF4;
        }

        menuitem:hover {
          background-color: rgba(59, 66, 82, 0.85);
          color: #ECEFF4;
        }

        menuitem:disabled,
        menuitem:disabled label {
          color: rgba(216, 222, 233, 0.4);
        }

        menu separator {
          background-color: rgba(76, 86, 106, 0.4);
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