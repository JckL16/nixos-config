{ pkgs, lib, variables, ... }: {
  
  imports = [
    ./locale.nix
    ./networking.nix
    ./nix-settings.nix
  ];

}