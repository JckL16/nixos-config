{ pkgs, lib, config, ... }:
{
  options = {
    yubikey.enable = 
      lib.mkEnableOption "Make it possible to use yubikeys on the system";
  };
  
  config = lib.mkIf config.yubikey.enable {

    hardware.gpgSmartcards.enable = true;
  

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      gnupg
      pinentry-curses
      openssh
    ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    services.pcscd.enable = true;
  

    services.udev.packages = [ 
      pkgs.yubikey-personalization 
      pkgs.libu2f-host
    ];

  };
}
