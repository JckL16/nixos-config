# modules/nixos/programs/gamemode.nix

{ pkgs, lib, config, variables, ... }: {
  options = {
    gamemode.enable = 
      lib.mkEnableOption "Enable GameMode system configuration";
  };
  
  config = lib.mkIf config.gamemode.enable {
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      
      settings = {
        general = {
          # Desired CPU governor (performance, powersave, etc.)
          defaultgov = "performance";
          
          # CPU governor to use when gamemode is active
          desiredgov = "performance";
          
          # Renice game processes (lower = higher priority, -20 to 19)
          renice = 10;
        };
        
        # GPU optimizations
        gpu = {
          # Apply GPU optimizations (requires accepting responsibility)
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 1;  # FIXED: Changed from 0 to 1 for your GPU
          amd_performance_level = "high";
        };
        
        # CPU-specific optimizations
        cpu = {
          # Park CPU cores (0 = don't park any)
          park_cores = "no";
          
          # Pin game threads to specific cores
          pin_cores = "no";
        };
        
        # Custom scripts
        custom = {
          # Script to run when gamemode starts
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimizations activated' -i applications-games";
          
          # Script to run when gamemode ends
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimizations deactivated' -i applications-games";
        };
      };
    };
    
    # System packages
    environment.systemPackages = with pkgs; [
      gamemode
    ];
    
    services.dbus.packages = [ pkgs.gamemode ];
    
    users.groups.gamemode = {};
  };
}