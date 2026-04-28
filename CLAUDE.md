# NixOS Configuration

> **Memory:** At the start of each conversation, read `.memory/MEMORY.md` and load all
> referenced memory files. Write new memories and updates to `.memory/` in this repo,
> not to the external Claude memory directory.

Multi-host NixOS flake configuration for laptop, desktop, rugged, VM, and WSL systems.
Primary desktop: Hyprland. Username: jack. Timezone: Europe/Stockholm.

## Structure

- `flake.nix` — entry point; defines all nixosConfigurations
- `variables.nix` — global variables passed as specialArgs to all modules
- `hosts/<name>/` — per-host config: `configuration.nix` (system), `home.nix` (user)
- `modules/nixos/` — reusable system-level NixOS modules
- `modules/home-manager/` — reusable home-manager modules
- `docs/` — installation guides and module documentation

## Shell Aliases

Defined in `modules/home-manager/programs/command-line/zsh.nix`.

| Alias | Command |
|---|---|
| `switch` | `sudo nixos-rebuild switch --flake ~/nixos-config` |
| `test` | `sudo nixos-rebuild test --flake ~/nixos-config` |
| `dry-run` | `sudo nixos-rebuild dry-run --flake ~/nixos-config` |
| `update` | `nix flake update --flake ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config` |
| `clean` | `nix-collect-garbage` |
| `install-bootloader` | `sudo nixos-rebuild boot --install-bootloader --flake ~/nixos-config` |
| `nix-search` | `nix search nixpkgs` |
| `ls` / `ll` / `la` / `lt` / `tree` | eza (replacement for ls) |
| `cd` | zoxide (`z`) |
| `gst` / `gco` / `gp` / `gl` | git shortcuts |
| `rm` / `cp` / `mv` | safety variants (`-i` flag) |
| `open` | `xdg-open` |

## Key Commands (without aliases)

```bash
sudo nixos-rebuild switch --flake .#<hostname>
sudo nixos-rebuild test --flake .#<hostname>
nix flake update
nix flake check
```

## Conventions

- **Modules** use `lib.mkEnableOption` + `lib.mkIf config.<module>.enable` for optional features
- **Defaults** use `lib.mkDefault` so hosts can override without conflicts
- **Variables** from `variables.nix` are available everywhere via `specialArgs`; use them instead of hardcoding username, timezone, etc.
- **Stable vs unstable**: use `pkgs` (nixpkgs 25.11) by default; use `pkgs-unstable` only when a package is unavailable or too old in stable
- **No formatter is configured** — keep existing indentation style (2 spaces) when editing Nix files
- Module files live under `modules/nixos/` or `modules/home-manager/` and must be imported in the relevant `default.nix`

## Adding a New Module

1. Create the file under the appropriate `modules/` subdirectory
2. Add it to the `imports` list in that directory's `default.nix`
3. Gate it behind `lib.mkEnableOption` if it's optional
4. Enable it per-host in `hosts/<name>/configuration.nix` or `home.nix`

## Adding a New Host

Use `hosts/nixos-example/` as a template — it is fully commented.

1. Copy `hosts/nixos-example/` to `hosts/<new-host>/`
2. Add a `mkSystem { hostname = "<new-host>"; ... }` entry to `nixosConfigurations` in `flake.nix`; use `extraVars` for variable overrides, `extraModules` for extra NixOS modules, `withHardwareConfig = false` / `withDisko = false` if the host doesn't need them
3. Set host-specific variables (device, bootloader type, graphics drivers, etc.)
4. Run `disko` for disk setup, then `nixos-install`
5. See `docs/installation.md` for full steps

## Disk Setup (Disko)

Configured via `diskoConfig` options in each host's `configuration.nix`:
- `device`: block device (e.g. `/dev/nvme0n1`)
- `encryption.enable`: LUKS with PBKDF2 (required for GRUB compatibility)
- `swapSize`: e.g. `"16G"`
- BIOS systems set `isBIOS = true` in `flake.nix` — this adds a separate unencrypted `/boot` to avoid a double LUKS password prompt at GRUB

## Home-Manager

Integrated as a NixOS module (not standalone). Each host's `configuration.nix` configures it:
- `useGlobalPkgs = true` and `useUserPackages = true`
- User modules are exported as `homeManagerModules.default` and imported in each `home.nix`

## Git

Always ask before running `git commit` or `git push`. Do not stage, commit, or push
any changes without explicit confirmation, even if the task seems complete.

## Nix Commands

Do not run nix or nixos-rebuild commands (e.g. `nixos-rebuild switch`, `nix flake update`,
`nix build`, `nix run`, `disko`). Instead, output the exact command for the user to run
in a code block and explain what it does.

## Keeping Docs and Memory Up to Date

When making changes to this config:
- Update `docs/` if the change affects installation, module behaviour, or options
- Update relevant memory files in `.memory/` (in this repo) if the change introduces
  a new non-obvious constraint, decision, or host purpose. Update `.memory/MEMORY.md`
  index when adding or removing memory files.
- Update this `CLAUDE.md` if the change affects project structure, conventions, or workflow

## Things to Be Careful About

- Do not hardcode the username (`jack`) — use `variables.username`
- Do not remove `lib.mkDefault` from module defaults — hosts rely on being able to override them
- `hardware-configuration.nix` is machine-generated; do not manually edit it
