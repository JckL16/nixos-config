# modules/nixos/hardware/tpm2-unlock.nix

{ lib, config, ... }: {

  options.tpm2Unlock.enable = lib.mkEnableOption "TPM2-backed automatic LUKS unlock";

  config = lib.mkIf (config.tpm2Unlock.enable && config.diskoConfig.encryption.enable) {
    boot.initrd.systemd.enable = true;
    boot.initrd.luks.devices.${config.diskoConfig.encryption.luksName}.crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-pcrs=0+7"
    ];
  };
}
