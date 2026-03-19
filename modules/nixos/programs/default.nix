{ ... }: {

  imports = [
    ./gamemode.nix
    ./steam.nix
    ./virtualisation.nix
    ./winbox.nix
    ./docker.nix
    ./metasploit-db.nix
    ./yubikey.nix
    ./veracrypt.nix
  ];

}
