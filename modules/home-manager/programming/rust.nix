# modules/home-manager/programming/rust.nix

{ pkgs, option, lib, ... }: {
  options = {
    rust.enable = 
      lib.mkEnableOption "Enable rust";
  };

  config = lib.mkIf config.rust.enable {
    home.packages = [
      pkgs.rustc
      pkgs.cargo
      pkgs.rustfmt
      pkgs.clippy
      pkgs.rust-analyzer
    ];
  };
}