# Configuration Content Guide

This document covers all the functionality available in this NixOS configuration and how to enable and configure each module.

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

---

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

---

## Core Modules (Enabled by Default)

These are enabled automatically and generally should stay enabled.

### Audio
- **Option:** `audio.enable` (default: `true`)
- **File:** `modules/nixos/hardware/audio.nix`
- PipeWire-based audio stack.

### Bluetooth
- **Option:** `bluetooth.enable` (default: `true`)
- **File:** `modules/nixos/hardware/bluetooth.nix`
- Bluetooth service and management. Set to `false` for VMs or systems without Bluetooth hardware.

### Swap File
- **Option:** `swap-file.enable` (default: `true`)
- **File:** `modules/nixos/core/swap-file.nix`
- Creates a 16 GiB swap file at `/var/lib/swapfile`.
- Configurable size:
  ```nix
  swap-file.enable = true;
  swap-file.size = 8192;  # Size in MiB
  ```

### Garbage Collection
- **Option:** `garbage-collection.enable` (default: `true`)
- **File:** `modules/nixos/core/garbage-collection.nix`
- Runs `nix-collect-garbage` weekly, deleting store paths older than 7 days.

### Other Core Modules (Always Active)
These have no enable toggle and are always imported:

- **Locale** (`modules/nixos/core/locale.nix`) -- Timezone, keyboard layout, and locale settings from `variables.nix`.
- **Networking** (`modules/nixos/core/networking.nix`) -- NetworkManager, hostname.
- **Nix Settings** (`modules/nixos/core/nix-settings.nix`) -- Enables flakes, allows unfree packages.
- **System Packages** (`modules/nixos/system-packages.nix`) -- Base packages installed on every system: git, curl, vim, wget, python3, direnv, ncdu, nerd-fonts, and more. Sets the default editor to `nvim` and enables zsh/bash.
- **Users** (`modules/nixos/users.nix`) -- Creates the user from `variables.username` with groups: `networkmanager`, `wheel`, `input`, `video`, `render`, `gamemode`, `docker`, `libvirtd`. Installs Firefox and sets zsh as the default shell.

---

## Bootloader

One bootloader should be active. GRUB is the default.

### GRUB
- **Option:** `grub.enable` (default: `true`)
- **File:** `modules/nixos/boot/grub.nix`
- Supports both EFI and BIOS. Uses `variables.bootDevice` and `variables.isBIOS` to configure itself.
- OS prober is enabled for dual-boot detection.
- Keeps 5 generations.

#### GRUB Nordic Theme
- **Option:** `grub.nordic-theme.enable` (default: `false`)
- **Where to set:** `configuration.nix`
  ```nix
  grub.nordic-theme.enable = true;
  ```

### systemd-boot
- **Option:** `systemd-boot.enable` (default: `false`)
- **File:** `modules/nixos/boot/systemd-boot.nix`
- EFI-only bootloader. Will fail with an assertion if `isBIOS = true`.
- To switch from GRUB:
  ```nix
  grub.enable = false;
  systemd-boot.enable = true;
  ```

---

## Desktop Environments

### Hyprland (Wayland Compositor)
- **System option:** `hyprland.enable` in `configuration.nix`
- **User option:** `hyprland.enable` in `home.nix`
- **Both must be set to `true`.**

System-level (`modules/nixos/desktop/hyprland.nix`) provides:
- Hyprland compositor with XWayland support
- greetd display manager with tuigreet (enabled by default, can be overridden)
- XDG portals for sandboxed apps
- Polkit, printing, udisks2 (USB automounting)
- System packages: wayland, kitty, waybar, rofi, wl-clipboard

User-level (`modules/home-manager/desktop/hyprland/`) provides:
- Hyprland keybindings and window rules
- Waybar (status bar) configuration
- Mako (notification daemon)
- Clipman (clipboard manager)
- Rofi (application launcher) theme
- Nordic GTK theme
- SwayOSD (volume/brightness OSD)
- Wlogout (logout menu)

```nix
# configuration.nix
hyprland.enable = true;

# home.nix
hyprland.enable = true;
```

### GNOME
- **Option:** `gnome.enable` in `configuration.nix`
- **File:** `modules/nixos/desktop/gnome.nix`
- Full GNOME desktop with GDM display manager.
- No user-level module needed.

```nix
# configuration.nix
hyprland.enable = false;
gnome.enable = true;
```

---

## Display Managers

Display managers handle the login screen. When using Hyprland, greetd is enabled by default. You can override this or use an alternative.

### greetd (with tuigreet)
- **Option:** `greetd.enable` (default: `true` when Hyprland is enabled)
- **File:** `modules/nixos/desktop/display-managers/greetd.nix`
- Terminal-based login manager using tuigreet.
- Automatically configured to launch Hyprland.

### ly
- **Option:** `ly.enable` (default: `false`)
- **File:** `modules/nixos/desktop/display-managers/ly.nix`
- TUI display manager similar to greetd.
- To use ly instead of greetd:
  ```nix
  # configuration.nix
  greetd.enable = false;
  ly.enable = true;
  ```

