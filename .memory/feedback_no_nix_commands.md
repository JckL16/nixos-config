---
name: do not run nix commands
description: Never run nix or nixos-rebuild commands — tell the user what to run instead
type: feedback
---

Do not execute nix commands (e.g. `nixos-rebuild`, `nix flake update`, `nix build`,
`nix run`, `disko`, etc.). Instead, tell the user the exact command to run.

**Why:** Nix builds can be slow, token-expensive, and interactive. The user prefers
to run them manually so they can observe output and control timing.

**How to apply:** Whenever a nix command would be needed to complete or verify a task,
output the command in a code block and explain what it does. Do not invoke it.
