{ config, lib, pkgs, ... }:

let
  cfg = config.c-cpp;
in
{
  options.c-cpp = {
    enable = lib.mkEnableOption "C/C++ development environment";
    
    compiler = lib.mkOption {
      type = lib.types.enum [ "gcc" "clang" "both" ];
      default = "gcc";
      description = "Which C/C++ compiler to use";
    };
    
    includeDebugTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include debugging tools like gdb and valgrind";
    };
    
    includeBuildTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include build tools like cmake, make, and ninja";
    };
    
    includeLibraries = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include common C/C++ libraries";
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages to include in the environment";
    };
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Build essentials
      gnumake
      pkg-config
    ] 
    # Compiler selection
    ++ (if cfg.compiler == "gcc" then [ gcc ]
        else if cfg.compiler == "clang" then [ clang llvm ]
        else [ gcc clang-tools llvm ])  # For "both": gcc as default, clang-tools for clang features
    # Build tools
    ++ lib.optionals cfg.includeBuildTools [
      cmake
      ninja
      meson
      autoconf
      automake
      libtool
    ] 
    # Debug tools
    ++ lib.optionals cfg.includeDebugTools [
      gdb
      valgrind
      lldb
      strace
    ] 
    # Common libraries
    ++ lib.optionals cfg.includeLibraries [
      boost
      fmt
      spdlog
      catch2
      gtest
    ] 
    ++ cfg.extraPackages;
    
    # Set up environment variables
    home.sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/pkgconfig";
    };
  };
}