---

## Graphics Drivers

Enable exactly one that matches your hardware. Set in `configuration.nix`.

### Intel
```nix
intel-graphics.enable = true;
```

### AMD
```nix
amd-graphics.enable = true;
```

### NVIDIA
```nix
nvidia-graphics.enable = true;
```
Configures modesetting, 32-bit support, kernel modules (`nvidia`, `nvidia_modeset`, `nvidia_uvm`, `nvidia_drm`), and `nvidia-drm.modeset=1` kernel parameter.

---

## Gaming

Gaming requires both system-level and user-level modules.

### Steam
- **System:** `steam.enable = true;` in `configuration.nix`
- **User:** `steam.enable = true;` in `home.nix`

System-level installs Steam with Proton-GE compatibility. If `gamemode.enable` is also true, Steam is built with GameMode support automatically.

User-level installs additional tools: MangoHUD, Vulkan tools, Proton utilities.

### GameMode
- **System:** `gamemode.enable = true;` in `configuration.nix`
- **User:** `gamemode.enable = true;` in `home.nix`

System-level configures Feral GameMode with CPU governor optimization, GPU performance settings, renice for game processes, and desktop notifications on activation/deactivation.

### Minecraft
- **User only:** `minecraft.enable = true;` in `home.nix`

```nix
# configuration.nix
steam.enable = true;
gamemode.enable = true;

# home.nix
steam.enable = true;
gamemode.enable = true;
minecraft.enable = true;
```

---

## Virtualisation

### libvirt/QEMU (KVM)
- **System:** `virtualisation.enable = true;` in `configuration.nix`
- **User:** `virt-manager.enable = true;` in `home.nix`

System-level enables libvirtd with QEMU KVM, TPM emulation, and auto-start of the default network.

User-level installs the virt-manager GUI.

```nix
# configuration.nix
virtualisation.enable = true;

# home.nix
virt-manager.enable = true;
```

### Docker
- **System only:** `docker.enable = true;` in `configuration.nix`
- The user is already added to the `docker` group via `users.nix`.

### Guest Agents (for running inside a VM)

#### QEMU Guest Agent
```nix
# configuration.nix
qemu-guest-agent.enable = true;
```

#### VirtualBox Guest Agent
```nix
# configuration.nix
virtualbox-guest-agent.enable = true;
```

---

## Programming Environments

These are user-level modules set in `home.nix`.

### Python
- **Option:** `python-dev.enable = true;`
- Installs Python 3 with pip, setuptools, wheel, virtualenv, Poetry, Pipenv, and Pyright (LSP).
- Additional Python packages can be specified:
  ```nix
  python-dev.enable = true;
  python-dev.packages = [ "requests" "numpy" "pandas" ];
  ```
- Sets `PYTHONDONTWRITEBYTECODE=1`.

### Rust
- **Option:** `rust.enable = true;`
- Installs rustc, cargo, rustfmt, clippy, rust-analyzer, and gcc.
- Adds `~/.cargo/bin` to `PATH`.

### C/C++
- **Option:** `c-cpp.enable = true;`
- Installs gcc, cmake, ninja, meson, autoconf, automake, gdb, valgrind, lldb, strace, and common libraries (Boost, fmt, spdlog, Catch2, Google Test).

```nix
# home.nix
python-dev.enable = true;
python-dev.packages = [ "flask" "sqlalchemy" ];
rust.enable = true;
c-cpp.enable = true;
```

---

## Cyber Security Toolkit

- **User only:** `cyber.enable = true;` in `home.nix`
- **File:** `modules/home-manager/cyber/default.nix`

This is a comprehensive security toolkit for CTFs, penetration testing, and security research. Enabling it automatically enables `python-dev` with security-specific Python packages (pwntools, unicorn, capstone, keystone-engine, ropper, pycryptodome, cryptography, r2pipe).

Includes tools across these categories:

