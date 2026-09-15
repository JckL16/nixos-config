---
name: project-serpantinum-bar-fork
description: In-progress fork of Serpantinum's QuickShell bar + power menu to replace HyprPanel and wlogout
metadata:
  type: project
---

Replacing `modules/home-manager/desktop/hyprland/hyprpanel.nix` and `wlogout.nix` with a
custom QuickShell (QML/Qt6) bar, living at `modules/home-manager/desktop/hyprland/quickshell.nix`
+ `modules/home-manager/desktop/hyprland/quickshell/`. Originally started as a trimmed fork of
[Serpantinum](https://github.com/ilyamiro/serpantinum) and was named `serpantinum-bar/`
accordingly, but renamed to `quickshell/` once most of the content became original code (only
4 singletons — `Config`, `Caching`, `Scaler`, `ThemeBackend` — and a few widget files are still
vendored/adapted from upstream; `Bar.qml`, `shell.qml`, all popups, and `ClockWidget` are new).

**Why:** The user finds the current HyprPanel top bar impractical day-to-day and likes
Serpantinum's bar design specifically (not its dynamic Matugen theming, which is explicitly
unwanted). Serpantinum ships no way to run just the bar — its `Shell.qml` hardcodes Bar +
Launcher + Clipboard + Polkit-agent + Lock + ScreenshotOverlay together, which would
duplicate the existing `walker`/`clipman`/`polkit_gnome`/`hyprlock`. Its own Nix module only
exposes cosmetic settings (colors, bar module names/position, idle timings) — there is no
way to assemble a custom trimmed bar from Nix options alone, since QuickShell has no
Nix-attrset-to-QML translation layer the way HyprPanel does. The user explicitly accepted
this after being walked through it (see [[feedback_prefer_existing_nix_modules]] for a
related planning correction from this same discussion) — chose "fork the QML" over
reconfiguring HyprPanel or switching to Waybar.

Pinned upstream commit: `48620a5c7a86f0a73323a87c0b04e0200a54503a` (2026-09-14), cloned to
scratchpad for extracting source. No upstream update path once forked — re-port manually if
newer Serpantinum features are wanted later.

Full plan (vendor paths, which singletons are needed, theme-bridge approach, how it's wired
via home-manager's `programs.quickshell` module): `/home/jack/.claude/plans/eager-sparking-boot.md`.

**How to apply:** This is a multi-session QML port with no way to verify rendering from this
environment — build in reviewable stages (bar alone, then theme bridge, then power menu) and
have the user check each stage live on their Hyprland session before moving to the next.

**Known upstream bug found in stage 1 testing:** upstream's `Hyprland.dispatch("hl.dsp.focus({
workspace = N })")` calls fail with "Invalid dispatcher" on this Quickshell/Hyprland version —
confirmed via `journalctl --user -u quickshell`. The correct call is the plain
`Hyprland.dispatch("workspace " + N)`. Already fixed in `WorkspacesWidget.qml`; watch for the
same `hl.dsp.*` pattern if porting any other upstream file that dispatches Hyprland actions
(e.g. anything touched during the stage-2 PowerMenu extraction).
