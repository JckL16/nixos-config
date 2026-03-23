{ pkgs, lib, variables, ... }: {

  imports = [
    ./locale.nix
    ./networking.nix
    ./nix-settings.nix
    ./swap-file.nix
    ./garbage-collection.nix
  ];

  # Run unpatched binaries with hardcoded library paths
  programs.nix-ld.enable = true;

  # Create /usr/bin entries for scripts with hardcoded shebangs (e.g., #!/usr/bin/perl)
  services.envfs.enable = true;

}