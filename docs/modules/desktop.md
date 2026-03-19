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
- Polkit, printing, udisks2 (USB automounting)
- System packages: wayland, kitty, waybar, rofi, wl-clipboard

### User-level

**File:** `modules/home-manager/desktop/hyprland/`

Provides:
- Hyprland keybindings and window rules
- Waybar (status bar) configuration
- Mako (notification daemon)
- Clipman (clipboard manager)
- Rofi (application launcher) theme
- Nordic GTK theme
- SwayOSD (volume/brightness OSD)
- Wlogout (logout menu)

```nix
# configuration.nix
hyprland.enable = true;

# home.nix
hyprland.enable = true;
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
