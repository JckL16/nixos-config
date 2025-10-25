# modules/home-manager/desktop/shared/default.nix

{ ... }: {
  
  imports = [
    ./sway.nix
    ./waybar.nix
    ./kanshi.nix
  ];

}