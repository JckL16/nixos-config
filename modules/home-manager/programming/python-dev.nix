# modules/home-manager/programming/python-dev.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.python-dev;
in
{
  options.python-dev = {
    enable = lib.mkEnableOption "Python development environment";
    
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of Python package names to install (e.g., [\"requests\" \"numpy\" \"pandas\"])";
      example = [ "requests" "numpy" "pandas" "pytest" "black" ];
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional system packages to include in the environment";
    };
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; 
      let
        python = pkgs.python3;
        
        # Basic packages always included
        basicPythonPackages = ps: with ps; [
          pip
          setuptools
          wheel
          virtualenv
        ];
        
        # User-specified packages
        userPythonPackages = ps: 
          map (name: ps.${name}) cfg.packages;
        
        # Combine all packages
        allPythonPackages = ps: 
          (basicPythonPackages ps) ++ (userPythonPackages ps);
      in
      [
        (python.withPackages allPythonPackages)
        poetry
        pipenv
        pyright  # LSP server
      ] ++ cfg.extraPackages;
    
    # Set up environment variables
    home.sessionVariables = {
      PYTHONDONTWRITEBYTECODE = "1";  # Don't create __pycache__
    };
  };
}
