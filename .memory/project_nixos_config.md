---
name: nixos-config project overview
description: Non-obvious decisions and constraints in the NixOS flake config repo
type: project
---

Multi-host NixOS flake config managing: nixos-laptop, nixos-desktop, nixos-rugged,
nixos-vm, nixos-wsl. Primary desktop is Hyprland. Stable channel: nixos-25.11.

Key non-obvious decisions:
- PBKDF2 used for LUKS instead of default Argon2 because GRUB cannot handle Argon2
- BIOS hosts get a separate unencrypted /boot partition to prevent a double password
  prompt (once at GRUB, once at initrd)

**Why:** These are hardware compatibility constraints, not stylistic preferences.
**How to apply:** Don't change LUKS KDF or /boot layout without verifying GRUB support.
