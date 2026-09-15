{ lib, variables, config, ... }:

let
  cfg = config.smbMounts;

  mountSubmodule = { name, ... }: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to automount this share.";
      };

      server = lib.mkOption {
        type = lib.types.str;
        example = "//nas.lan/share";
        description = "SMB server and share, in //host/share form.";
      };

      mountPoint = lib.mkOption {
        type = lib.types.str;
        default = "/home/${variables.username}/${name}";
        description = "Local path the share is mounted at.";
      };

      credentialsFile = lib.mkOption {
        type = lib.types.str;
        default = "/etc/nixos/secrets/smb-${name}-credentials";
        description = ''
          Path to a mount.cifs credentials file (mode 600, root-owned),
          created manually and never committed to git. Format:
            username=myuser
            password=mypassword
            domain=WORKGROUP
        '';
      };

      uid = lib.mkOption {
        type = lib.types.str;
        default = variables.username;
        description = "User (name or numeric uid) that owns files on the mount.";
      };

      gid = lib.mkOption {
        type = lib.types.str;
        default = "users";
        description = "Group (name or numeric gid) that owns files on the mount.";
      };

      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra mount options, e.g. [ \"vers=3.0\" ].";
      };
    };
  };
in
{
  options.smbMounts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule mountSubmodule);
    default = { };
    description = "SMB/CIFS network shares to automount, keyed by a short name.";
  };

  config = {
    fileSystems = lib.mkMerge (
      lib.mapAttrsToList
        (_: m: lib.mkIf m.enable {
          "${m.mountPoint}" = {
            device = m.server;
            fsType = "cifs";
            options = [
              "credentials=${m.credentialsFile}"
              "uid=${m.uid}"
              "gid=${m.gid}"
              "noauto"
              "x-systemd.automount"
              "x-systemd.idle-timeout=60"
              "x-systemd.device-timeout=5s"
              "x-systemd.mount-timeout=5s"
              "x-systemd.mkdir"
              "_netdev"
            ] ++ m.extraOptions;
          };
        })
        cfg
    );
  };
}
