---
name: project-wallpaper-mechanism
description: How the desktop wallpaper is actually wired (gtk-theme.nix home.file), and that it no longer auto-regenerates per theme
metadata:
  type: project
---

`~/.config/wallpapers/wallpaper.png` (what `swaybg` reads, hardcoded in
`modules/home-manager/desktop/hyprland/hyprland.nix`'s exec-once) is managed via
`home.file` in `modules/home-manager/desktop/hyprland/gtk-theme.nix`. The repo's
`wallpaper/wallpaper.png` asset is the actual source image — `gtk-theme.nix` points
`home.file.".config/wallpapers/wallpaper.png".source` directly at it.

**Before 2026-10-19** this file instead generated a wallpaper procedurally at build time
(`pkgs.runCommand` + imagemagick, a radial gradient from `c.surface` to `c.background` with
light noise) — so every theme in `theme/presets.nix` automatically got its own matching
wallpaper with zero user effort, and the repo's `wallpaper/wallpaper.png` asset sat unused/
orphaned (a stale leftover, never actually wired to anything).

**Why changed:** user downloaded a real photo (wallhaven) matching the `typewriter` palette
and wanted it as their actual wallpaper. Swapping it in live via `swaybg -i <path>` didn't
survive a reboot — `gtk-theme.nix`'s `home.file` forcibly overwrites `wallpaper.png` back to
the generated gradient on every home-manager activation (incl. the one that runs at
login/boot), which is what was actually happening. Fixed by replacing the generated-gradient
derivation with a direct `home.file` source pointing at `wallpaper/wallpaper.png`, and
overwriting that asset with the chosen photo.

**How to apply:** The wallpaper is now a **static image**, not theme-reactive — switching
`variables.theme` no longer changes the wallpaper automatically like it used to. To update
the wallpaper going forward: overwrite `wallpaper/wallpaper.png` in the repo (e.g.
`convert <new-image> wallpaper/wallpaper.png`) and run `switch`. For *live* previewing before
committing to a `switch`, kill and relaunch the `swaybg` process directly
(`pkill swaybg; setsid swaybg -i <path> -m fill & disown`) — this is purely a runtime test and
reverts on the next home-manager activation unless the repo asset is also updated.
