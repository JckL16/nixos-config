---
name: project-theme-monochrome-todo
description: Monochrome grey/white/black theme — done. Palette choice, tradeoffs, and where to look if colors need adjusting.
metadata:
  type: project
---

`variables.theme` is set to `"monochrome"`, a new preset in `modules/home-manager/theme/presets.nix`.
Done, not a pending task anymore.

**Why this palette:** Uses [Base16 "Grayscale Dark"](https://github.com/tinted-theming/base16-schemes)
by Alexandre Gavioli — a real, actively-maintained scheme with ports for terminals, Vim/Neovim,
tmux, rofi, waybar, etc., so it carries over to other apps too (already wired into Neovim via
`colorschemes.base16` in `modules/home-manager/programs/command-line/nvim/default.nix`, using the
same hex values directly rather than a builtin name, to guarantee an exact match — see
[[project_quickshell_hyprland_gotchas]]).

**Structural ladder is shifted one step lighter than stock base16** — `#101010` (the scheme's own
base) is dropped entirely; `background` uses what upstream calls `backgroundAlt`'s tone instead
(preferred after seeing it in Alacritty). Base16's dark tier only has 4 rungs (base00-03) and
`background` now claims two of them, so `border`/`nord3` uses a custom in-between gray
(`#6e6e6e`) rather than reusing `surface`'s value — needed genuinely distinct shades, since e.g.
WorkspacesWidget's occupied-vs-empty pill colors both read from this tier and became
indistinguishable when they collided during an earlier iteration.

**No hue anywhere, by design.** `urgent`/`warning`/`success` are distinguished by luminance
(near-white → mid gray) rather than color — an inherent tradeoff of going pure grayscale, not a
bug if something looks like it "should" be red/yellow/green and isn't.

**How to apply / adjust further:** Edit the `monochrome` preset directly in `presets.nix` (matches
the same `colors`/`font`/`gtk` shape as `nord`/`gruvbox`/`dracula`/`tokyo-night`). For a
pixel-perfect dedicated GTK theme (this preset currently just uses `adw-gtk3-dark`, already fairly
neutral but not literally grayscale-branded), `vinceliuice/Graphite-gtk-theme`
(nixpkgs: `graphite-gtk-theme`) ships a real neutral-grey variant — its Nix build needs explicit
`themeVariants = [ "default" ]; colorVariants = [ "dark" ];` overrides (upstream defaults to a
blue-accented variant, not plain grey) rather than a plain package reference, which is why it
wasn't wired in automatically.
