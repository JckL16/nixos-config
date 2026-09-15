{ pkgs, lib, config, ... }: {
  options = {
    steam.enable = 
      lib.mkEnableOption "Enable Steam home-manager configuration";
  };
  
  config = lib.mkIf config.steam.enable {

    home.packages = with pkgs; [

      protonup-qt
      protontricks
      winetricks
      

      gamescope
      mangohud
      

      vulkan-tools
      vulkan-loader
      vulkan-validation-layers
    ];
    

    home.sessionVariables = {
      WINE_VK_USE_FSR = "1";
      STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
    };
    

    programs.mangohud = {
      enable = true;
      settings = {

        fps = true;
        frame_timing = true;
        cpu_temp = true;
        gpu_temp = true;
        

        cpu_stats = true;
        gpu_stats = true;
        ram = true;
        vram = true;
        

        vulkan_driver = true;
        engine_version = true;
        

        gamemode = lib.mkIf config.gamemode.enable true;
        

        position = "top-left";
        background_alpha = 0.5;
        font_size = 24;
        

        gl_vsync = 0;
      };
    };
    

    home.shellAliases = {

      steam-gamescope = "gamescope -f -W 2560 -H 1440 -- steam";
      

      vulkan-test = "vulkaninfo | grep -i 'device name'";
      vulkan-cube = "vkcube";
      

      proton-update = "protonup-qt";
    };
    

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/steam" = "steam.desktop";
      };
    };
  };
}