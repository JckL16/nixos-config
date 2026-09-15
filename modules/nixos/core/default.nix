{ pkgs, lib, variables, ... }: {

  imports = [
    ./locale.nix
    ./networking.nix
    ./nix-settings.nix
    ./garbage-collection.nix
  ];

  programs.nix-ld.enable = true;

  services.envfs.enable = true;

}