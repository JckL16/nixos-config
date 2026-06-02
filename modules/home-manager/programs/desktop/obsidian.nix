# modules/home-manager/programs/desktop/obsidian.nix

{ pkgs, pkgs-unstable, lib, config, ... }: {

  options = {
    obsidian.enable = lib.mkEnableOption "Enable Obsidian note-taking application";
  };

  config = lib.mkIf config.obsidian.enable {
    home.packages = [
      # pkgs-unstable is required for Obsidian 1.12+. That release switched to
      # PDF.js fetching PDFs via XHR from a vault-specific app:// subdomain;
      # nixpkgs 1.12.7 includes a CORS patch that registers the scheme
      # correctly. The 1.10.3 build in stable lacks this patch and renders
      # PDFs as a blank "0 of 0" viewer.
      # NIXOS_OZONE_WL is unset to force XWayland — the Wayland PDF renderer
      # was also black-screening before this fix was identified.
      (pkgs.symlinkJoin {
        name = "obsidian";
        paths = [ pkgs-unstable.obsidian ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/obsidian \
            --unset NIXOS_OZONE_WL
        '';
      })
    ];
  };

}
