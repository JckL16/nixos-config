# modules/home-manager/desktop-env/sway/kanshi.nix

{ pkgs, lib, config, ... }: 

let
  kanshiConfig = ''
    # Single laptop screen
    profile laptop {
      output * enable
    }

    # Docked setup - laptop + external
    profile docked {
      output * enable
    }

    # External only
    profile external-only {
      output * enable
    }
  '';
in
{
  
  config = lib.mkIf config.sway.enable {
    systemd.user.services.kanshi = {
      Unit = {
        Description = "Kanshi output autoconfig daemon";
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kanshi}/bin/kanshi";
        Restart = "on-failure";
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    
    xdg.configFile."kanshi/config".text = kanshiConfig;
    
    home.packages = with pkgs; [
      kanshi
    ];
  };
}