{ pkgs, lib, config, ... }: {

  options = {
    veracrypt.enable = lib.mkEnableOption "VeraCrypt disk encryption tool";
  };

  config = lib.mkIf config.veracrypt.enable {
    environment.systemPackages = with pkgs; [
      veracrypt
    ];

    programs.fuse.userAllowOther = true;

    security.wrappers.veracrypt = {
      source = "${pkgs.veracrypt}/bin/veracrypt";
      owner = "root";
      group = "root";
      setuid = true;
    };
  };

}
