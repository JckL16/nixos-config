{ pkgs, lib, config, ... }: {

  options = {
    amd-graphics.enable = 
      lib.mkEnableOption "Enable amd graphics";
  };

  config = lib.mkIf config.amd-graphics.enable {

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];

    boot.initrd.kernelModules = [ "amdgpu" ];

    environment.variables = {
      AMD_VULKAN_ICD = "RADV";

      RADV_DEBUG = "nodcc,nogpl";
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