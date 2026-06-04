# modules/home-manager/desktop/hyprland/walker.nix
# Walker — GTK4 app launcher.
# Nord theme matching HyprPanel popup menus.
# Per-mode Nerd Font prompt icons via hicolor SVG icons.

{ pkgs, lib, config, ... }:

let
  # Shared CSS for all modes.
  walkerCss = pkgs.writeText "walker-nord.css" ''
    @define-color foreground #ECEFF4;
    @define-color background rgba(46, 52, 64, 0.92);
    @define-color selection rgba(59, 66, 82, 0.85);
    @define-color border rgba(76, 86, 106, 0.5);
    @define-color dimtext rgba(216, 222, 233, 0.6);

    #window,
    #box,
    #aiScroll,
    #aiList,
    #search,
    #password,
    #input,
    #prompt,
    #clear,
    #typeahead,
    #list,
    child,
    scrollbar,
    slider,
    #item,
    #text,
    #label,
    #bar,
    #sub,
    #activationlabel {
      all: unset;
    }

    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 14px;
      color: @foreground;
    }

    #window {
      color: @foreground;
    }

    #box {
      background-color: @background;
      border: 1px solid @border;
      border-radius: 8px;
      padding: 10px;
    }

    #search {
      background-color: rgba(59, 66, 82, 0.5);
      border: 1px solid @border;
      border-radius: 6px;
      padding: 6px;
      margin-bottom: 6px;
    }

    #input {
      color: @foreground;
      padding: 4px 8px;
    }

    #prompt {
      opacity: 0.55;
      color: @foreground;
      margin-left: 4px;
      margin-right: 8px;
      font-size: 16px;
    }

    #clear {
      opacity: 0.6;
      color: @foreground;
      margin-right: 4px;
    }

    #input placeholder {
      color: @dimtext;
    }

    #list {
      color: @foreground;
    }

    child {
      padding: 8px 12px;
      border-radius: 4px;
    }

    child:selected,
    child:hover {
      background-color: @selection;
    }

    #icon {
      -gtk-icon-size: 0px;
      min-width: 0;
      min-height: 0;
      margin: 0;
      padding: 0;
      opacity: 0;
    }

    #label {
      font-weight: 500;
    }

    #sub {
      opacity: 0.6;
      font-size: 0.85em;
    }

    scrollbar {
      opacity: 0;
    }

    #spinner {
      padding: 8px;
    }

    #cfgerr {
      background-color: rgba(191, 97, 106, 0.85);
      margin-top: 10px;
      padding: 8px;
      border-radius: 4px;
    }
  '';

  # Per-mode TOML — only the prompt icon name differs.
  # icon names resolve to Nerd Font SVGs installed in hicolor (see activation script).
  makeToml = icon: pkgs.writeText "walker-nord-${icon}.toml" ''
    [ui.anchors]
    bottom = true
    left = true
    right = true
    top = true

    [ui.window]
    h_align = "fill"
    v_align = "fill"

    [ui.window.box]
    h_align = "center"
    v_align = "center"
    width = 520

    [ui.window.box.bar]
    orientation = "horizontal"
    position = "end"

    [ui.window.box.bar.entry]
    h_align = "fill"
    h_expand = true

    [ui.window.box.bar.entry.icon]
    h_align = "center"
    h_expand = true
    pixel_size = 24
    theme = ""

    [ui.window.box.scroll.list]
    max_height = 320
    max_width = 500
    min_width = 500
    width = 500

    [ui.window.box.scroll.list.item.activation_label]
    h_align = "fill"
    v_align = "fill"
    width = 20
    x_align = 0.5
    y_align = 0.5

    [ui.window.box.scroll.list.item.icon]
    hide = true
    theme = ""

    [ui.window.box.scroll.list.margins]
    top = 8

    [ui.window.box.search.prompt]
    name = "prompt"
    icon = "${icon}"
    theme = "hicolor"
    pixel_size = 16
    h_align = "center"
    v_align = "center"

    [ui.window.box.search.clear]
    name = "clear"
    icon = "edit-clear"
    theme = ""
    pixel_size = 16
    h_align = "center"
    v_align = "center"

    [ui.window.box.search.input]
    h_align = "fill"
    h_expand = true
    v_align = "center"
    icons = true

    [ui.window.box.search.spinner]
    hide = true
  '';

  tomlApps      = makeToml "walker-apps";
  tomlWindows   = makeToml "walker-windows";
  tomlClipboard = makeToml "walker-clipboard";
  tomlWebsearch = makeToml "walker-websearch";
  tomlKeybinds  = makeToml "walker-keybinds";

