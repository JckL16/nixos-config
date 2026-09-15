---
name: feedback-prefer-existing-nix-modules
description: Before proposing a hand-rolled Nix derivation/packaging for a tool, check whether an official nixpkgs/home-manager module already covers it
metadata:
  type: feedback
---

When planning to package or wire up a third-party tool, actively search for an existing
official nixpkgs or home-manager module before drafting a custom derivation
(`pkgs.runCommand`, manual `cp -r` into `$out`, hand-written systemd units, etc.).

**Why:** While planning a QuickShell-based bar (see [[project_serpantinum_bar_fork]]), the
first plan draft included a hand-rolled derivation + exec-once wiring for `quickshell`. The
user pushed back twice asking "could this not be done with a NixOS module" — a search then
turned up home-manager's own `programs.quickshell` module (`configs.<name>`, `activeConfig`,
`systemd.enable`), which replaced the custom packaging entirely and was clearly the better
answer. The miss wasn't fatal, but it cost two extra review round-trips that a search up
front would have avoided.

**How to apply:** When a plan involves installing/running a program that isn't already used
elsewhere in this repo, spend one search checking `home-manager`'s `modules/programs/` (or
nixpkgs) for a module before writing packaging logic by hand. Only fall back to a custom
derivation once that search comes up empty.
