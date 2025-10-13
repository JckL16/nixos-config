{ config, pkgs, ... }:

{
  home.packages = [ pkgs.neofetch ];
  
  home.file.".config/neofetch/config.conf" = {
    text = ''
      # Neofetch config
      # See https://github.com/dylanaraps/neofetch/wiki/Customizing-Info

      print_info() {
          info title
          info underline

          prin "┌─────────\n Hardware Information \n─────────┐"
          info " ​ ​  OS" distro
          info " ​ ​  Host" model
          info " ​ ​  Kernel" kernel
          info " ​ ​  Uptime" uptime
          info " ​ ​  Packages" packages
          info " ​ ​  Shell" shell
          info " ​ ​  Resolution" resolution
          info " ​ ​  DE" de
          info " ​ ​  WM" wm
          info " ​ ​  WM Theme" wm_theme
          info " ​ ​  Theme" theme
          info " ​ ​  Icons" icons
          info " ​ ​  Terminal" term
          info " ​ ​  Terminal Font" term_font
          info " ​ ​  CPU" cpu
          info " ​ ​  GPU" gpu
          info " ​ ​  Memory" memory

          prin "└───────────────────────────────────┘"
      }

      # Title
      title_fqdn="off"

      # Kernel
      kernel_shorthand="on"

      # Distro
      distro_shorthand="off"
      os_arch="on"

      # Uptime
      uptime_shorthand="on"

      # Memory
      memory_percent="on"
      memory_unit="gib"

      # Packages
      package_managers="on"

      # Shell
      shell_path="off"
      shell_version="on"

      # CPU
      speed_type="bios_limit"
      speed_shorthand="on"
      cpu_brand="on"
      cpu_speed="on"
      cpu_cores="logical"
      cpu_temp="off"

      # GPU
      gpu_brand="on"
      gpu_type="all"

      # Resolution
      refresh_rate="on"

      # Gtk Theme / Icons / Font
      gtk_shorthand="off"
      gtk2="on"
      gtk3="on"

      # IP Address
      public_ip_host="http://ident.me"
      public_ip_timeout=2
      local_ip_interface=('auto')

      # Disk
      disk_show=('/')
      disk_subtitle="mount"
      disk_percent="on"

      # Song
      music_player="auto"
      song_format="%artist% - %album% - %title%"
      song_shorthand="off"

      # Text Colors (Nord palette - high contrast)
      # Using bright colors for readability on Nord background
      # Format: colors=(title @) (at symbol) (underline) (subtitle) (colon) (info)
      colors=(14 14 7 14 14 15)

      # Text Options
      bold="on"
      underline_enabled="on"
      underline_char="─"
      separator=":"

      # Color Blocks
      block_range=(0 15)
      color_blocks="on"
      block_width=3
      block_height=1
      col_offset="auto"

      # Progress Bars
      bar_char_elapsed="━"
      bar_char_total="─"
      bar_border="on"
      bar_length=15
      bar_color_elapsed="14"
      bar_color_total="8"

      # Backend Settings
      image_backend="ascii"
      image_source="auto"

      # Ascii Options
      ascii_distro="auto"
      ascii_colors=(14 12 7 6 15)
      ascii_bold="on"

      # Image Options
      image_loop="off"
      thumbnail_dir="''${XDG_CACHE_HOME:-''${HOME}/.cache}/thumbnails/neofetch"
      crop_mode="normal"
      crop_offset="center"
      image_size="auto"
      gap=3
      yoffset=0
      xoffset=0
      background_color=

      # Misc Options
      stdout="off"
    '';
    force = true;
  };
}