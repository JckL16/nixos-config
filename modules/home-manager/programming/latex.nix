{ config, lib, pkgs, ... }:
let
  cfg = config.latex;
in
{
  options.latex = {
    enable = lib.mkEnableOption "LaTeX development environment";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (texlive.combine {
        inherit (texlive) scheme-medium titlesec enumitem microtype;
      })

      zathura
    ];
  };
}
