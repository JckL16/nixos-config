# modules/nixos/programs/ventoy.nix

{ pkgs, lib, config, ... }: {

  options = {
    ventoy.enable = lib.mkEnableOption "Ventoy bootable USB drive tool";
  };

  config = lib.mkIf config.ventoy.enable {
    environment.systemPackages = with pkgs; [
      ventoy-full
    ];

    # ventoy uses binary blobs flagged as insecure; explicitly opt in
    nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.12" ];
  };

}
