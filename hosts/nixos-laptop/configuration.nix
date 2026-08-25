# hosts/nixos-laptop/configuration.nix

{ config, pkgs, pkgs-unstable, inputs, variables, ... }: {

  # Disko disk configuration (enable only during fresh install)
  diskoConfig = {
    enable = true;
    device = "/dev/nvme0n1";
    encryption.enable = true;
    swapSize = "16G";
  };

  # GRUB theme (colors driven by variables.theme)
  grub.theme.enable = true;

  # Fingerprint reader (06cb:00bd Synaptics Prometheus — built-in libfprint driver, no TOD needed)
  services.fprintd.enable = true;

  # TPM2 LUKS unlock (see docs/installation.md for one-time enrolment)
  tpm2Unlock.enable = true;

  # Ryzen 3000 APU quirks
  boot.kernelParams = [ "idle=nomwait" "iommu=soft" ];

  # Hostname
  networking.hostName = "nixos-laptop";

  # Desktop environment
  hyprland.enable = true;

  # Enabling virtualisation for the system
  virtualisation.enable = true;
  docker.enable = true;

  # Graphics drivers
  amd-graphics.enable = true;
  steam.enable = true;
  gamemode.enable = true;

  # Metasploit database (used with cyber.enable)
  metasploit-db.enable = true;


  networking.firewall.allowedTCPPorts = [ 9090 53317 ];
  # DHCP (67) and DNS (53) for NetworkManager hotspot clients; 53317 for LocalSend
  networking.firewall.allowedUDPPorts = [ 53 67 53317 ];

  # Declarative hotspot profile — autoconnect is always false so it never
  # starts on boot. Toggle via HyprPanel dashboard or `nmcli connection up Hotspot`.
  # PSK is injected from /etc/NetworkManager/hotspot.env (not in the Nix store).
  # Create that file manually: HOTSPOT_PSK=<password>
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ "/etc/NetworkManager/hotspot.env" ];
    profiles."Hotspot" = {
      connection = {
        id             = "Hotspot";
        type           = "wifi";
        interface-name = "wlp1s0";
        autoconnect    = "false";
      };
      wifi = {
        mode = "ap";
        ssid = "Jacks Laptop";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk      = "$HOTSPOT_PSK";
      };
      ipv4.method = "shared";
      ipv6.method = "ignore";
    };
  };

  # Battery charge thresholds — keeps battery between 80–90% when plugged in.
  # START=80 ensures the EC starts a charge cycle at 79%, so UPower reports
  # 'charging' (not 'pending-charge') and HyprPanel shows the charging icon.
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 80;
      STOP_CHARGE_THRESH_BAT0  = 90;
    };
  };

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
