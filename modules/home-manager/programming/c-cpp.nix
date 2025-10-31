{ config, lib, pkgs, ... }:
let
  cfg = config.c-cpp;
in
{
  options.c-cpp = {
    enable = lib.mkEnableOption "C/C++ development environment";
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Build essentials
      gnumake
      pkg-config
      
      # Compilers - gcc has priority, clang is secondary
      gcc
      
      # Build tools
      cmake
      ninja
      meson
      autoconf
      automake
      libtool
      
      # Debug tools
      gdb
      valgrind
      lldb
      strace
      
      # Common libraries
      boost
      fmt
      spdlog
      catch2
      gtest
    ];
    
    # Set up environment variables
    home.sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/pkgconfig";
    };
  };
}
