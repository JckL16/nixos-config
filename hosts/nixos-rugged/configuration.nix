# hosts/nixos-rugged/configuration.nix
#

{ config, pkgs, pkgs-unstable, inputs, variables, ... }: {

  # Disko disk configuration (enable only during fresh install)
  diskoConfig = {
    enable = true;
    device = "/dev/nvme0n1";
    encryption.enable = true;
    swapSize = "16G";
  };

  networking.hostName = "nixos-rugged";

  # TPM2 LUKS unlock (see docs/installation.md for one-time enrolment)
  tpm2Unlock.enable = true;

  grub.theme.enable = true;
  boot.loader.grub.configurationLimit = 1; # 511M /boot can't fit 2 × 210M initrds during a switch

  hyprland.enable = true;
  printing.enable = true;

  greetd.enable = true;

  nvidia-graphics.enable = true;

  steam.enable = true;
  gamemode.enable = true;

  virtualisation.enable = true;   # libvirt/QEMU KVM
  docker.enable = true;

  metasploit-db.enable = true;    # PostgreSQL database for Metasploit

  # Firewall rules for spotify to be able to cast to google devices
  networking.firewall.allowedTCPPorts = [ 57621 9090 1337 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.12"
  ];

  programs.localsend.enable = true;

  # SMB share, only reachable on the kronan LAN; see docs/modules/applications.md
  # for how to create /etc/nixos/secrets/smb-kronan-share-credentials
  smbMounts.kronan-share = {
    server = "//smb.kronan.arpa/share";
    mountPoint = "/home/${variables.username}/kronan-mount";
  };

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
