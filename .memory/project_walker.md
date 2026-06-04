---
name: walker-decisions
description: Non-obvious Walker launcher config decisions, constraints, and workarounds
metadata:
  type: project
---

Walker 0.13.26 GTK4 app launcher replaces Rofi/Fuzzel. Config in
`modules/home-manager/desktop/hyprland/walker.nix`.
Clipboard history in `modules/home-manager/desktop/hyprland/clipman.nix`.

## Theme system requires copied files, not symlinks
Walker needs to write to its themes directory. `home.file` (read-only symlinks) breaks this.
Fix: `home.activation.copyWalkerTheme` runs after `linkGeneration`, uses `cp --no-preserve=all`
to copy CSS and TOML files. Each mode needs its own `<name>.css` AND `<name>.toml` pair —
missing CSS causes the mode to fall back to white GTK defaults.

**Why:** Walker modifies themes dir at runtime; symlinks into nix store are read-only.

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

## Prompt icons via hicolor SVG
GTK4 cannot render Nerd Font glyphs as icon names directly. Workaround: install SVG files
with `<text font-family="JetBrainsMono Nerd Font">glyph</text>` to
`~/.local/share/icons/hicolor/scalable/apps/<name>.svg`. hicolor is the universal fallback
GTK searches regardless of active theme.

## No built-in window switcher module
Walker has no Hyprland window switcher module. `walker -m windows` opens Walker's own
module picker. Custom script at `~/.config/walker/windows.sh` uses
`hyprctl clients -j | jq | walker --dmenu` with `-t $'\t' -l 0 -V 1` to switch windows.

## Calculator prefix must be + not =
Walker passes the FULL input string (including prefix character) to qalc.
`=1+1` → qalc receives `=1+1` → evaluates as `(0 = (1+1)) = false`.
`+` is safe as unary plus. Use `+` for calc prefix, `=` for websearch.

[[project_hyprpanel]]
