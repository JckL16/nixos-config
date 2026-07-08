---
name: host purposes and context
description: What each host is for and non-obvious host-specific context
type: project
---

- **nixos-laptop**: ThinkPad X395. AMD Ryzen APU (Vega integrated graphics), LTS kernel, development + CTF prep. Fingerprint reader (Synaptics 06cb:009a) not yet configured — needs open-fprintd + python-validity (not in nixpkgs).
- **nixos-desktop**: AMD graphics, gaming + networking + security research. ARM emulation enabled. Winbox for MikroTik devices. GameMode GPU override (device 1, not auto).
- **nixos-rugged**: NVIDIA graphics. Portable/hardened machine. Similar toolset to desktop.
- **nixos-vm**: CTF/malware analysis VM — specifically designed around snapshot support. Uses GNOME (not Hyprland) because VirGL 3D acceleration breaks QEMU snapshots and live migration. BIOS boot, /dev/vda, small 4G swap.
- **nixos-example**: Template only — fully commented, never deployed.

**Why:** Non-obvious: the VM uses GNOME not by preference but to preserve snapshot capability.
**How to apply:** When suggesting desktop/graphics changes to nixos-vm, don't enable 3D acceleration or Hyprland — it will break snapshots.
