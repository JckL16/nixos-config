# modules/home-manager/picom.nix

{ pkgs, lib, config, ... }: {
  options = {
    picom.enable = lib.mkEnableOption "Enable picom";
  };

  config = lib.mkIf config.picom.enable {
    home.packages = with pkgs; [
      (picom.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "ornfelt";
          repo = "picom-animations";
          rev = "e7b14886ae644aaa657383f7c4f44be7797fd5f6";
          hash = "sha256-YQVp5HicO+jbvCYSY+hjDTnXCU6aS3aCvbux6NFcJ/Y=";
        };
      }))
    ];

    xdg.configFile."picom/picom.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.config/picom/picom.conf;
      force = true;
    };
  };
}