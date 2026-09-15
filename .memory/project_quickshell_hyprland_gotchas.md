---
name: project-quickshell-hyprland-gotchas
description: Verified QuickShell/Qt6 API gotchas, Hyprland portal/EDS system quirks, QML animation pitfalls, and bar widget spacing/padding quirks found while building the QuickShell bar
metadata:
  type: project
---

Technical reference distilled from in-code comments removed during a cleanup pass (user asked
to strip all comments from [[project_serpantinum_bar_fork]]'s code and move anything worth
keeping here). These are concrete, verified facts — not preferences — reusable for any future
work touching this repo's QuickShell bar, Hyprland config, or EDS/GNOME Calendar integration.

**Why:** Removing the code comments meant this context stopped being derivable from the code
itself; several of these took multiple failed rebuild/restart cycles to root-cause the first
time (verified against real C++ headers/upstream source each time, not guessed).

**How to apply:** Consult before touching QuickShell QML, Hyprland windowrules/portals, or the
EDS-backed calendar script again — several of these look like they should work from web-search
summaries alone and don't.

## QuickShell/Qt6 QML API (verified against quickshell-mirror source headers)

- `Text` (QtQuick) has **no** `cursorShape` or `hoverEnabled` property. `Text.hoveredLink` /
  `linkActivated` / `linkColor` (with `textFormat: Text.StyledText`) are real. For a pointer
  cursor over a link, add a sibling `MouseArea` with `cursorShape` computed independently
  (don't rely on `hoveredLink` for the cursor — compute "is this a link" in JS instead).
- `PopupWindow.closePolicy` doesn't exist; `grabFocus: true` is the real click-outside-to-close
  property (`popupwindow.hpp`).
- `NetworkDevice.deviceType` doesn't exist; it's `.type` (`network/device.hpp`).
- `WifiDevice.scanning` doesn't exist; it's `scannerEnabled` (`network/wifi.hpp`).
- `NetworkDevice.hasLink` doesn't exist (fabricated in upstream Serpantinum source, carried over
  without verification); use `.connected` / `.state` (`ConnectionState` enum).
- `PanelWindow`/`WlrLayershell.exclusionMode` defaults to `Auto`, which respects **other**
  layer-shell surfaces' `exclusiveZone` reservations even across different layers (e.g. an
  Overlay-layer full-screen dim window will still leave a Top-layer bar's reserved strip
  undimmed). Set `exclusionMode: ExclusionMode.Ignore` to make it truly cover everything.
- `WlrLayershell.keyboardFocus` defaults to `None` (zero keyboard input) — must explicitly set
  `WlrKeyboardFocus.OnDemand` for Escape/keybinds to work in a popup or overlay window.
- `WlrLayershell` property changes (`namespace`, `exclusionMode`, `keyboardFocus`) only take
  effect at window **connection** time. A `systemctl --user restart quickshell` is required to
  see them apply — `test` alone (which triggers a QML hot-reload) is not enough, since
  already-connected `PanelWindow` instances stay alive across reloads and just toggle `visible`.

## Hyprland windowrule syntax

Hyprland 0.53+ replaced the legacy `windowrule = PROPERTY on class:^(x)$` form with
comma-separated `match:` clauses: `windowrule = float on, match:class ^(x)$`. The old form
silently matches **nothing** on 0.55.4+ — no error, just a dead rule. Confirmed live via
`hyprctl clients`/`hyprctl keyword` testing, not docs (which still show the old form in places).

## xdg-desktop-portal under Hyprland

- home-manager's `wayland.windowManager.hyprland` module bundles its own
  `hyprland-portals.conf` (via `xdg.portal.configPackages`, generated from the hyprland package
  itself) at `~/.config/xdg-desktop-portal/hyprland-portals.conf` (XDG_CONFIG_HOME — high
  priority). Desktop-specific config filenames (`<desktop>-portals.conf`) are searched across
  **all** XDG locations before any generic `portals.conf` is even considered, so a NixOS-level
  `xdg.portal.config.common` override (landing in a lower-priority location, generic filename)
  never gets reached. To actually override, set it at the **home-manager** level with the
  desktop-matching key: `xdg.portal.config.hyprland = { ... };` (key must be `"hyprland"` to
  produce `hyprland-portals.conf`, not `"common"`).
