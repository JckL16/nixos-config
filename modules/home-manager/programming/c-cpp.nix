{ config, lib, pkgs, ... }: {
  options.c-cpp = {
    enable = mkEnableOption "C/C++ development environment";

    compiler = mkOption {
      type = types.enum [ "gcc" "clang" "both" ];
      default = "both";
      description = "Which C/C++ compiler to use";
    };

    includeDebugTools = mkOption {
      type = types.bool;
      default = true;
      description = "Include debugging tools like gdb and valgrind";
    };

    includeBuildTools = mkOption {
      type = types.bool;
      default = true;
      description = "Include build tools like cmake, make, and ninja";
    };

    includeLibraries = mkOption {
      type = types.bool;
      default = true;
      description = "Include common C/C++ libraries";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to include in the environment";
    };
  };

  config = mkIf config.c-cpp.enable {
    home.packages = with pkgs; [
      # Compiler(s)
      (mkIf (config.c-cpp.compiler == "gcc" || config.c-cpp.compiler == "both") gcc)
      (mkIf (config.c-cpp.compiler == "clang" || config.c-cpp.compiler == "both") clang)
      (mkIf (config.c-cpp.compiler == "clang" || config.c-cpp.compiler == "both") llvm)
      
      # Build essentials
      gnumake
      pkg-config
      
      # Build tools
    ] ++ optionals config.c-cpp.includeBuildTools [
      cmake
      ninja
      meson
      autoconf
      automake
      libtool
    ] ++ optionals config.c-cpp.includeDebugTools [
      gdb
      valgrind
      lldb
      strace
    ] ++ optionals config.c-cpp.includeLibraries [
      # Common libraries
      boost
      fmt
      spdlog
      catch2
      gtest
    ] ++ config.c-cpp.extraPackages;

    # Set up environment variables
    home.sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/pkgconfig";
    };
  };
}