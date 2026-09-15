{ pkgs, pkgs-unstable, lib, config, ... }: {

  options = {
    obsidian.enable = lib.mkEnableOption "Enable Obsidian note-taking application";
  };

  config = lib.mkIf config.obsidian.enable {
    home.packages = [

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
