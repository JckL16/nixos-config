# hosts/nixos-desktop/configuration.nix

{ config, pkgs, pkgs-unstable, inputs, variables, ... }: {

  # Disko disk configuration (enable only during fresh install)
  diskoConfig = {
    enable = true;
    device = "/dev/nvme0n1";
    encryption.enable = true;
    swapSize = "32G";
  };

  networking.firewall.allowedTCPPorts = [ 8080 8443 ];

  # MGMT VLAN (tagged on the physical NIC)
  #
  # Static, not DHCP: the route below's gateway (10.0.99.1) is on this same
  # subnet, and the route-add runs synchronously when the interface is
  # created -- with DHCP, dhcpcd hasn't acquired a lease yet at that point,
  # so the kernel has no on-link address for 10.0.99.0/24 and the route
  # fails ("Nexthop has invalid gateway"). A static address is assigned in
  # the same unit, before the route line runs, so it's always in place.
  networking.vlans.mgmt = {
    id = 99;
    interface = "enp4s0";
  };
  networking.interfaces.mgmt.ipv4.addresses = [
    { address = "10.0.99.50"; prefixLength = 24; }
  ];

  networking.interfaces.mgmt.ipv4.routes = [
    { address = "10.0.30.0"; prefixLength = 24; via = "10.0.99.1"; }
  ];

  # In case NetworkManager auto-picks up the new vlan interface and fights
  # the static config above -- harmless if NM isn't managing this machine.
  networking.networkmanager.unmanaged = [ "mgmt" ];

  # Enable emulation of ARM systems
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # GRUB theme (colors driven by variables.theme)
  grub.theme.enable = true;

  # Hostname
  networking.hostName = "nixos-desktop";

  # Desktop environment
  hyprland.enable = true;
  printing.enable = true;

  # Graphics drivers
  amd-graphics.enable = true;

  # Gaming
  steam.enable = true;
  gamemode.enable = true;
  # Makes sure gamemode can see the GPU on my desktop
  programs.gamemode.settings.gpu.gpu_device = 1;

  # Metasploit database (used with cyber.enable)
  metasploit-db.enable = true;

  winbox.enable = true;
  ventoy.enable = true;

  virtualisation.enable = true;   # libvirt/QEMU KVM
  docker.enable = true;

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs variables pkgs-unstable;
    };
    users."${variables.username}" = {
      imports = [
        ./home.nix
        inputs.self.outputs.homeModules.default
      ];
    };
  };

}
