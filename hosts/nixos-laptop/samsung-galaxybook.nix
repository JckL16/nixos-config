{ config, pkgs, lib, ... }:

let
  # Fetch the samsung-galaxybook driver (pre-6.14 branch for kernel < 6.14)
  samsung-galaxybook-src = pkgs.fetchFromGitHub {
    owner = "joshuagrisham";
    repo = "samsung-galaxybook-extras";
    rev = "pre-6.14";
    sha256 = lib.fakeSha256;  # Temporary - will be replaced after first build
  };

  # Build the kernel module
  samsung-galaxybook = config.boot.kernelPackages.callPackage ({ stdenv, kernel }:
    stdenv.mkDerivation {
      pname = "samsung-galaxybook";
      version = "unstable-pre-6.14";
      
      src = samsung-galaxybook-src;
      
      nativeBuildInputs = kernel.moduleBuildDependencies;
      
      makeFlags = kernel.makeFlags ++ [
        "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "INSTALL_MOD_PATH=$(out)"
      ];
      
      installTargets = [ "modules_install" ];
      
      meta = with lib; {
        description = "Samsung Galaxy Book platform driver for keyboard backlight control";
        homepage = "https://github.com/joshuagrisham/samsung-galaxybook-extras";
        license = licenses.gpl2;
        platforms = platforms.linux;
      };
    }
  ) {};

in {
  # Add the Samsung Galaxy Book driver
  boot.extraModulePackages = [ samsung-galaxybook ];
  
  # Load the module at boot
  boot.kernelModules = [ "samsung_galaxybook" ];
  
  # Install brightnessctl for controlling the keyboard backlight
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
