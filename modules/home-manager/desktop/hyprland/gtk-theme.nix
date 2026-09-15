{ pkgs, lib, config, ... }:
let
  c = config.theme.colors;
  g = config.theme.gtk;

  generatedWallpaper = pkgs.runCommand "theme-wallpaper" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    ${pkgs.imagemagick}/bin/convert \
      -size 1920x1080 \
      radial-gradient:"${c.surface}"-"${c.background}" \
      -attenuate 0.03 +noise Gaussian \
      PNG24:$out
  '';
in {

  config = lib.mkIf config.hyprland.enable {
    gtk = {
      enable = true;

      theme = {
        name    = g.themeName;
        package = pkgs.${g.themePackage};
      };

      iconTheme = {
        name    = g.iconThemeName;
        package = pkgs.${g.iconThemePackage};
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

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

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    home.pointerCursor = {
      name    = g.cursorName;
      package = pkgs.${g.cursorPackage};
      size    = g.cursorSize;
      gtk.enable = true;
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "adwaita-dark";
    };

    home.sessionVariables = {
      GTK_THEME              = g.themeName;
      GTK_ICON_THEME         = g.iconThemeName;
      QT_QPA_PLATFORM        = "wayland";
      QT_STYLE_OVERRIDE      = "adwaita-dark";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      MOZ_ENABLE_WAYLAND     = "1";
    };

    home.file.".config/wallpapers/wallpaper.png".source = generatedWallpaper;

    home.packages = [
      pkgs.${g.themePackage}
      pkgs.${g.iconThemePackage}
      pkgs.${g.cursorPackage}
    ];
  };
}
