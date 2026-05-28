---
name: hyprpanel-decisions
description: Non-obvious HyprPanel config decisions, constraints, and workarounds
metadata:
  type: project
---

HyprPanel replaces Waybar + Mako. Config in `modules/home-manager/desktop/hyprland/hyprpanel.nix`.

## GLib ELOOP workaround
HyprPanel's `readFile()` follows nix-store symlinks and hits the ELOOP kernel limit.
Fix: activation scripts wipe `~/.config/hyprpanel` before linkGeneration, then dereference
`config.json` symlink → real file after. `modules.scss` is generated with `pkgs.writeText`
and always copied (never symlinked).

**Why:** Without this, HyprPanel fails to load config.json and modules.scss, giving an
unstyled white bar or CSS compilation errors.

## monochrome = true is required
`theme.bar.menus.monochrome = true` must be set for `background`, `cards`, `text`, `label`,
`dimtext` overrides to take effect. Without it, per-menu Catppuccin defaults override all color settings.

## customModules path
CPU/RAM/cpuTemp live under `bar.customModules.{cpu,ram,cpuTemp}`, NOT `bar.{cpu,...}`.
The `round` option controls decimals: `true` = 0 decimals, `false` = 2 decimals (no 1-decimal option).
RAM `labelType` options: `"percentage"`, `"used"`, `"used/total"`, `"free"`.

## Battery widget removed
UPower's DisplayDevice incorrectly sums dual-battery energy values (current energy / one
battery's full energy → 188%). `usePercentageForPolicy = true` does NOT fix this.
Workaround: battery removed from bar layout; batsignal monitors BAT0 directly.

## udiskie tray disabled
`tray = "auto"` causes `gtk_widget_get_scale_factor` GTK assertion failures on Wayland
that crash the daemon via "Broken pipe". `tray = "never"` is stable; `notify = true`
sends libnotify notifications that HyprPanel's notification center catches.

## blueman autostart double-suppression needed
`services.blueman-applet.enable = false` only disables the systemd service.
`services.blueman.enable = true` (in bluetooth.nix) installs
`/etc/xdg/autostart/blueman.desktop` which dex picks up separately.
Both the service AND `~/.config/autostart/blueman.desktop` with `Hidden=true` are needed.

## HyprPanel dashboard shortcuts
The right card of the shortcuts section always injects hardcoded SettingsButton and
RecordingButton — cannot be removed via config. The left card (shortcut1-4) is hidden
if all commands are empty strings (hasCommand checks length > 0).

## modules.scss CSS constraints (GTK3)
- No `!important` support — GTK3 CSS parser errors on it
- No `@charset` — non-ASCII characters in comments cause SASS to prepend `@charset "UTF-8"`
  which GTK3 rejects as "unknown @ rule". Use only ASCII in comments.
- `box-shadow: inset` is unreliable for calendar cell indicators; use `border-bottom` instead
- `*` { all: unset; font-size: X } in HyprPanel's main CSS overrides inherited font-size on
  every element — must target `label` directly (e.g. `menuitem label`) to override font size

## Layer rule names
Actual Hyprland layer namespaces (verified via `hyprctl layers`):
- Bar: `bar-0`, `bar-1` (match with `bar-[0-9]+`)
- Menus: `.*menu`
- Notifications: `notifications-window`

[[project_nixos_config]]
