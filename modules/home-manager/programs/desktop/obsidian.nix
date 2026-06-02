# modules/home-manager/programs/desktop/obsidian.nix

{ pkgs, lib, config, ... }: {

  options = {
    obsidian.enable = lib.mkEnableOption "Enable Obsidian note-taking application";
  };

  config = lib.mkIf config.obsidian.enable {
    home.packages = [
      # Unset NIXOS_OZONE_WL so Obsidian runs via XWayland instead of native
      # Wayland — the native Wayland Electron PDF renderer produces a black screen.
      (pkgs.symlinkJoin {
        name = "obsidian";
        paths = [ pkgs.obsidian ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/obsidian \
            --unset NIXOS_OZONE_WL
        '';
      })
    ];
  };

}
