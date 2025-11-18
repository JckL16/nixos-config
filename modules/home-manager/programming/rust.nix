# modules/home-manager/programming/rust.nix

{ pkgs, config, lib, ... }: {

  options = {
    rust.enable = 
      lib.mkEnableOption "Enable rust";
  };

  config = lib.mkIf config.rust.enable {
    home.packages = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      gcc
    ];

    home.sessionPath = [
      "$HOME/.cargo/bin"
    ];
  };
}
