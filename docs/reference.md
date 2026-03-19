# Quick Reference

All module enable options at a glance.

## System Level (configuration.nix)

| Option | Default | Description |
|---|---|---|
| `hyprland.enable` | `false` | Hyprland Wayland compositor |
| `gnome.enable` | `false` | GNOME desktop environment |
| `greetd.enable` | `false`* | greetd with tuigreet (*auto-enabled with Hyprland) |
| `ly.enable` | `false` | ly display manager |
| `grub.enable` | `true` | GRUB bootloader |
| `grub.nordic-theme.enable` | `false` | Nordic theme for GRUB |
| `systemd-boot.enable` | `false` | systemd-boot (EFI only) |
| `intel-graphics.enable` | `false` | Intel GPU drivers |
| `amd-graphics.enable` | `false` | AMD GPU drivers |
| `nvidia-graphics.enable` | `false` | NVIDIA GPU drivers |
| `audio.enable` | `true` | PipeWire audio |
| `bluetooth.enable` | `true` | Bluetooth service |
| `swap-file.enable` | `true` | Swap file (16 GiB) |
| `swap-file.size` | `16384` | Swap file size in MiB |
| `garbage-collection.enable` | `true` | Weekly nix store cleanup |
| `steam.enable` | `false` | Steam with Proton-GE |
| `gamemode.enable` | `false` | Feral GameMode |
| `virtualisation.enable` | `false` | libvirt/QEMU KVM |
| `docker.enable` | `false` | Docker daemon |
| `winbox.enable` | `false` | MikroTik Winbox |
| `qemu-guest-agent.enable` | `false` | QEMU guest agent |
| `virtualbox-guest-agent.enable` | `false` | VirtualBox guest additions |
| `metasploit-db.enable` | `false` | PostgreSQL database for Metasploit |
| `yubikey.enable` | `true` | YubiKey support |
| `veracrypt.enable` | `true` | VeraCrypt disk encryption |

## User Level (home.nix)

| Option | Default | Description |
|---|---|---|
| `hyprland.enable` | `false` | Hyprland user config (waybar, rofi, etc.) |
| `git.enable` | `true` | Git with configured identity |
| `nvim.enable` | `true` | Neovim with LSP |
| `alacritty.enable` | `true` | Alacritty terminal |
| `zen-browser.enable` | `true` | Zen Browser (default browser) |
| `steam.enable` | `false` | Steam user tools (MangoHUD, etc.) |
| `gamemode.enable` | `false` | GameMode user config |
| `minecraft.enable` | `false` | Minecraft launcher |
| `virt-manager.enable` | `false` | Virtual machine manager GUI |
| `libreoffice.enable` | `false` | LibreOffice suite |
| `onlyoffice.enable` | `false` | OnlyOffice suite |
| `winbox.enable` | `false` | MikroTik Winbox |
| `python-dev.enable` | `false` | Python development environment |
| `python-dev.packages` | `[]` | Extra Python packages to install |
| `rust.enable` | `false` | Rust development environment |
| `c-cpp.enable` | `false` | C/C++ development environment |
| `go.enable` | `false` | Go development environment |
| `cyber.enable` | `false` | Cyber security toolkit |
