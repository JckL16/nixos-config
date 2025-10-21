# modules/home-manager/programs/steam.nix

{ pkgs, lib, config, ... }: {

  options = {
    steam.enable = 
      lib.mkEnableOption "Enable Steam home-manager configuration";
  };

  config = lib.mkIf config.steam.enable {
    # Steam-related packages
    home.packages = with pkgs; [
      steam-run  # Run non-Steam games in Steam runtime
      steamcmd   # Steam command-line client
    ];

    # Environment variables for Steam/Proton gaming
    home.sessionVariables = {
      WINE_VK_USE_FSR = "1";
      STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
    };

    # Configure MangoHud
    programs.mangohud = {
      enable = true;
      settings = {
        # Performance metrics
        fps = true;
        frame_timing = true;
        cpu_temp = true;
        gpu_temp = true;
        
        # Resource usage
        cpu_stats = true;
        gpu_stats = true;
        ram = true;
        vram = true;
        
        # Vulkan-specific
        vulkan_driver = true;
        engine_version = true;
        
        # Position and style
        position = "top-left";
        background_alpha = 0.5;
        font_size = 24;
        
        # Wayland compatibility
        gl_vsync = 0;
      };
    };

    # Gaming-related shell aliases
    home.shellAliases = {
      # Launch Steam with optimizations
      steam-gamemode = "gamemoderun steam";
      steam-gamescope = "gamescope -f -W 2560 -H 1440 -- steam";  # Adjust resolution
      
      # Test Vulkan
      vulkan-test = "vulkaninfo | grep -i 'device name'";
      vulkan-cube = "vkcube";
      
      # Proton-GE management
      proton-update = "protonup-qt";
    };

    # XDG MIME types for Steam
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/steam" = "steam.desktop";
      };
    };
  };
}