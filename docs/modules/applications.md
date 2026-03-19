# Applications

## Office Suites

Set in `home.nix`.

### LibreOffice

```nix
libreoffice.enable = true;
```

### OnlyOffice

```nix
onlyoffice.enable = true;
```

## Zen Browser

- **Option:** `zen-browser.enable = true;` in `home.nix`
- **Default:** `true`

Firefox-based browser set as the XDG default for `http`, `https`, and `text/html`. Installed via the `0xc000022070/zen-browser-flake` community flake.

The Rofi web search shortcut (`Super+Shift+D`) opens results directly in Zen Browser.

## VeraCrypt (Disk Encryption)

- **Option:** `veracrypt.enable = true;` in `configuration.nix`
- **File:** `modules/nixos/programs/veracrypt.nix`
- **Default:** `true`

VeraCrypt is a free and open-source disk encryption tool. It allows you to create virtual encrypted disks within files or encrypt entire partitions and storage devices.

### Features

- AES, Serpent, and Twofish encryption algorithms
- Hidden volume support for plausible deniability
- Cross-platform compatibility (Windows, macOS, Linux)
- Hardware acceleration support

### System Configuration

The module configures:

- FUSE support (`programs.fuse.userAllowOther = true`) for mounting volumes
- A setuid security wrapper so the GUI can mount volumes without requiring sudo

### Usage

**GUI:** Run `veracrypt` to open the graphical interface.

**Command line:**

```bash
# Mount a volume
veracrypt /path/to/volume /mnt/point

# Dismount a volume
veracrypt -d /mnt/point

# Dismount all volumes
veracrypt -d
```

---

## Winbox (MikroTik Network Management)

Requires both system and user level:

```nix
# configuration.nix
winbox.enable = true;

# home.nix
winbox.enable = true;
```

---

## Default User-Level Programs

These are enabled by default and provide the base user experience.

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

Pre-configured with LSP support and plugins via external Lua configuration.

### Alacritty

- **Option:** `alacritty.enable` (default: `true`)

GPU-accelerated terminal emulator.

### Git

- **Option:** `git.enable` (default: `true`)

Configured with the username and email from `variables.nix`.

### Services (Always Active)

- **Keyring** (`modules/home-manager/services/keyring.nix`) -- GNOME Keyring for password management.
- **Udiskie** (`modules/home-manager/services/udiskie.nix`) -- Automatic USB drive mounting.
