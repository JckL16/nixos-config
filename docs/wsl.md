# WSL Installation

This configuration includes a WSL (Windows Subsystem for Linux) host at `hosts/nixos-wsl/`. It comes with programming environments (Go, Rust, Python, C/C++) and cyber security tools pre-configured.

## Prerequisites

- Windows 10 version 2004+ or Windows 11
- WSL2 enabled

## Installation Steps

### 1. Enable WSL2

Open PowerShell as Administrator:

```powershell
wsl --install
```

Restart your computer if prompted.

### 2. Install NixOS-WSL

Download the latest NixOS-WSL release:

```powershell
# Download the latest tarball from GitHub
# https://github.com/nix-community/NixOS-WSL/releases

wsl --import NixOS $env:USERPROFILE\NixOS\ nixos-wsl.tar.gz --version 2
```

### 3. Launch NixOS

```powershell
wsl -d NixOS
```

### 4. Clone and Apply This Configuration

Inside the WSL instance:

```bash
# Enable flakes temporarily
nix-shell -p git

# Clone the configuration
cd ~
git clone https://github.com/JckL16/nixos-config.git
cd nixos-config

# Update variables.nix with your settings
nano variables.nix

# Apply the WSL configuration
sudo nixos-rebuild switch --flake .#nixos-wsl
```

### 5. Restart WSL

Exit and restart the WSL instance:

```powershell
wsl --shutdown
wsl -d NixOS
```

## WSL-Specific Notes

- The WSL host automatically mounts Windows drives under `/mnt/c`, `/mnt/d`, etc.
- Desktop environments are disabled since WSL runs headless (use WSLg for GUI apps if needed)
- Audio and Bluetooth modules are disabled as they're not applicable to WSL

## What's Included

The WSL host comes with:

- **Programming environments:** Go, Rust, Python, C/C++
- **Cyber security toolkit:** Full suite of security tools
- **CLI tools:** Neovim, Zsh with plugins, Git, and more

Desktop applications (Alacritty, Zen Browser) are disabled since you'll use Windows Terminal and your Windows browser.

## Customization

Edit `hosts/nixos-wsl/home.nix` to enable or disable modules:

```nix
# Disable cyber tools if you don't need them
cyber.enable = false;

# Disable programming environments you don't use
go.enable = false;
```
