# modules/home-manager/desktop/shared/default.nix

{ ... }: {
  
  imports = [
    ./mako.nix
    ./clipman.nix
    ./rofi.nix
    ./nordic-theme.nix
    ./swayosd.nix
  ];

}