- The GTK portal's own `.portal` file declares `UseIn=gnome`. Under Hyprland, the legacy
  UseIn-based desktop-matching fallback won't select it even as the only available backend for
  an interface — need explicit `match:`/interface routing in portals.conf
  (`"org.freedesktop.impl.portal.Settings" = ["gtk"];` etc.) **and** the GTK portal's own
  package must be installed into the same profile (`home.packages`) as Hyprland's portal, since
  portal-implementation `.portal` files apparently aren't merged across separate Nix profiles
  the way most XDG data is.
- GNOME Calendar (and other libadwaita apps) crash with `assertion 'tz != NULL' failed` if
  `TZDIR` isn't in their environment. NixOS sets `TZDIR=/etc/zoneinfo` via
  `environment.sessionVariables`, but that only reaches PAM-managed login sessions — apps
  launched from inside an already-running Hyprland session/terminal don't inherit it. Fix: add
  `"TZDIR,/etc/zoneinfo"` to Hyprland's own `env` list in `wayland.windowManager.hyprland`. This
  is applied once at compositor startup, not hot-reloadable — needs a full logout/login (or
  reboot after `switch`), a plain `test` is not enough for this specific fix.
- GNOME Calendar needs `services.gnome.evolution-data-server.enable = true` (NixOS) outside a
  full GNOME session, else calendar sources fail with `Sources5 ... no owner found`.
- libadwaita apps ignore the legacy GTK3 `gtk-application-prefer-dark-theme` setting entirely.
  Dark mode is read from the Settings portal's `org.freedesktop.appearance color-scheme`, which
  xdg-desktop-portal-gtk answers from the dconf key `org/gnome/desktop/interface color-scheme` —
  set via home-manager's `dconf.settings` for dark libadwaita apps under a non-GNOME compositor.

## evolution-data-server (EDS) calendar cache

- `~/.cache/evolution/calendar/<source-id>/cache.db`'s `ECacheObjects` table stores
  `summary`/`location` as an **accent-folded, lowercased search index** — not display text.
  Diacritics (å/ä/ö etc.) and original casing are stripped for search purposes. The real text
  survives in the `ECacheOBJ` column (the full serialized VEVENT block) and must be re-parsed
  from there (regex on `SUMMARY:`/`LOCATION:` lines) for correct display.
- `occur_start`/`occur_end` in that same table ARE reliable digit-only UTC timestamps
  (`YYYYMMDDHHMMSS`, no timezone suffix) — convert to local time via jq's
  `strptime("%Y%m%d%H%M%S") | mktime | localtime | strftime(...)`, which follows the system
  timezone.