- **General utilities** -- Scripting languages (Ruby, Perl), networking (nmap, masscan, rustscan, socat, netcat), file transfer (rsync, aria2), hex editors (imhex, hexyl, ghex), JSON/XML processing (jq, yq, htmlq), system monitoring, and wordlists.
- **Binary exploitation** -- Debuggers (gdb with GEF, lldb, edb), disassemblers/decompilers (radare2, rizin, cutter, ghidra), binary analysis (binwalk, binutils, elfutils, patchelf), ROP tools (rp++, one_gadget, pwninit), fuzzers (AFL++, honggfuzz, radamsa), dynamic analysis (strace, ltrace, valgrind), and CPU emulation (QEMU, unicorn).
- **Reverse engineering** -- Java (jadx, bytecode-viewer), .NET (ILSpy), Python (pycdc), mobile (apktool, dex2jar, android-tools), string extraction (FLOSS), unpacking (UPX), and protocol analysis (protobuf).
- **Forensics** -- Disk recovery (sleuthkit, testdisk, foremost, scalpel, ddrescue), memory forensics (volatility3), network forensics (wireshark, tshark, tcpdump, ettercap, NetworkMiner), metadata (exiftool), PDF analysis (pdf-parser, pdfid), Windows forensics (regripper, evtx), YARA, and disk utilities (dislocker, smartmontools).
- **Cryptography** -- Libraries (openssl, gnutls), encryption tools (gnupg, age), hash cracking (hashcat, john, fcrackzip), cryptanalysis (xortool), number theory (PARI/GP, GAP), and certificate management (certbot).
- **Steganography** -- ImageMagick, steghide, stegseek, zsteg, outguess, QR code tools (qrencode, zbar).
- **Web exploitation** -- Proxies (Burp Suite, OWASP ZAP, mitmproxy), scanners (nikto, wpscan, nuclei, wapiti), fuzzers (ffuf, wfuzz, feroxbuster, gobuster), SQL injection (sqlmap), subdomain enumeration (amass, subfinder), API testing (Postman, Insomnia, HTTPie), JWT tools, and wordlists (SecLists).

Also requires the Metasploit database at system level for full Metasploit functionality:

```nix
# configuration.nix
metasploit-db.enable = true;

# home.nix
cyber.enable = true;
```

---

## Office & Desktop Applications

Set in `home.nix`.

### LibreOffice
```nix
libreoffice.enable = true;
```

### OnlyOffice
```nix
onlyoffice.enable = true;
```

### Winbox (MikroTik Network Management)
Requires both system and user level:
```nix
# configuration.nix
winbox.enable = true;

# home.nix
winbox.enable = true;
```

---

## Default User-Level Programs (Always Active)

These are enabled by default in the home-manager module and provide the base user experience.

### Zsh Shell
Always active. Configured with:
- **Oh-My-Zsh** with plugins: git, fzf, sudo, command-not-found, colored-man-pages, extract
- **Autosuggestions** and **syntax highlighting**
- **Zoxide** (smart `cd` replacement, aliased to `cd`)
- **Eza** (modern `ls` replacement, aliased to `ls`, `ll`, `la`, `lt`, `tree`)
- **Fzf** for fuzzy finding (Ctrl-R for history search)
- **pay-respects** for command correction
- Additional CLI tools: bat, ripgrep, fd, tldr, btop, duf, dust, procs, delta

#### NixOS Shell Aliases
| Alias | Command |
|---|---|
| `switch` | `sudo nixos-rebuild switch --flake ~/nixos-config` |
| `test` | `sudo nixos-rebuild test --flake ~/nixos-config` |
| `dry-run` | `sudo nixos-rebuild dry-run --flake ~/nixos-config` |
| `update` | Updates the flake lock and rebuilds |
| `clean` | `nix-collect-garbage` |
| `install-bootloader` | Reinstalls the bootloader |
| `nix-search` | `nix search nixpkgs` |

#### Other Aliases
| Alias | Description |
|---|---|
| `ls`, `ll`, `la`, `lt` | Eza with icons and directory grouping |
| `cd` | Zoxide smart directory jumping |
| `gst`, `gco`, `gp`, `gl` | Git status, checkout, push, pull |
| `rm`, `cp`, `mv` | Safer variants with `-i` confirmation |
| `open` | `xdg-open` |

### Neovim
- **Option:** `nvim.enable` (default: `true`)
- Pre-configured with LSP support and plugins via external Lua configuration.

### Alacritty
- **Option:** `alacritty.enable` (default: `true`)
- GPU-accelerated terminal emulator.

### Git
- **Option:** `git.enable` (default: `true`)
- Configured with the username and email from `variables.nix`.

### Services (Always Active)
- **Keyring** (`modules/home-manager/services/keyring.nix`) -- GNOME Keyring for password management.
- **Udiskie** (`modules/home-manager/services/udiskie.nix`) -- Automatic USB drive mounting.

---

## Quick Reference: All Enable Options

### System Level (configuration.nix)

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
| `garbage-collection.enable` | `true` | Weekly nix store cleanup |
| `steam.enable` | `false` | Steam with Proton-GE |
| `gamemode.enable` | `false` | Feral GameMode |
| `virtualisation.enable` | `false` | libvirt/QEMU KVM |
| `docker.enable` | `false` | Docker daemon |
| `winbox.enable` | `false` | MikroTik Winbox |
| `qemu-guest-agent.enable` | `false` | QEMU guest agent |
| `virtualbox-guest-agent.enable` | `false` | VirtualBox guest additions |
| `metasploit-db.enable` | `false` | PostgreSQL database for Metasploit |

### User Level (home.nix)

| Option | Default | Description |
|---|---|---|
| `hyprland.enable` | `false` | Hyprland user config (waybar, rofi, etc.) |
| `git.enable` | `true` | Git with configured identity |
| `nvim.enable` | `true` | Neovim with LSP |
| `alacritty.enable` | `true` | Alacritty terminal |
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
| `cyber.enable` | `false` | Cyber security toolkit |
