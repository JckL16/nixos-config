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

      gnumake
      pkg-config
      

      gcc
      

      cmake
      ninja
      meson
      autoconf
      automake
      libtool
      

      gdb
      valgrind
      lldb
      strace

      clang-tools
      

      boost
      fmt
      spdlog
      catch2
      gtest
    ];
    

    home.sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/pkgconfig";
    };
  };
}
