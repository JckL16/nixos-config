# modules/nixos/guest-agents/qemu-guest-agent.nix

{ pkgs, lib, config, ... }: {

  options = {
    qemu-guest-agent.enable = 
      lib.mkEnableOption "Enable the qemu and spice guest agent";
  };

  config = lib.mkIf config.qemu-guest-agent.enable {
    # Enable QEMU Guest Agent for graceful shutdown and IP reporting
    services.qemuGuest.enable = true;

    # Enable Spice vdagent for clipboard sharing and resolution
    services.spice-vdagentd.enable = true;
  };
  
}
