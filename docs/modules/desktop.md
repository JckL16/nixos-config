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
| `hyprland.nix` | Keybindings, window rules, layer rules, exec-once startup, keyboard input options |
| `hyprpanel.nix` | HyprPanel bar — replaces Waybar and Mako |
| `nordic-theme.nix` | Nordic GTK theme, Papirus icons, Nordzy cursors, GTK popup CSS |
| `walker.nix` | Walker GTK4 app launcher — Nord theme, per-mode prompt icons, window switcher |
| `clipman.nix` | Clipboard history via cliphist; picker via walker `--dmenu` |
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

### Keyboard Input

Configured in `hyprland.nix` under `input`:
- `kb_layout` — primary layout from `variables.keyboard-layout` with `,us` fallback; switched with `Alt+Shift`
- `kb_options = "grp:alt_shift_toggle,caps:escape"` — Caps Lock acts as Escape system-wide

### Walker (App Launcher)

**File:** `modules/home-manager/desktop/hyprland/walker.nix`

Walker is a GTK4 application launcher styled with a Nord glassmorphism theme. It replaces Rofi/Fuzzel.

| Keybind | Action |
|---|---|
| `Super+D` | App launcher (desktop apps + shell runner) |
| `Super+Tab` | Window switcher (custom hyprctl script) |
| `Super+Shift+D` | Web search (`=` prefix in main launcher also works) |
| `Super+F1` | Search Hyprland keybinds (`hyprlandkeybinds` module) |
| `Super+Shift+V` | Clipboard history picker |

Prefix shortcuts in the main launcher:
- `=` — web search
- `+` — calculator (qalculate)
- `>` — shell command runner

**Services:** Walker 2.x requires the `elephant` data provider backend. Enabled via `services.elephant.enable = true` in walker.nix, which creates a systemd user service (`WantedBy=graphical-session.target`). The `walker --gapplication-service` daemon is started via Hyprland's `exec-once`. **After a theme change, restart the Walker daemon** (`pkill walker && walker --gapplication-service &`) since it caches the theme at startup.

**Theme system:** Walker 2.x uses a directory-based theme format: `~/.config/walker/themes/nord/` containing `layout.xml` (GTK4 interface definition), `item.xml` (list item template), and `style.css` (Nord colours). Files are copied via `home.activation.copyWalkerTheme` (not symlinked) because Walker needs write access to the themes directory. The `-s` flag in Walker 2.x means "provider set", not style — never use `-s` for theme selection.

**`-V` flag behaviour (non-obvious):** Walker's `--dmenu` mode requires `-V N` where N ≥ 1 to produce any stdout output. `-V 0` outputs nothing; omitting `-V` also outputs nothing. Use `-V 1` to return the second tab-separated column — the same pattern used in the window switcher script.

### Clipboard History (cliphist)

**File:** `modules/home-manager/desktop/hyprland/clipman.nix`

Clipboard history is captured by `cliphist` (via a systemd user service running `wl-paste --watch cliphist store`) and browsed with the Walker dmenu picker.

The picker script (`~/.config/walker/clipboard.sh`) works around two non-obvious constraints:
1. `cliphist list` outputs `ID\tpreview` — awk reverses this to `preview\tID` so Walker can show the content as the label (`-l 0`) and return the ID as the value (`-V 1`)
2. `grep -Pm1 "^$id\t"` then reconstructs the full `ID\tpreview` line from cliphist list so `cliphist decode` receives the format it expects

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
