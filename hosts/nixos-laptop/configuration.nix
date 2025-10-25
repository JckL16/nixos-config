# hosts/nixos-laptop/configuration.nix

{ config, pkgs, home-manager, inputs, variables, ... }: {
  
  imports = [
    ./samsung-laptop.nix
    home-manager.nixosModules.home-manager
  ];

  # Set to newest kernel to get the samsung-galaxy kernel working
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.systemd.enable = true;  # Use systemd in initrd for better compatibility
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-19" "-T0" ];

  # Hostname7
  networking.hostName = "nixos-laptop";

  # Desktop environment
  sway.enable = true;

  # Graphics drivers
  intel-graphics.enable = true;
  # steam.enable = true;

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { 
      inherit inputs variables;
      sway.enable = config.sway.enable;
    };
    users."${variables.username}" = {
      imports = [
        ./home.nix
        inputs.self.outputs.homeManagerModules.default
      ];
    };
  };

}
