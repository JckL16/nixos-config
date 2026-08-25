# modules/home-manager/desktop/hyprland/gtk-theme.nix
#
# GTK/cursor/Qt theming and wallpaper generation.
# All values come from config.theme.* which is driven by variables.theme.

{ pkgs, lib, config, ... }:
let
  c = config.theme.colors;
  g = config.theme.gtk;

  # Generate a radial-gradient wallpaper at Nix build time using theme colors.
  # The center is slightly lighter (surface) fading to background at the edges,
  # giving a subtle vignette that looks good on all themes.
  generatedWallpaper = pkgs.runCommand "theme-wallpaper" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    ${pkgs.imagemagick}/bin/convert \
      -size 1920x1080 \
      radial-gradient:"${c.surface}"-"${c.background}" \
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

      # Override popup/context menu styling so systray right-click menus
      # match the HyprPanel dropdown look (rounded, glassy).
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

    # Wallpaper generated from theme colors; swaybg and hyprlock both read this path.
    home.file.".config/wallpapers/wallpaper.png".source = generatedWallpaper;

    home.packages = [
      pkgs.${g.themePackage}
      pkgs.${g.iconThemePackage}
      pkgs.${g.cursorPackage}
    ];
  };
}
