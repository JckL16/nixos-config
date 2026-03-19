# modules/nixos/programs/veracrypt.nix

{ pkgs, lib, config, ... }: {

  options = {
    veracrypt.enable = lib.mkEnableOption "VeraCrypt disk encryption tool";
  };

  config = lib.mkIf config.veracrypt.enable {
    environment.systemPackages = with pkgs; [
      veracrypt
    ];

    # FUSE support for mounting encrypted volumes
    programs.fuse.userAllowOther = true;

    # Security wrapper for GUI mounting without sudo
    security.wrappers.veracrypt = {
      source = "${pkgs.veracrypt}/bin/veracrypt";
      owner = "root";
      group = "root";
      setuid = true;
    };
  };

}
