{ pkgs, lib, config, variables, ... }: {

  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" "ssh" ];
  };

  home.packages = with pkgs; [
    seahorse        # GUI for managing keyring
    libsecret       # provides secret-tool CLI
  ];
}