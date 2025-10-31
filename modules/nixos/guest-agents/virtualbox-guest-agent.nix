# modules/nixos/guest-agents/virtualbox-guest-agent.nix

{ pkgs, lib, config, ... }: {

  options = {
    virtualbox-guest-agent.enable = 
      lib.mkEnableOption "Enable the virtualbox guest agent";
  };

  config = lib.mkIf config.virtualbox-guest-agent.enable {
    virtualisation.virtualbox.guest.enable = true;
  };
  
}
