# modules/nixos/system-packages.nix

{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    acpi
    curl
    dex
    direnv
    dosfstools
    e2fsprogs
    git
    inetutils
    man-db
    man-pages
    neovim
    procps
    texinfo
    tldr
    tree
    unzip
    util-linux
    vim
    wget
    zip
  ];

  programs.zsh.enable = true;
  programs.bash.enable = true;

}