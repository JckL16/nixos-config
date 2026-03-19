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
