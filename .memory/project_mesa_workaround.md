---
name: project-mesa-workaround
description: Temporary RADV_DEBUG=nogpl workaround in amd.nix for Mesa 26.1.2 Unity crash — remove once Mesa 26.1.3+ ships
metadata:
  type: project
---

`modules/nixos/hardware/graphics/amd.nix` has `RADV_DEBUG = "nogpl"` set as a temporary workaround.

**Why:** Mesa 26.1.2's RADV driver has a SIGSEGV regression in `VK_EXT_graphics_pipeline_library` (GPL) triggered by Unity games (e.g. shapez 2) during Vulkan pipeline creation. Disabling GPL via `nogpl` forces RADV to use traditional pipeline creation and avoids the crash. `RADV_PERFTEST=gpl` was also removed at the same time (GPL has been default since Mesa 24.0, the flag was obsolete).

**How to apply:** Once NixOS ships Mesa 26.1.3+, remove the `RADV_DEBUG = "nogpl"` line from `amd.nix` and rebuild. Mesa 26.1.3 was expected around 2026-06-17.
