# modules/home-manager/programs/gaming/minecraft.nix
{ pkgs, lib, config, ... }: {
  options = {
    minecraft.enable = 
      lib.mkEnableOption "Enable minecraft";
  };
  
  config = lib.mkIf config.minecraft.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
