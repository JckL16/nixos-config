# Desktop Environments

## Hyprland (Wayland Compositor)

- **System option:** `hyprland.enable` in `configuration.nix`
- **User option:** `hyprland.enable` in `home.nix`
- **Both must be set to `true`.**

### System-level

**File:** `modules/nixos/desktop/hyprland.nix`

Provides:
- Hyprland compositor with XWayland support
- greetd display manager with tuigreet (enabled by default, can be overridden)
- XDG portals for sandboxed apps
- Polkit, printing, udisks2 (USB automounting), UPower
- System packages: wayland, kitty, wl-clipboard

### User-level

**File:** `modules/home-manager/desktop/hyprland/`

| File | Purpose |
|---|---|
| `hyprland.nix` | Keybindings, window rules, layer rules, exec-once startup |
| `hyprpanel.nix` | HyprPanel bar — replaces Waybar and Mako |
| `nordic-theme.nix` | Nordic GTK theme, Papirus icons, Nordzy cursors, GTK popup CSS |
| `rofi.nix` | Rofi application launcher theme |
| `clipman.nix` | Clipboard manager |
| `swayosd.nix` | Volume/brightness OSD (SwayOSD) |
| `wlogout.nix` | Logout/shutdown/reboot/lock menu |

### HyprPanel (Bar + Notifications)

HyprPanel replaces both Waybar (status bar) and Mako (notification daemon). It is an
AGS/GJS-based bar with animated popups, media controls, a calendar, network manager UI,
notification center, and audio mixer.

**Config:** `modules/home-manager/desktop/hyprland/hyprpanel.nix`

Bar layout (left → middle → right):
- **Left:** dashboard launcher, workspaces, active window title, media player
- **Middle:** clock + date (`DD-MM-YYYY  HH:MM`)
- **Right:** volume, network, bluetooth, battery (if `hyprland.battery = true`), CPU%, RAM used, CPU temp, systray, notifications

Key configuration decisions:
- `systemd.enable = false` — started via `exec-once` in hyprland.nix, consistent with the rest of the desktop
- `wallpaper.enable = false` — swaybg handles wallpaper
- `theme.bar.menus.monochrome = true` — **required** for `background`/`cards`/`text` color overrides to take effect; without it per-menu Catppuccin defaults override everything
- Battery widget is gated on `hyprland.battery = true` (home.nix) — set on laptop/rugged hosts only; desktop hosts omit it. UPower 1.90.10 with `usePercentageForPolicy = true` correctly reports dual-battery percentage via the DisplayDevice.
- `bar.customModules.{cpu,ram,cpuTemp}` — correct path for custom resource modules (not `bar.{cpu,...}`)

**GLib ELOOP workaround:** HyprPanel's `readFile()` follows symlinks into the nix store
and hits the kernel ELOOP limit on multi-level symlinks. The activation scripts work around
this by:
1. `cleanHyprpanelConfig` (before linkGeneration) — wipes `~/.config/hyprpanel` so home-manager creates fresh symlinks
2. `copyHyprpanelConfig` (after linkGeneration) — dereferences `config.json` symlink to a real file, and copies `modules.scss` from the nix store

`modules.scss` is generated via `pkgs.writeText` and copied (never symlinked) to avoid the ELOOP. It contains Nord theme overrides for: calendar today indicator, systray popup menus, bar module fixed widths, media control active state, and notification popup margins.

### Startup sequence (exec-once)

Configured in `hyprland.nix`:

1. X11 font path setup for XWayland apps
2. `mkdir -p ~/Pictures/Screenshots`
3. Lid suspend state file initialisation
4. `dex --autostart --environment hyprland` — XDG autostart (udiskie, nm-applet, etc.)
5. `swaybg` — wallpaper
6. `hyprpanel` — bar
7. `hyprctl dispatch workspace 1`
8. `swayosd-server`
9. `batsignal -b -w 20 -c 10 -d 5 -n BAT0` — low battery alerts for BAT0 only (no -f flag to avoid "battery full" notification spam)
10. polkit-gnome authentication agent — required for udiskie and other privilege escalation

### Bluetooth

`services.blueman.enable = true` is set in `modules/nixos/hardware/bluetooth.nix` and
installs a system-level `/etc/xdg/autostart/blueman.desktop`. To prevent `dex` from
auto-launching the blueman tray applet (HyprPanel has its own bluetooth module), an
override is written to `~/.config/autostart/blueman.desktop` with `Hidden=true`.

`services.blueman-applet.enable = false` disables the home-manager systemd service but
does **not** stop dex from picking up the system autostart file — the override file is
required for both.

### USB Automounting (udiskie)

**File:** `modules/home-manager/services/udiskie.nix`

- `tray = "never"` — udiskie's GTK StatusIcon tray causes `gtk_widget_get_scale_factor`
  assertion failures on Wayland that crash the daemon. Running headless (no tray) is stable.
- `notify = true` — mount/unmount events appear as desktop notifications via libnotify,
  which HyprPanel's notification center catches.
- Automounting itself works correctly when headless.

### Monitor Configuration

Monitor layout is managed per-host using **nwg-displays**, a GUI tool for arranging monitors visually. A shortcut to nwg-displays is in the HyprPanel dashboard (top-left launcher menu).

The Hyprland config sources `~/.config/hypr/monitors.conf` on startup. If the file doesn't exist (e.g. on a new host), Hyprland falls back to the default `preferred,auto` layout.

**To configure monitors:**
1. Run `nwg-displays` (or click the monitor icon in the dashboard)
2. Arrange monitors and set resolutions/refresh rates
3. Click Apply — this writes `~/.config/hypr/monitors.conf`

The file persists across rebuilds since it lives outside the Nix store.

```nix
# configuration.nix
hyprland.enable = true;

# home.nix
hyprland.enable  = true;
hyprland.battery = true;   # omit on desktop hosts without a battery
```

## GNOME

- **Option:** `gnome.enable` in `configuration.nix`
- **File:** `modules/nixos/desktop/gnome.nix`

Full GNOME desktop with GDM display manager. No user-level module needed.

```nix
# configuration.nix
hyprland.enable = false;
gnome.enable = true;
```

---

## Display Managers

Display managers handle the login screen. When using Hyprland, greetd is enabled by default.

### greetd (with tuigreet)

- **Option:** `greetd.enable` (default: `true` when Hyprland is enabled)
- **File:** `modules/nixos/desktop/display-managers/greetd.nix`

Terminal-based login manager using tuigreet. Automatically configured to launch Hyprland.

### ly

- **Option:** `ly.enable` (default: `false`)
- **File:** `modules/nixos/desktop/display-managers/ly.nix`

TUI display manager similar to greetd.

To use ly instead of greetd:

```nix
# configuration.nix
greetd.enable = false;
ly.enable = true;
```

---

## Graphics Drivers

Enable exactly one that matches your hardware. Set in `configuration.nix`.

### Intel

```nix
intel-graphics.enable = true;
```

### AMD

```nix
amd-graphics.enable = true;
```

### NVIDIA

```nix
nvidia-graphics.enable = true;
```

Configures modesetting, 32-bit support, kernel modules (`nvidia`, `nvidia_modeset`, `nvidia_uvm`, `nvidia_drm`), and `nvidia-drm.modeset=1` kernel parameter.
