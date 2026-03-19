# Modules Overview

This document covers the repository structure, how modules work, and global configuration variables.

## Repository Structure

```
nixos-config/
├── flake.nix                       # Flake entry point, defines all hosts
├── variables.nix                   # Global variables (username, locale, etc.)
├── hosts/                          # Per-host configurations
│   ├── nixos-example/              # Example/template host
│   │   ├── configuration.nix       # System-level config
│   │   └── home.nix                # User-level config
│   └── ...                         # Other hosts follow the same pattern
├── modules/
│   ├── nixos/                      # System-level modules
│   │   ├── core/                   # Locale, networking, swap, garbage collection
│   │   ├── boot/                   # Bootloader options
│   │   ├── desktop/                # Desktop environments
│   │   ├── hardware/               # Audio, bluetooth, graphics drivers
│   │   ├── programs/               # System-level programs
│   │   ├── guest-agents/           # VM guest agents
│   │   ├── system-packages.nix     # Base system packages
│   │   └── users.nix               # User account setup
│   └── home-manager/               # User-level modules
│       ├── programs/               # CLI tools, terminals, gaming, desktop apps
│       ├── desktop/                # Desktop environment configs (Hyprland)
│       ├── programming/            # Development environments
│       ├── services/               # User services (keyring, udiskie)
│       └── cyber/                  # Security toolkit
└── wallpaper/                      # Wallpaper assets
```

## How Modules Work

Every module uses the `lib.mkEnableOption` / `lib.mkIf` pattern. You enable a module by setting `<module>.enable = true;` in your host's config files:

- **System-level modules** are set in `hosts/<your-host>/configuration.nix`
- **User-level modules** are set in `hosts/<your-host>/home.nix`

Some modules need to be enabled at both levels (e.g. Hyprland has a system-level component and a user-level component).

## Global Variables (variables.nix)

These variables are available to all modules and control system-wide behavior.

| Variable | Description | Default |
|---|---|---|
| `username` | System username | `"jack"` |
| `description` | User display name | `"Jack"` |
| `timeZone` | System timezone | `"Europe/Stockholm"` |
| `gitUsername` | Git commit author name | `"Jack"` |
| `gitEmail` | Git commit author email | `"jack@example.com"` |
| `defaultLocale` | Primary system locale | `"en_US.UTF-8"` |
| `extraLocale` | Secondary locale (date, currency, etc.) | `"sv_SE.UTF-8"` |
| `keyboard-layout` | Keyboard layout for Wayland/X11 | `"se"` |
| `console-keyboard` | TTY keyboard layout | `"sv-latin1"` |
| `system-state-version` | NixOS state version | `"25.11"` |
| `bootDevice` | GRUB target device | `"nodev"` |
| `isBIOS` | Whether the system uses BIOS (not EFI) | `false` |
| `displayScale` | Wayland compositor scale factor | `1` |
| `wallpaperPath` | Path to wallpaper image | `"~/.config/wallpapers/wallpaper.png"` |

You can override any variable per-host in `flake.nix`:

```nix
variables = (import ./variables.nix) // {
  displayScale = 1.5;
  bootDevice = "/dev/sda";
};
```

## Unstable Packages (pkgs-unstable)

Every host receives `pkgs-unstable` via `specialArgs` in `flake.nix`, which provides access to the `nixpkgs-unstable` channel. This is useful for packages that are not yet available or are outdated on the stable channel. It is passed through to home-manager via `extraSpecialArgs` in each host's `configuration.nix`.

Use it in `home.nix` or `configuration.nix` by adding `pkgs-unstable` to the module arguments:

```nix
# home.nix
{ config, pkgs, pkgs-unstable, ... }:
{
  home.packages = [
    pkgs.spotify           # from stable
    pkgs-unstable.some-pkg # from unstable
  ];
}
```
