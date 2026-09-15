{ pkgs, lib, config, ... }: {

  options = {
    ventoy.enable = lib.mkEnableOption "Ventoy bootable USB drive tool";
  };

  config = lib.mkIf config.ventoy.enable {
    environment.systemPackages = with pkgs; [
      ventoy-full
    ];

    nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.12" ];
  };

}
