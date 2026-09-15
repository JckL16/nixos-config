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

          defaultgov = "performance";
          

          desiredgov = "performance";
          

          renice = 10;
        };
        

        gpu = {

          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 1;
          amd_performance_level = "high";
        };
        

        cpu = {

          park_cores = "no";
          

          pin_cores = "no";
        };
        

        custom = {

          start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimizations activated' -i applications-games";
          

          end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimizations deactivated' -i applications-games";
        };
      };
    };
    

    environment.systemPackages = with pkgs; [
      gamemode
    ];
    
    services.dbus.packages = [ pkgs.gamemode ];
    
    users.groups.gamemode = {};
    users.users."${variables.username}".extraGroups = [ "gamemode" ];
  };
}