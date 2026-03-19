# NixOS Config

My NixOS configuration, managed with flakes and home-manager.

## What's in here

The config is split into reusable modules under [modules/](modules/) -- system-level stuff
lives in [modules/nixos/](modules/nixos/) and user-level stuff in [modules/home-manager/](modules/home-manager/). Each
host picks what it needs.

Some highlights:

- **Hyprland** or **GNOME** desktop environments (or headless for WSL)
- GPU drivers for Intel, AMD, and NVIDIA
- Gaming setup with Steam + Proton-GE and GameMode
- Dev environments for Python, Rust, C/C++, and Go
- Virtualisation with libvirt/QEMU and Docker
- A cyber security toolkit with the usual suspects (Metasploit, Burp Suite, Wireshark, Ghidra, etc.)
- Zsh + Neovim + Alacritty + Zen Browser as the default shell/editor/terminal/browser
- PipeWire, Bluetooth, printing, and other basics are enabled out of the box

## Getting started

See the [Installation Guide](docs/installation.md) to get started, or [WSL Installation](docs/wsl.md) for Windows Subsystem for Linux.

Global settings like username, timezone, and git config live in [variables.nix](variables.nix).

## Documentation

All documentation is in the [docs/](docs/) directory:

- [Installation Guide](docs/installation.md) - Installing NixOS with this configuration
- [WSL Installation](docs/wsl.md) - Using this configuration on Windows
- [Module Documentation](docs/modules/) - Detailed documentation for each module category
- [Quick Reference](docs/reference.md) - All options at a glance
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

See also [hosts/nixos-example/](hosts/nixos-example/) for a commented example config to use as a starting point.
