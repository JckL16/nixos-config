# hosts/nixos-example/home.nix
#
# User-level configuration. Programs and settings here are installed
# per-user via Home Manager. For details on each module see CONTENT.md.

{ config, pkgs, ... }:
{

  # ==========================================================================
  # Desktop Environment
  # Must match what you enabled in configuration.nix.
  # ==========================================================================
  hyprland.enable = true;

  # ==========================================================================
  # Gaming
  # Enable the user-level counterparts of the options in configuration.nix.
  # ==========================================================================
  # steam.enable = true;
  # gamemode.enable = true;
  # minecraft.enable = true;

  # ==========================================================================
  # Programming Environments
  # ==========================================================================
  # python-dev.enable = true;
  # python-dev.packages = [ "requests" "numpy" "pandas" ];  # extra pip packages
  # rust.enable = true;
  # c-cpp.enable = true;

  # ==========================================================================
  # Cyber Security Toolkit
  # Comprehensive toolset for CTFs, pentesting, and security research.
  # Automatically enables python-dev with security-focused packages.
  # Also enable metasploit-db in configuration.nix for full Metasploit support.
  # ==========================================================================
  # cyber.enable = true;

  # ==========================================================================
  # Virtualisation
  # Requires virtualisation.enable = true in configuration.nix.
  # ==========================================================================
  # virt-manager.enable = true;

  # ==========================================================================
  # Office & Desktop Applications
  # ==========================================================================
  # libreoffice.enable = true;
  # onlyoffice.enable = true;
  # winbox.enable = true;      # also needs winbox.enable in configuration.nix

  # ==========================================================================
  # Defaults (enabled automatically, override here if needed)
  # ==========================================================================
  # git.enable = false;         # Disable Git (configured from variables.nix)
  # nvim.enable = false;        # Disable Neovim
  # alacritty.enable = false;   # Disable Alacritty terminal

  # ==========================================================================
  # Extra Packages
  # Add any additional Nix packages you want installed for your user.
  # Search for packages: nix search nixpkgs <name>
  # ==========================================================================
  home.packages = with pkgs; [
    # Example:
    # firefox
    # spotify
    # discord
    # obsidian
    # vlc
  ];

}
