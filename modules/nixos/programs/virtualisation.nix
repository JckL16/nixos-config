# modules/nixos/programs/virtualisation.nix

{ config, lib, pkgs, variables, ... }:

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

    # vagrant-libvirt checks standard distro paths that don't exist on NixOS.
    # OVMF_CODE satisfies the validation check and injects OVMF as pflash unit=0.
    # /run/libvirt/nix-ovmf/ is a stable symlink managed by NixOS — survives rebuilds.
    environment.sessionVariables = {
      VAGRANT_LIBVIRT_OVMF_CODE = "/run/libvirt/nix-ovmf/edk2-x86_64-code.fd";
    };

    # Enable default network automatically
    virtualisation.libvirtd.onBoot = "start";
    virtualisation.libvirtd.onShutdown = "shutdown";

    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      vagrant
      (ansible.overridePythonAttrs (old: {
        propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ python313Packages.pywinrm ];
      }))
    ];

    users.users."${variables.username}".extraGroups = [ "libvirtd" ];

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
