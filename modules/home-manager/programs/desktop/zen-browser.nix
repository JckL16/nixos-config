# modules/home-manager/programs/desktop/zen-browser.nix

{ pkgs, lib, config, inputs, ... }: {

  options = {
    zen-browser.enable =
      lib.mkEnableOption "Enable Zen Browser";
  };

  config = lib.mkIf config.zen-browser.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "zen-beta.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/about" = "zen-beta.desktop";
        "x-scheme-handler/unknown" = "zen-beta.desktop";
        "application/pdf" = "zen-beta.desktop";
      };
    };
  };

}
