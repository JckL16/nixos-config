# modules/nixos/programs/steam.nix

{ pkgs, lib, config, ... }: {

  options = {
    steam.enable = 
      lib.mkEnableOption "Enable Steam with Proton and gaming support";
  };

  config = lib.mkIf config.steam.enable {
    # Enable Steam with all gaming features
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };

    # 32-bit graphics support (essential for most games)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Add gaming packages to system
    environment.systemPackages = with pkgs; [
      # Proton utilities
      protonup-qt
      protontricks
      winetricks
      
      # Gaming optimization
      gamemode
      gamescope
      mangohud
      
      # Vulkan support
      vulkan-tools
      vulkan-loader
      vulkan-validation-layers
    ];

    # Enable GameMode
    programs.gamemode.enable = true;
  };
}