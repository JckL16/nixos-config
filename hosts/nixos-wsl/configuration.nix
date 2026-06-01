# hosts/nixos-wsl/configuration.nix

{ config, pkgs, pkgs-unstable, inputs, variables, ... }: {

  wsl = {
    enable = true;
    defaultUser = variables.username;
    startMenuLaunchers = true;
    wslConf.automount.root = "/mnt";
  };

  # Hostname
  networking.hostName = "nixos-wsl";

  # Disabled - not applicable to WSL
  audio.enable = false;
  bluetooth.enable = false;
  grub.enable = false;
  yubikey.enable = false;

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
        inputs.self.outputs.homeManagerModules.default
      ];
    };
  };

}
