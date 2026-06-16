---
name: project-mesa-workaround
description: Temporary RADV_DEBUG=nogpl workaround in amd.nix for Mesa 26.1.2 Unity crash — remove once Mesa 26.1.3+ ships
metadata:
  type: project
---

`modules/nixos/hardware/graphics/amd.nix` has `RADV_DEBUG = "nodcc,nogpl"` set as a temporary workaround.

**Why:** Mesa 26.1.2's RADV driver has a SIGSEGV regression triggered by Unity games (e.g. shapez 2) during Vulkan pipeline creation. Both `nodcc` (disables Delta Color Compression) and `nogpl` (disables Graphics Pipeline Library) are needed together to prevent the crash. `RADV_PERFTEST=gpl` was also removed (GPL has been default since Mesa 24.0, the flag was obsolete).

**How to apply:** Once NixOS ships Mesa 26.1.3+, remove the `RADV_DEBUG = "nodcc,nogpl"` line from `amd.nix` and rebuild. Mesa 26.1.3 was expected around 2026-06-17.
