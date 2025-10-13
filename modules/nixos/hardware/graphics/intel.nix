# modules/nixos/graphics/intel.nix

{ pkgs, lib, config, ... }: {

  options = {
    intel-graphics.enable = 
      lib.mkEnableOption "Enable intel graphics";
  };

  config = lib.mkIf config.intel-graphics.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
      ];
    };
    
    # Load Intel graphics driver early
    boot.initrd.kernelModules = [ "i915" ];
    
    # Enable GuC/HuC firmware loading (Gen 9+)
    boot.kernelParams = [ "i915.enable_guc=2" "i915.enable_fbc=1" ];
  };
  
}