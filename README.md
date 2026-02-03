# Nixos Config

My NixOS configuration, managed with flakes and home-manager.

## What's in here

The config is split into reusable modules under [modules/](modules/) -- system-level stuff
lives in [modules/nixos/](modules/nixos/) and user-level stuff in [modules/home-manager/](modules/home-manager/). Each
host picks what it needs.

Some highlights:

- **Hyprland** or **GNOME** desktop environments
- GPU drivers for Intel, AMD, and NVIDIA
- Gaming setup with Steam + Proton-GE and GameMode
- Dev environments for Python, Rust, and C/C++
- Virtualisation with libvirt/QEMU and Docker
- A cyber security toolkit with the usual suspects (Metasploit, Burp Suite, Wireshark, Ghidra, etc.)
- Zsh + Neovim + Alacritty as the default shell/editor/terminal
- PipeWire, Bluetooth, printing, and other basics are enabled out of the box

## Getting started

A guide to installing the configuration including where to find the ISO and files can be found in [INSTALL.md](INSTALL.md)

Global settings like username, timezone, and git config live in [variables.nix](variables.nix).

## Docs

- [CONTENT.md](CONTENT.md) -- full breakdown of every module and option
- [INSTALL.md](INSTALL.md) -- installation and setup instructions
- [hosts/nixos-example/](hosts/nixos-example/) -- commented example config to use as a starting point
