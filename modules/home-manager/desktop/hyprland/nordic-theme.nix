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
      
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
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

    home.sessionVariables = {
      GTK_THEME = "Nordic";
      QT_QPA_PLATFORM = "wayland";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    home.file = {
      ".config/wallpapers/wallpaper.png".source = ../../../../wallpaper/wallpaper.png;
    };

    home.packages = with pkgs; [
      nordic
      nordzy-cursor-theme
      papirus-icon-theme
    ];
  };
}