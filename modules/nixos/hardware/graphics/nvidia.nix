# modules/nixos/graphics/nvidia.nix
{ pkgs, lib, config, ... }: {
  options = {
    nvidia-graphics.enable =
      lib.mkEnableOption "Enable nvidia graphics";
  };
  
  config = lib.mkIf config.nvidia-graphics.enable {
    # Enable graphics (hardware.opengl is deprecated, use hardware.graphics)
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # For 32-bit applications
    };
    
    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];
    
    # NVIDIA-specific configuration
    hardware.nvidia = {
      # Modesetting is required for Wayland compositors
      modesetting.enable = true;
      
      # Enable power management (experimental, can cause sleep/suspend issues)
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      
      # Use the open source kernel module (not nouveau)
      # Only available from driver 515.43.04+
      # Set to false if experiencing issues
      open = false;
      
      # Enable the Nvidia settings menu
      nvidiaSettings = true;
      
      # Optionally, select the driver version
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    
    # Load NVIDIA driver early
    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
    
    # Ensure nvidia-drm.modeset=1 is set
    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  };
}