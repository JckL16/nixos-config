{ pkgs, lib, config, ... }: {
  options = {
    garbage-collection.enable =
      lib.mkEnableOption "Enable garbage collection" // { default = true; };
    garbage-collection.keepGenerations = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = ''
        Maximum number of system generations to keep, enforced daily
        alongside the --delete-older-than age limit below. A generation
        is deleted once it falls outside the most recent N generations
        or past the age limit, whichever comes first -- this matters on
        hosts that rebuild several times a day, since age alone lets
        dozens of same-week generations accumulate.
      '';
    };
  };

  config = lib.mkIf config.garbage-collection.enable {

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    systemd.services.trim-system-generations = {
      description = "Trim system generations by count, then by age";
      serviceConfig.Type = "oneshot";
      path = [ config.nix.package ];
      script = ''
        nix-env -p /nix/var/nix/profiles/system --delete-generations +${toString config.garbage-collection.keepGenerations}
        nix-collect-garbage --delete-older-than 7d
      '';
    };

    systemd.timers.trim-system-generations = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}