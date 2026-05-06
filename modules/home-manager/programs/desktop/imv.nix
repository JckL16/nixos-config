# modules/home-manager/programs/desktop/imv.nix

{ pkgs, lib, config, ... }: {

  options = {
    imv.enable = lib.mkEnableOption "Enable imv image viewer";
  };

  config = lib.mkIf config.imv.enable {
    home.packages = [ pkgs.imv ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg"            = "imv.desktop";
        "image/png"             = "imv.desktop";
        "image/gif"             = "imv.desktop";
        "image/webp"            = "imv.desktop";
        "image/avif"            = "imv.desktop";
        "image/bmp"             = "imv.desktop";
        "image/tiff"            = "imv.desktop";
        "image/svg+xml"         = "imv.desktop";
        "image/x-portable-bitmap" = "imv.desktop";
      };
    };
  };

}
