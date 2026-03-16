# modules/nixos/core/nix-settings.nix

{ pkgs, ... }: {
  
  # Unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 128 * 1024 * 1024; # 128 MiB

}