{ config, lib, pkgs, ... }:

let
  cfg = config.python-dev;
in
{
  options.python-dev = {
    enable = lib.mkEnableOption "Python development environment";
    
    pythonVersion = lib.mkOption {
      type = lib.types.enum [ "python3" "python311" "python312" "python313" ];
      default = "python312";
      description = "Which Python version to use";
    };
    
    includeCommonPackages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include common Python packages (requests, numpy, pandas, etc.)";
    };
    
    includeDevTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include development tools (pytest, black, mypy, etc.)";
    };
    
    includeDataScience = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include data science packages (jupyter, matplotlib, scipy, etc.)";
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages to include in the environment";
    };
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; 
    let
      python = pkgs.${cfg.pythonVersion};
      commonPythonPackages = ps: with ps; [
        pip
        setuptools
        wheel
        virtualenv
        requests
        numpy
        pandas
      ];
      
      devToolPackages = ps: with ps; [
        pytest
        pytest-cov
        black
        flake8
        mypy
        pylint
        ipython
        autopep8
      ];
      
      dataSciencePackages = ps: with ps; [
        jupyter
        matplotlib
        scipy
        scikit-learn
        seaborn
        plotly
      ];
      
      allPythonPackages = ps: 
        (if cfg.includeCommonPackages then commonPythonPackages ps else [])
        ++ (if cfg.includeDevTools then devToolPackages ps else [])
        ++ (if cfg.includeDataScience then dataSciencePackages ps else []);
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