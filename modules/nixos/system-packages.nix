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
    neofetch
    neovim
    procps
    texinfo
    tldr
    tree
    unzip
    util-linux
    vim
    vscode
    wget
    zip
    nurl
  ];

  programs.zsh.enable = true;

}