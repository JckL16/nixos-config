---
name: installation quirks and constraints
description: Non-obvious gotchas during NixOS installation with this config
type: project
---

- **RAM exhaustion during install**: NixOS ISO runs in RAM. Large configs can exhaust it. Workaround: create an 8GB tmpswap + bind-mount /tmp to the target disk before running nixos-install. Documented in docs/installation.md.

- **Disko stays enabled after install**: `diskoConfig.enable = true` should remain set post-install. Disko only acts when explicitly invoked (`nix run github:nix-community/disko`). Normal rebuilds ignore it. Keeping it enabled preserves disk layout as documentation.

- **LUKS password is permanent**: The encryption password is never stored in the Nix config. It cannot be changed or recovered after installation without reinstalling. Set it carefully.

- **Monitor config is manual**: Hyprland loads `~/.config/hypr/monitors.conf` at startup. This file lives outside the Nix store and is set up using `nwg-displays` GUI after first boot. Not managed declaratively. `hyprland.nix` only creates an empty placeholder if the file doesn't exist yet (so Hyprland's `source =` doesn't error on a fresh install) via `home.activation`, not `home.file` — home-manager's `home.file` creates a read-only Nix-store symlink, which would break nwg-displays' ability to write to it.

- **Disko vs. hardware-configuration.nix fileSystems conflict**: both define `fileSystems` at the same priority, which conflicts. `modules/nixos/disko/default.nix` forces disko's device paths to win over the UUIDs `nixos-generate-config` writes into `hardware-configuration.nix`.

**Why:** These are operational constraints not obvious from reading the code.
**How to apply:** Flag these during install guidance or when helping set up a new host.
