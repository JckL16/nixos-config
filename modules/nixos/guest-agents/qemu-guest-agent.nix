{ pkgs, lib, config, ... }: {

  options = {
    qemu-guest-agent.enable = 
      lib.mkEnableOption "Enable the qemu and spice guest agent";
  };

  config = lib.mkIf config.qemu-guest-agent.enable {

    services.qemuGuest.enable = true;

    services.spice-vdagentd.enable = true;
  };
  
}
