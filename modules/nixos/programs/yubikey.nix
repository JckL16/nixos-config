# modules/nixos/programs/yubikey.nix
{ pkgs, lib, config, ... }:
{
  options = {
    yubikey.enable = 
      lib.mkEnableOption "Make it possible to use yubikeys on the system";
  };
  
  config = lib.mkIf config.yubikey.enable {
    # Enable U2F/FIDO support for YubiKey
    hardware.gpgSmartcards.enable = true;
  
    # Ensure required packages are available
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      gnupg
      pinentry-curses  # For terminal pinentry
      openssh
    ];

    # Enable GPG agent with SSH support
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    # Enable pcscd service for smart card support
    services.pcscd.enable = true;
  
    # Enable udev rules for YubiKey
    services.udev.packages = [ 
      pkgs.yubikey-personalization 
      pkgs.libu2f-host  # Additional U2F support
    ];

  };
}
