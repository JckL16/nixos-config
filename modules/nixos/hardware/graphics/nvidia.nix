{ pkgs, lib, config, ... }: {
  options = {
    nvidia-graphics.enable =
      lib.mkEnableOption "Enable nvidia graphics";
  };
  
  config = lib.mkIf config.nvidia-graphics.enable {

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    

    services.xserver.videoDrivers = [ "nvidia" ];
    

    hardware.nvidia = {

      modesetting.enable = true;
      

      powerManagement.enable = false;
      powerManagement.finegrained = false;
      

      open = false;
      

      nvidiaSettings = true;
      

    };
    

    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

    boot.kernelParams = [ "nvidia-drm.modeset=1" ];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
  };
}
