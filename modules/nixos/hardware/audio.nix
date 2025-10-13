# modules/nixos/audio.nix

{ pkgs, lib, config, ... }: {

  options = {
    audio.enable = 
      lib.mkEnableOption "Enable audio";
  };

  config = lib.mkIf config.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };
  
}