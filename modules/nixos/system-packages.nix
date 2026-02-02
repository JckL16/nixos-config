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
    procps
    texinfo
    tldr
    tree
    unzip
    util-linux
    vim
    wget
    zip
    coreutils
    nerd-fonts.jetbrains-mono
    gnumake
    openssl
    python3
    ncdu
  ];

  programs.direnv.enable = true;

  programs.zsh.enable = true;
  programs.bash.enable = true;

  environment.variables.EDITOR = "nvim";
  
}
