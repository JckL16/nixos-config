# modules/home-manager/cyber/default.nix

{ pkgs, lib, config, ... }: {
  options = {
    cyber.all = 
      lib.mkEnableOption "Enable all cyber security modules";
    
    cyber.forensics = 
      lib.mkEnableOption "Enable forensics tools";
    
    cyber.binary-exploitation = 
      lib.mkEnableOption "Enable binary exploitation tools";
    
    cyber.cryptography = 
      lib.mkEnableOption "Enable cryptography tools";
    
    cyber.general = 
      lib.mkEnableOption "Enable general CTF skills tools";
    
    cyber.reverse-engineering = 
      lib.mkEnableOption "Enable reverse engineering tools";
    
    cyber.web-exploitation = 
      lib.mkEnableOption "Enable web exploitation tools";
  };
  
  imports = [
    ./forensics.nix
    ./binary-exploitation.nix
    ./cryptography.nix
    ./general.nix
    ./reverse-engineering.nix
    ./web-exploitation.nix
  ];
  
  config = {
    # Pass through to individual modules
    forensics.enable = lib.mkIf (config.cyber.all || config.cyber.forensics) true;
    binary-exploitation.enable = lib.mkIf (config.cyber.all || config.cyber.binary-exploitation) true;
    cryptography.enable = lib.mkIf (config.cyber.all || config.cyber.cryptography) true;
    general.enable = lib.mkIf (config.cyber.all || config.cyber.general-skills) true;
    reverse-engineering.enable = lib.mkIf (config.cyber.all || config.cyber.reverse-engineering) true;
    web-exploitation.enable = lib.mkIf (config.cyber.all || config.cyber.web-exploitation) true;
  };
}
