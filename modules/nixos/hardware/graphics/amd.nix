# modules/nixos/graphics/amd.nix

{ pkgs, lib, config, ... }: {

  options = {
    amd-graphics.enable = 
      lib.mkEnableOption "Enable amd graphics";
  };

  config = lib.mkIf config.amd-graphics.enable {
    # Enable OpenGL/Graphics
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;  # For 32-bit applications
    };

    # AMD-specific packages
    hardware.opengl.extraPackages = with pkgs; [
      amdvlk           # Vulkan driver
      rocmPackages.clr.icd  # OpenCL support
    ];

    # For 32-bit Vulkan support (gaming, Wine, etc.)
    hardware.opengl.extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];

    # Load AMDGPU driver early
    boot.initrd.kernelModules = [ "amdgpu" ];
  };
  
}