- Only sources with an active webcal/CalDAV sync get a `cache.db` at all. Purely local EDS
  calendars (created directly in GNOME Calendar, "local" backend) store as flat `.ics` files
  under `~/.local/share/evolution/calendar/<id>/calendar.ics` instead, with no SQLite cache and
  no accent-folding problem (since there's no search index for them).

## Terminal TUI tool launchers (nmtui / newt)

- `nmtui`/`newt`-based TUIs compute their dialog's centered position **once at startup** based
  on the terminal's size at that moment. If Hyprland force-resizes the terminal window via a
  `windowrule = ..., size W H` **after** the terminal's initial launch, the dialog ends up
  visibly off-center (a stale-size race). Fix: don't force a `size` in the windowrule at all —
  let the terminal launch at its own natural default size, avoiding any resize-after-launch race
  entirely, and just use `float on, center on`.
- Alacritty's `-o key=value` CLI flag accepts arbitrary TOML config overrides scoped to that one
  invocation (e.g. `-o 'keyboard.bindings=[{key="Escape",action="Quit"}]'`) — useful for
  one-off floating-terminal tool launchers without touching the global Alacritty config.
- `NEWT_COLORS` env var (`field=fg,bg field2=fg2,bg2 ...`) themes newt-based TUIs like `nmtui`;
  on a truecolor terminal (Alacritty) it accepts real hex values, not just the classic 8 ANSI
  color names some docs imply are the only option.

## Bar widget spacing (found while tightening gaps between all bar modules)

- The bar's inter-widget "gap" a user perceives is the sum of **two independent layers**: the
  fixed chain gap in `Bar.qml`'s `targetX` bindings (`barWindow.s(N)`, same for every pair), plus
  each widget's *own* internal edge padding baked into its width formula. Both have to be tuned
  together — changing only the chain gap while leaving per-widget padding inconsistent (some
  widgets `s(4)`/side, others `s(8)`/side) produces visibly uneven spacing even though the chain
  gap itself is uniform.
- **Identical numeric per-side padding does not produce identical visual gaps** across widget
  types. `ClickButton`-based widgets (Vol/Network/Bt — Nerd Font icon + text) rendered
  consistently "correctly sized" at a given padding value, but `BatWidget`/`NotificationWidget`
  (plain `Row`/`RowLayout` of `Text` glyphs) and `TrayWidget` (real bitmap `Image` icons, zero
  font bearing) looked visibly tighter at the *same* padding constant. Root cause is Nerd Font
  glyph side-bearing varying per icon/font-rendering-path, not the container padding — this isn't
  fixable by computing "the right number" once; it needs a padding value bumped specifically for
  the non-`ClickButton` widgets (ended up ~1.75x larger for Bat/Notification/Tray vs Vol/Network/Bt
  to look visually equal) and confirmed by eye against a screenshot, not assumed from the code.
- Grouping two independently-padded, transparent-background pills tightly (e.g. CPU+RAM in
  `SysMonWidget`) can't be done by shrinking the parent `Row`'s `spacing` alone if each child pill
  has its own baked-in width formula (`child.implicitWidth + s(8)`, i.e. padding on *both* sides
  of each pill) — the pills' own facing-inward padding still applies regardless of `Row.spacing`.
  Fix: use **negative** `Row.spacing` (e.g. `-s(6)`) to overlap the transparent rectangles by
  exactly the facing-inward padding amount, cancelling it while leaving each pill's *outer*-facing
  edge (and thus its gap to the next widget in the chain) untouched. Safe here specifically because
  the pills have no visible background/border to clip.
- This repo's Hyprland `gaps_in`/`gaps_out` (`hyprland.nix`) is `4`/`6` — bar-edge alignment
  (leftmost workspace pill vs. where tiled windows actually start) should be tuned to match
  `gaps_out` exactly, not guessed.

## QML animation/z-order pitfalls (found in WorkspacesWidget)

- A separately z-layered, animated "highlight" `Rectangle` sliding behind/over a `Repeater`'s
  sibling items is fragile in both directions: above the siblings (higher `z`) it visually
  covers their content entirely regardless of the siblings' own color; below them (lower `z`)
  it becomes visible through the **gaps** between siblings during a slide transition, looking
  like a flickering artifact as it passes underneath. Simpler and more robust: color each item's
  own background directly for the "selected" state (with its own `Behavior on color`) instead of
  overlaying a separate animated highlight shape that has to track positions independently.
- Chaining several `Behavior on x` animations off each other's `x + width` (self-positioning bar
  widgets with no real layout container) compounds into a slow, laggy cascade whenever any
  upstream widget resizes (e.g. tray icon count changing). Omit the `Behavior` on `x` itself for
  widgets whose position is *derived* from a neighbor's current size — only animate the width
  change, not the resulting cascade of position changes.
