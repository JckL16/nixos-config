---
name: project-kitty-terminal-migration
description: Why Kitty replaced Alacritty as the default terminal (ligature support)
metadata:
  type: project
---

Jack switched the default terminal from Alacritty to Kitty (completed 2026-10-12) specifically
to get programming ligatures (`->`, `<=`, `==`, etc. rendered as single glyphs) in terminal
Neovim. The font (`JetBrainsMono Nerd Font`) already supported ligatures — Alacritty's
maintainers have permanently declined to implement ligature rendering, which is what forced the
terminal swap rather than a font or nixvim change. Kitty was chosen over WezTerm because its
home-manager module config shape (plain Nix attrs) matches the existing `alacritty.nix` style
instead of introducing a Lua config.

**Why this is worth keeping:** the "font already supports it, Alacritty is the actual blocker"
diagnosis isn't obvious from the code and took investigation to establish — useful if a similar
"can nixvim do X" question comes up for a terminal-level rendering feature again.

**How to apply:** Alacritty is fully removed from this repo now (no module, no fallback) — don't
suggest reverting to it without the user raising it first. Kitty config lives in
`modules/home-manager/programs/terminals/kitty.nix`.

**Known gotcha (fixed):** Kitty >=0.49 (nixpkgs has 0.49.1) extended `remember_window_size`
(default `yes`) to also persist maximized/fullscreen state, and Hyprland honors that request on
new windows — so once any kitty window was ever maximized, every subsequent instance reopens
maximized/fullscreen, filling the whole tile even with other windows already on the same
workspace (confirmed: panel/bar stayed visible since it's a layer-shell surface, only the
toplevel was maximized). Fixed by setting `remember_window_size = "no";` in kitty.nix's
`settings`. If kitty is ever upgraded and this regresses again, check that setting first before
assuming a Hyprland windowrule issue.
