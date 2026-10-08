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

    # Cap the TTM WC/UC page pool at ~2G (524288 pages * 4K) so amdgpu can't
    # hoard idle system RAM in this cache -- it was observed holding ~7.5G
    # idle after GPU-heavy workloads (e.g. video calls), leaving too little
    # headroom and causing swap thrashing.
    boot.kernelParams = [
      "ttm.pages_limit=524288"
      "ttm.page_pool_size=524288"
    ];

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