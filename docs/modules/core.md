# Core Modules

These modules handle fundamental system functionality. Most are enabled by default.

## Audio

- **Option:** `audio.enable` (default: `true`)
- **File:** `modules/nixos/hardware/audio.nix`
- **Where to set:** `configuration.nix`

PipeWire-based audio stack.

## Bluetooth

- **Option:** `bluetooth.enable` (default: `true`)
- **File:** `modules/nixos/hardware/bluetooth.nix`
- **Where to set:** `configuration.nix`

Bluetooth service and management. Set to `false` for VMs or systems without Bluetooth hardware.

## Swap File

- **Option:** `swap-file.enable` (default: `true`)
- **File:** `modules/nixos/core/swap-file.nix`
- **Where to set:** `configuration.nix`

Creates a 16 GiB swap file at `/var/lib/swapfile`.

Configurable size:

```nix
swap-file.enable = true;
swap-file.size = 8192;  # Size in MiB
```

## Garbage Collection

- **Option:** `garbage-collection.enable` (default: `true`)
- **File:** `modules/nixos/core/garbage-collection.nix`
- **Where to set:** `configuration.nix`

Runs `nix-collect-garbage` weekly, deleting store paths older than 7 days. Also runs `nix-store --optimise` weekly to deduplicate identical files in the Nix store.

## Always-Active Modules

These have no enable toggle and are always imported:

### Locale
- **File:** `modules/nixos/core/locale.nix`
- Timezone, keyboard layout, and locale settings from `variables.nix`.

### Networking
- **File:** `modules/nixos/core/networking.nix`
- NetworkManager, hostname.

### Nix Settings
- **File:** `modules/nixos/core/nix-settings.nix`
- Enables flakes, allows unfree packages.

### System Packages
- **File:** `modules/nixos/system-packages.nix`
- Base packages installed on every system: git, curl, vim, wget, python3, direnv, ncdu, nerd-fonts, and more.
- Sets the default editor to `nvim` and enables zsh/bash.

### Users
- **File:** `modules/nixos/users.nix`
- Creates the user from `variables.username` with groups: `networkmanager`, `wheel`, `input`, `video`, `render`, `gamemode`, `docker`, `libvirtd`.
- Sets zsh as the default shell.

## Bootloader

One bootloader should be active. GRUB is the default.

### GRUB

- **Option:** `grub.enable` (default: `true`)
- **File:** `modules/nixos/boot/grub.nix`
- **Where to set:** `configuration.nix`

Supports both EFI and BIOS. Uses `variables.bootDevice` and `variables.isBIOS` to configure itself. OS prober is enabled for dual-boot detection. Keeps 5 generations.

#### GRUB Nordic Theme

- **Option:** `grub.nordic-theme.enable` (default: `false`)

```nix
grub.nordic-theme.enable = true;
```

### systemd-boot

- **Option:** `systemd-boot.enable` (default: `false`)
- **File:** `modules/nixos/boot/systemd-boot.nix`
- **Where to set:** `configuration.nix`

EFI-only bootloader. Will fail with an assertion if `isBIOS = true`.

To switch from GRUB:

```nix
grub.enable = false;
systemd-boot.enable = true;
```
