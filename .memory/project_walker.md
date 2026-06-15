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

## -V flag is 1-indexed; 0 and omitted both output nothing
Walker `--dmenu` mode requires `-V N` where N ≥ 1 to produce stdout output.
`-V 0` outputs nothing. Omitting `-V` also outputs nothing.
`-V 1` returns the second tab-separated column (same pattern as windows.sh).

**Why:** Confirmed via debug logging. `-V 0` evaluated as falsy/null by walker.
**How to apply:** Always use `-V 1` for dmenu value return. If you need column 0 (first field),
reverse the columns with awk before piping to walker.

## Clipboard picker: awk reversal + grep reconstruction
`cliphist list` outputs `ID\tpreview`. To show preview as label and return ID as value:
1. `awk 'BEGIN{FS=OFS="\t"} {print $2, $1}'` reverses to `preview\tID`
2. Walker: `-t $'\t' -l 0 -V 1` — shows column 0 (preview), returns column 1 (ID)
3. `grep -Pm1 "^$id\t"` reconstructs full `ID\tpreview` line from cliphist list
4. Full line piped to `cliphist decode` which needs the tab-separated format

**Why:** `cliphist decode` requires the full `ID\tpreview` line from stdin;
just the ID alone does not work. Walker's -V 0 limitation forces the awk workaround.

## Calculator prefix must be + not =
Walker passes the FULL input string (including prefix character) to qalc.
`=1+1` → qalc receives `=1+1` → evaluates as `(0 = (1+1)) = false`.
`+` is safe as unary plus. Use `+` for calc prefix, `=` for websearch.

## No built-in window switcher script
Walker 2.x has a `windows` provider, but the custom `~/.config/walker/windows.sh` uses
`hyprctl clients -j | jq | walker --dmenu` with `-t $'\t' -l 0 -V 1` to switch windows.
Kept as custom script for reliable window focus via `hyprctl dispatch focuswindow`.

[[project_hyprpanel]]
