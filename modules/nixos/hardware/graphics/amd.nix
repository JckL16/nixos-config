# modules/nixos/graphics/amd.nix

{ pkgs, lib, config, ... }: {

  options = {
    amd-graphics.enable = 
      lib.mkEnableOption "Enable amd graphics";
  };

  config = lib.mkIf config.amd-graphics.enable {
    # Enable OpenGL/Graphics
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # AMD-specific packages
    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd  # OpenCL support
    ];

    # Load AMDGPU driver early
    boot.initrd.kernelModules = [ "amdgpu" ];

    # AMD-specific environment variables for gaming
    environment.variables = {
      AMD_VULKAN_ICD = "RADV";
      RADV_PERFTEST = "gpl,nggc";
    };

    environment.systemPackages = with pkgs; [
      mesa
      vulkan-tools
      lact
      clinfo
      radeontop
    ];

    services.lact.enable = true;
  };
  
}