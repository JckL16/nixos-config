{ pkgs, lib, config, ... }: {
  options = {
    onlyoffice.enable =
      lib.mkEnableOption "Enable the OnlyOffice desktop editors";
  };
  
  config = lib.mkIf config.onlyoffice.enable {
    home.packages = with pkgs; [
      onlyoffice-desktopeditors
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/msword" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.oasis.opendocument.text" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-excel" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-powerpoint" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.oasis.opendocument.presentation" = "onlyoffice-desktopeditors.desktop";
      };
    };
  };
}
