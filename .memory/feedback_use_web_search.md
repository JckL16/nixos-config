---
name: feedback-use-web-search
description: Use web search for package behaviour research, not nix store inspection or binary reverse engineering
metadata:
  type: feedback
---

Use web search to look up how a package works (CLI flags, config schema, available modules, changelog). Do not run `--help` on binaries, inspect `/nix/store/...` paths, or read package source to reverse-engineer behaviour.

**Why:** User explicitly asked for this approach. Inspecting binaries/store paths is noisy and fragile; official docs/wikis are more reliable.

**How to apply:** Whenever investigating package-specific behaviour (e.g. Walker TOML schema, Hyprland syntax changes, NixOS module options), reach for WebSearch first.
