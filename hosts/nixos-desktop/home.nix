# hosts/nixos-desktop/home.nix

{ config, pkgs, pkgs-unstable, ... }:
let
  # KTH system-security course (s3k) — remove once the course is done.
  # s3k expects riscv64-unknown-elf-*, nixpkgs' embedded cross-toolchain only
  # provides riscv64-none-elf-*; symlink the names it expects onto PATH.
  # Plain symlinks only (no share/, no nix-support/) so home-manager's
  # profile builder never sees the cross-gcc's docs and can't collide
  # with the native gcc's info registration (install-info START/END error).
  riscvCross = pkgs.pkgsCross.riscv64-embedded.buildPackages;
  riscv64-unknown-elf-toolchain = pkgs.runCommand "riscv64-unknown-elf-toolchain" { } ''
    mkdir -p $out/bin
    for f in ${riscvCross.gcc}/bin/riscv64-none-elf-* ${riscvCross.binutils}/bin/riscv64-none-elf-*; do
      name=$(basename "$f")
      ln -sf "$f" "$out/bin/riscv64-unknown-elf-''${name#riscv64-none-elf-}"
    done
  '';
in
{

  # Enabled the hyprland config for this user
  hyprland.enable = true;

  tmux.enable = true;

  programs.tui-do.enable = true;

  # Enabled user specific configuration for gaming
  steam.enable = true;
  gamemode.enable = true;
  minecraft.enable = true;

  programs.zen-browser.enable = true;

  obsidian.enable = true;

  spotify.enable = true;

  winbox.enable = true;

  rust.enable = true;
  python-dev.enable = true;
  python-dev.packages = [ "tqdm" ];
  go.enable = true;
  latex.enable = true;

  syncthing.enable = true;

  onlyoffice.enable = true;

  cyber.enable = true;

  virt-manager.enable = true;

  home.packages = with pkgs; [
    vscode
    discord-ptb
    caligula
    nmap
    nixos-anywhere
    jq
    signal-desktop
    qbittorrent
    claude-code
    minikube
    kubectl
    ticktick
    orca-slicer
    putty
    riscv64-unknown-elf-toolchain # KTH system-security course (s3k)
  ] ++ [
    pkgs-unstable.proton-pass
    pkgs-unstable.protonmail-desktop
  ];

}