in {

  config = lib.mkIf config.hyprland.enable {
    home.packages = with pkgs; [ walker qalculate-qt libqalculate ];

    home.file.".config/walker/config.toml".text = ''
      theme = "nord"
      close_when_open = true
      click_to_close = true
      single_click_activation = false
      hide_action_hints = true
      hide_return_action = true
      hide_action_hints_dmenu = true

      [shell]
      exclusive_zone = -1
      layer = "overlay"
      anchor_top = true
      anchor_bottom = true
      anchor_left = true
      anchor_right = true

      [providers]
      default = ["desktopapplications"]
      empty = ["desktopapplications"]
      max_results = 8

      [[providers.prefixes]]
      prefix = "="
      provider = "websearch"

      [[providers.prefixes]]
      prefix = "+"
      provider = "calc"
    '';

    # Walker 0.13.26 theme system:
    #   - Flat files in ~/.config/walker/themes/: nord.css + per-mode *.toml
    #   - Copied (not symlinked) so Walker can write to the themes dir
    #   - Nerd Font prompt icons: SVGs installed to hicolor scalable/apps
    #     GTK finds hicolor icons as the universal fallback regardless of active theme
    home.activation.copyWalkerTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      mkdir -p "$HOME/.config/walker/themes"
      mkdir -p "$HOME/.local/share/icons/hicolor/scalable/apps"

      # Install Nerd Font SVG icons for Walker mode prompt indicators.
      # SVG text rendered by librsvg using the installed JetBrainsMono Nerd Font.
      # fill="#ECEFF4" = Nord Snow Storm (Walker foreground colour).
      install_nf_icon() {
        local name="$1" glyph="$2"
        printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><text x="8" y="14" font-family="JetBrainsMono Nerd Font" font-size="14" text-anchor="middle" fill="#ECEFF4">%s</text></svg>' \
          "$glyph" > "$HOME/.local/share/icons/hicolor/scalable/apps/$name.svg"
      }

      install_nf_icon "walker-apps"      "󰍉"
      install_nf_icon "walker-windows"   "󱂬"
      install_nf_icon "walker-clipboard" "󰅎"
      install_nf_icon "walker-websearch" "󰖟"
      install_nf_icon "walker-keybinds"  "󰌌"

      # Walker loads <theme-name>.css alongside each TOML.
      # The CSS is identical for all modes — copy it once per theme name.
      for theme in nord nord-windows nord-clipboard nord-websearch nord-keybinds; do
        cp --no-preserve=all "${walkerCss}" "$HOME/.config/walker/themes/$theme.css"
      done

      # Per-mode TOMLs — default (apps) must be named "nord" to match config.toml theme
      cp --no-preserve=all "${tomlApps}"      "$HOME/.config/walker/themes/nord.toml"
      cp --no-preserve=all "${tomlWindows}"   "$HOME/.config/walker/themes/nord-windows.toml"
      cp --no-preserve=all "${tomlClipboard}" "$HOME/.config/walker/themes/nord-clipboard.toml"
      cp --no-preserve=all "${tomlWebsearch}" "$HOME/.config/walker/themes/nord-websearch.toml"
      cp --no-preserve=all "${tomlKeybinds}"  "$HOME/.config/walker/themes/nord-keybinds.toml"

      # Rebuild icon cache so GTK4 picks up the new hicolor SVGs immediately
      gtk4-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
    '';

    # Window switcher: list all Hyprland clients, focus the selected one.
    home.file.".config/walker/windows.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        address=$(hyprctl clients -j | jq -r \
          '.[] | .title + " [" + .class + "]" + "\t" + .address' \
          | walker --dmenu -s nord-windows -t $'\t' -l 0 -V 1 -p 'Switch window')
        [ -n "$address" ] && hyprctl dispatch focuswindow "address:$address"
      '';
    };
  };
}
