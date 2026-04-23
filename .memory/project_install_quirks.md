---
name: installation quirks and constraints
description: Non-obvious gotchas during NixOS installation with this config
type: project
---

- **RAM exhaustion during install**: NixOS ISO runs in RAM. Large configs can exhaust it. Workaround: create an 8GB tmpswap + bind-mount /tmp to the target disk before running nixos-install. Documented in docs/installation.md.

- **Disko stays enabled after install**: `diskoConfig.enable = true` should remain set post-install. Disko only acts when explicitly invoked (`nix run github:nix-community/disko`). Normal rebuilds ignore it. Keeping it enabled preserves disk layout as documentation.

- **LUKS password is permanent**: The encryption password is never stored in the Nix config. It cannot be changed or recovered after installation without reinstalling. Set it carefully.

- **Monitor config is manual**: Hyprland loads `~/.config/hypr/monitors.conf` at startup. This file lives outside the Nix store and is set up using `nwg-displays` GUI after first boot. Not managed declaratively.

**Why:** These are operational constraints not obvious from reading the code.
**How to apply:** Flag these during install guidance or when helping set up a new host.
