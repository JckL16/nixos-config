# hosts/nixos-rugged/home.nix

{ config, pkgs, pkgs-unstable, lib, ... }:
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

  hyprland.enable  = true;
  hyprland.battery = true;

  tmux.enable = true;

  programs.tui-do.enable = true;

  # Lid close does nothing
  wayland.windowManager.hyprland.settings.bindl = lib.mkForce [];

  # Enabled user specific configuration for gaming
  steam.enable = true;
  gamemode.enable = true;

  minecraft.enable = true;

  programs.zen-browser.enable = true;
  # Adopts the pre-existing (pre-declarative-management) profile directory
  # instead of letting home-manager create a fresh "default" one — keeps the
  # 1.1GB of real browsing data (bookmarks/history/logins/extensions) in
  # ~/.config/zen/6ucup768.Default Profile intact and still in use.
  programs.zen-browser.profiles.default = {
    name = "Default Profile";
    path = "6ucup768.Default Profile";
  };

  obsidian.enable = true;

  spotify.enable = true;

  python-dev.enable = true;
  python-dev.packages = [ "requests" "numpy" "pandas" "matplotlib" ];
  rust.enable = true;
  c-cpp.enable = true;
  go.enable = true;

  cyber.enable = true;

  virt-manager.enable = true;

  onlyoffice.enable = true;

  syncthing.enable = true;

  tailscale.enable = true;

  home.packages = with pkgs; [
    tectonic
    signal-desktop
    ttyper
    qbittorrent
    claude-code
    caligula
    ticktick
    vscode
    calibre
    ventoy-full
    tea
    readest
    riscv64-unknown-elf-toolchain # KTH system-security course (s3k)
    jellyfin-desktop
  ] ++ [
      pkgs-unstable.protonmail-desktop
    ];

}
