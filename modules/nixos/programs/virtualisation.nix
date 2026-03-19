# modules/nixos/programs/virtualisation.nix

{ config, lib, pkgs, ... }:

{
  options = {
    virtualisation.enable = 
      lib.mkEnableOption "Enable libvirt and add user to the libvirtd group";
  };
  
  config = lib.mkIf config.virtualisation.enable {
    
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    # Enable default network automatically
    virtualisation.libvirtd.onBoot = "start";
    virtualisation.libvirtd.onShutdown = "shutdown";

    # Ensure the default NAT network starts automatically
    systemd.services.libvirtd-default-network = {
      description = "Autostart libvirt default NAT network";
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.libvirt}/bin/virsh net-autostart default || true
        ${pkgs.libvirt}/bin/virsh net-start default || true
      '';
    };

  };
}
