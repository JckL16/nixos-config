---
name: nixos-config project overview
description: Non-obvious decisions and constraints in the NixOS flake config repo
type: project
---

Multi-host NixOS flake config managing: nixos-laptop, nixos-desktop, nixos-rugged,
nixos-vm. Primary desktop is Hyprland. Stable channel: nixos-26.05.

Key non-obvious decisions:
- PBKDF2 used for LUKS instead of default Argon2 because GRUB cannot handle Argon2
- BIOS hosts get a separate unencrypted /boot partition to prevent a double password
  prompt (once at GRUB, once at initrd)
- `wapiti` is commented out of `modules/home-manager/cyber/default.nix`'s package list:
  broken on nixpkgs 26.05 because `wapiti-arsenic` pins `packaging<26.0` but nixpkgs
  ships `packaging` 26.1. Re-check before re-enabling.
- Nix string literals don't support `\uXXXX` Unicode escapes, but JSON does —
  `builtins.fromJSON ''"å"''`-style tricks are the way to produce a literal Unicode
  character (e.g. a Nerd Font icon codepoint) in a Nix string when you only have its escape
  sequence, not the raw glyph.
- NVIDIA + Wayland (`modules/nixos/hardware/graphics/nvidia.nix`): `nvidia-drm.modeset=1` is
  required for any Wayland compositor to work at all. Separately, XWayland needs to properly
  expose all monitors via RandR or Proton/Wine games under gamemode enumerate the wrong
  display set — both are handled in that module, don't remove either without testing games.
- `modules/nixos/programs/gamemode.nix`'s `gpu.gpu_device = 1` (not `0`) is intentional — this
  machine's multi-GPU setup needs index 1, not the default. If gamemode GPU optimizations seem
  to target the wrong GPU on a host, check this index rather than assuming `0` is correct.
- `modules/nixos/programs/virtualisation.nix`: vagrant-libvirt checks standard distro paths for
  OVMF firmware that don't exist on NixOS. `OVMF_CODE` satisfies its validation check and
  injects OVMF as a pflash unit=0. `/run/libvirt/nix-ovmf/` is a stable NixOS-managed symlink
  that survives rebuilds — don't assume it needs recreating after a switch.
- `modules/nixos/core/networking.nix` disables `NetworkManager-wait-online` (blocks boot 5+
  seconds waiting for a connection most services don't need) — anything that genuinely needs
  network at boot should declare `After = [ "network-online.target" ]` itself instead of relying
  on the global wait.
- `modules/home-manager/theme/presets.nix` is a pure Nix attrset (no `pkgs` dependency) so it can
  be imported by both home-manager modules and NixOS modules (e.g. the GRUB theme builder). Every
  preset must define every field `theme/default.nix` declares an option for — the loader applies
  `lib.mkDefault` over the whole attrset, so a missing key silently falls back to Nord's
  `mkOption` default instead of erroring, which can look like a real color that's just "wrong"
  rather than an obviously missing one. Check this first if a new/edited preset seems to be
  ignoring some of its own values.
- Hyprland's own config format wants colors as `rgba(RRGGBBAA)` — no leading `#`, alpha appended
  as a hex byte. `hyprland.nix`'s `hyprHex` helper (`builtins.substring 1 6`) strips the `#` and
  the alpha channel off a standard `#RRGGBBAA`/`#RRGGBB` theme color string to fit that format.

**Why:** These are hardware compatibility constraints, not stylistic preferences.
**How to apply:** Don't change LUKS KDF or /boot layout without verifying GRUB support.
