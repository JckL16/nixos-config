---
name: walker-decisions
description: Non-obvious Walker launcher config decisions, constraints, and workarounds
metadata:
  type: project
---

Walker 2.x GTK4 app launcher replaces Rofi/Fuzzel. Config in
`modules/home-manager/desktop/hyprland/walker.nix`.
Clipboard history in `modules/home-manager/desktop/hyprland/clipman.nix`.

## Walker 2.x requires elephant (data provider backend)
Walker was split in 2.x: `walker` (GTK4 UI, `--gapplication-service` daemon) and `elephant`
(data provider backend). Without `elephant`, walker crashes with "Please install elephant."
Enabled via `services.elephant.enable = true` in walker.nix (systemd user service,
`WantedBy=graphical-session.target`). Do NOT add `elephant` to `home.packages` manually.

**Why:** Walker 2.x delegates all provider data to the elephant daemon.
**How to apply:** Always ensure `services.elephant.enable = true` is present in walker.nix.

## Theme system changed completely in 2.x (TOML → directory of XML+CSS)
Walker 0.x used flat `<name>.css` + `<name>.toml` pairs.
Walker 2.x uses a directory `~/.config/walker/themes/<name>/` containing:
- `layout.xml` — GTK4 GtkBuilder interface definition for window/widget layout
- `item.xml` — GTK4 interface definition for each list item
- `style.css` — CSS targeting the new class names (`.box-wrapper`, `.item-box`, etc.)

No TOML files anywhere in the 2.x theme system. Per-mode themes no longer exist.
Files are copied (not symlinked) via `home.activation.copyWalkerTheme` because Walker
needs write access to the themes directory.

**Why:** Complete theme architecture rewrite in Walker 2.x.
**How to apply:** CSS class names reference: `.window`, `.box-wrapper`, `.box`,
`.search-container`, `.input`, `.item-box`, `.item-text`, `.item-subtext`,
`.item-image-text`, `.item-image`, `.item-quick-activation`. Selection:
`child:selected .item-box, row:selected .item-box`.

## -s flag meaning changed in 2.x
In Walker 0.x: `-s <name>` specified a style/theme name.
In Walker 2.x: `-s <name>` specifies a PROVIDER SET (defined in config.toml `[providers.sets]`).
Never use `-s` to set a theme. Never use `-s nord-*` flags.

**How to apply:** Strip all `-s` flags from walker invocations in keybinds and scripts.

## Module name changed: hyprland_keybinds → hyprlandkeybinds
Walker 2.x uses `hyprlandkeybinds` (no underscore). Old `hyprland_keybinds` is invalid.
Use `walker -m hyprlandkeybinds` for the keybinds browser.

## Walker 2.x dmenu API: no column selection
Walker 2.x removed `-t` (tab delimiter), `-l` (label column), and `-V` (value column) from dmenu.
`-t` in 2.x means `--theme`. The old column-selection dmenu API is gone entirely.
Walker 2.x dmenu just reads stdin lines and outputs the selected line unchanged to stdout.

**How to apply:** Never use `-t $'\t' -l N -V N` in Walker invocations — they are invalid.
For scripts that need to extract a field from the selected line, use `awk`/`cut` on Walker's output.

## Clipboard picker: simple pipe
`cliphist list` outputs `ID\tpreview` lines. Walker dmenu shows them and outputs the selected line.
`cliphist decode` accepts the full `ID\tpreview` line from stdin — so the script is a direct pipe:
```bash
entry=$(cliphist list | walker -d -p "Paste...")
[ -n "$entry" ] && printf '%s' "$entry" | cliphist decode | wl-copy
```
Script lives at `~/.config/walker/clipboard.sh` (defined in walker.nix).

**Why:** Walker 2.x dmenu passes through the whole selected line; cliphist decode expects exactly that format.

## Window switcher: use native provider
`walker -m windows` uses Walker's built-in Hyprland window provider. The old custom `windows.sh`
used `-t $'\t' -l 0 -V 1` flags that no longer exist in 2.x. Keybind: `$mod, Tab, exec, walker -m windows`.

## Calculator prefix must be + not =
Walker passes the FULL input string (including prefix character) to qalc.
`=1+1` → qalc receives `=1+1` → evaluates as `(0 = (1+1)) = false`.
`+` is safe as unary plus. Use `+` for calc prefix, `=` for websearch.

[[project_hyprpanel]]
