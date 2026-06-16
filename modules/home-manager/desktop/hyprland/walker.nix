# modules/home-manager/desktop/hyprland/walker.nix
# Walker — GTK4 app launcher.
# Nord theme using Walker 2.x directory-based format (layout.xml + item.xml + style.css).

{ pkgs, lib, config, ... }:

let
  # GTK4 window layout — 520px wide, 320px max list height.
  walkerLayout = pkgs.writeText "walker-layout.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <interface>
    <requires lib="gtk" version="4.0"></requires>
    <object class="GtkWindow" id="Window">
      <style><class name="window"></class></style>
      <property name="resizable">true</property>
      <property name="title">Walker</property>
      <child>
        <object class="GtkBox" id="BoxWrapper">
          <style><class name="box-wrapper"></class></style>
          <property name="overflow">hidden</property>
          <property name="orientation">horizontal</property>
          <property name="valign">center</property>
          <property name="halign">center</property>
          <property name="width-request">520</property>
          <property name="height-request">480</property>
          <child>
            <object class="GtkBox" id="Box">
              <style><class name="box"></class></style>
              <property name="orientation">vertical</property>
              <property name="hexpand-set">true</property>
              <property name="hexpand">true</property>
              <property name="spacing">8</property>
              <child>
                <object class="GtkBox" id="SearchContainer">
                  <style><class name="search-container"></class></style>
                  <property name="overflow">hidden</property>
                  <property name="orientation">horizontal</property>
                  <property name="halign">fill</property>
                  <property name="hexpand-set">true</property>
                  <property name="hexpand">true</property>
                  <child>
                    <object class="GtkEntry" id="Input">
                      <style><class name="input"></class></style>
                      <property name="halign">fill</property>
                      <property name="hexpand-set">true</property>
                      <property name="hexpand">true</property>
                    </object>
                  </child>
                </object>
              </child>
              <child>
                <object class="GtkBox" id="ContentContainer">
                  <style><class name="content-container"></class></style>
                  <property name="orientation">horizontal</property>
                  <property name="spacing">10</property>
                  <child>
                    <object class="GtkLabel" id="ElephantHint">
                      <style><class name="elephant-hint"></class></style>
                      <property name="label">Waiting for elephant...</property>
                      <property name="hexpand">true</property>
                      <property name="vexpand">true</property>
                      <property name="visible">false</property>
                      <property name="valign">0.5</property>
                    </object>
                  </child>
                  <child>
                    <object class="GtkLabel" id="Placeholder">
                      <style><class name="placeholder"></class></style>
                      <property name="label">No Results</property>
                      <property name="hexpand">true</property>
                      <property name="vexpand">true</property>
                      <property name="valign">0.5</property>
                    </object>
                  </child>
                  <child>
                    <object class="GtkScrolledWindow" id="Scroll">
                      <style><class name="scroll"></class></style>
                      <property name="can_focus">false</property>
                      <property name="overlay-scrolling">true</property>
                      <property name="hexpand">true</property>
                      <property name="vexpand">true</property>
                      <property name="max-content-width">500</property>
                      <property name="min-content-width">500</property>
                      <property name="max-content-height">320</property>
                      <property name="propagate-natural-height">true</property>
                      <property name="propagate-natural-width">true</property>
                      <property name="hscrollbar-policy">automatic</property>
                      <property name="vscrollbar-policy">automatic</property>
                      <child>
                        <object class="GtkGridView" id="List">
                          <style><class name="list"></class></style>
                          <property name="max_columns">1</property>
                          <property name="min_columns">1</property>
                          <property name="can_focus">false</property>
                        </object>
                      </child>
                    </object>
                  </child>
                  <child>
                    <object class="GtkBox" id="Preview">
                      <style><class name="preview"></class></style>
                    </object>
                  </child>
                </object>
              </child>
              <child>
                <object class="GtkBox" id="Keybinds">
                  <property name="hexpand">true</property>
                  <property name="margin-top">10</property>
                  <style><class name="keybinds"></class></style>
                  <child>
                    <object class="GtkBox" id="GlobalKeybinds">
                      <property name="spacing">10</property>
                      <style><class name="global-keybinds"></class></style>
                    </object>
                  </child>
                  <child>
                    <object class="GtkBox" id="ItemKeybinds">
                      <property name="hexpand">true</property>
                      <property name="halign">end</property>
                      <property name="spacing">10</property>
                      <style><class name="item-keybinds"></class></style>
                    </object>
                  </child>
                </object>
              </child>
              <child>
                <object class="GtkLabel" id="Error">
                  <style><class name="error"></class></style>
                  <property name="xalign">0</property>
                  <property name="visible">false</property>
                </object>
              </child>
            </object>
          </child>
        </object>
      </child>
    </object>
    </interface>
  '';

  # Item template — Walker 2.x default structure.
  walkerItem = pkgs.writeText "walker-item.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <interface>
    <requires lib="gtk" version="4.0"></requires>
    <object class="GtkBox" id="ItemBox">
      <style><class name="item-box"></class></style>
      <property name="orientation">horizontal</property>
      <property name="spacing">10</property>
      <child>
        <object class="GtkLabel" id="ItemImageFont">
          <style><class name="item-image-text"></class></style>
          <property name="width-chars">2</property>
        </object>
      </child>
      <child>
        <object class="GtkImage" id="ItemImage">
          <style><class name="item-image"></class></style>
          <property name="icon-size">large</property>
        </object>
      </child>
      <child>
        <object class="GtkBox" id="ItemTextBox">
          <style><class name="item-text-box"></class></style>
          <property name="orientation">vertical</property>
          <property name="vexpand">true</property>
          <property name="hexpand">true</property>
          <property name="vexpand-set">true</property>
          <property name="spacing">0</property>
          <child>
            <object class="GtkLabel" id="ItemText">
              <style><class name="item-text"></class></style>
              <property name="ellipsize">end</property>
              <property name="vexpand_set">true</property>
              <property name="vexpand">true</property>
              <property name="xalign">0</property>
            </object>
          </child>
          <child>
            <object class="GtkLabel" id="ItemSubtext">
              <style><class name="item-subtext"></class></style>
              <property name="ellipsize">end</property>
              <property name="vexpand_set">true</property>
              <property name="vexpand">true</property>
              <property name="xalign">0</property>
              <property name="yalign">0</property>
            </object>
          </child>
        </object>
      </child>
      <child>
        <object class="GtkLabel" id="QuickActivation">
          <style><class name="item-quick-activation"></class></style>
          <property name="wrap">false</property>
          <property name="valign">center</property>
          <property name="xalign">0</property>
          <property name="yalign">0.5</property>
        </object>
      </child>
    </object>
    </interface>
  '';

  # Nord CSS using Walker 2.x class names.
  # Icons hidden to preserve the text-only look from the previous Walker 0.x theme.
  walkerCss = pkgs.writeText "walker-nord.css" ''
    @define-color foreground #ECEFF4;
    @define-color background rgba(46, 52, 64, 0.92);
    @define-color selection rgba(59, 66, 82, 0.85);
    @define-color border rgba(76, 86, 106, 0.5);
    @define-color dimtext rgba(216, 222, 233, 0.6);
    @define-color accent #88C0D0;

    * {
      all: unset;
      font-family: "JetBrainsMono Nerd Font";
      font-size: 14px;
      color: @foreground;
    }

    .window {
      background-color: transparent;
    }

    .box-wrapper {
      background-color: @background;
      border: 1px solid @border;
      border-radius: 8px;
      box-shadow: 0 4px 24px rgba(0, 0, 0, 0.5);
    }

    .box {
      padding: 10px;
    }

    .search-container {
      background-color: rgba(59, 66, 82, 0.5);
      border: 1px solid @border;
      border-radius: 6px;
    }

    .input {
      background: transparent;
      color: @foreground;
      caret-color: @accent;
      padding: 6px 8px;
    }

    .input placeholder {
      color: @dimtext;
    }

    .input selection {
      background: rgba(136, 192, 208, 0.3);
    }

    .item-box {
      padding: 8px 12px;
      border-radius: 4px;
    }

    child:selected .item-box,
    child:hover .item-box,
    row:selected .item-box {
      background-color: @selection;
    }

    #ItemImage,
    .item-image {
      -gtk-icon-size: 0px;
      min-width: 0;
      min-height: 0;
      margin: 0;
      padding: 0;
      opacity: 0;
    }

    #ItemImageFont,
    .item-image-text {
      font-size: 0;
      min-width: 0;
      margin: 0;
      padding: 0;
      opacity: 0;
    }

    .item-text {
      font-weight: 500;
    }

    .item-subtext {
      font-size: 0.85em;
      color: @dimtext;
    }

    .item-quick-activation {
      color: @dimtext;
      font-size: 0.8em;
    }

    scrollbar {
      opacity: 0;
    }

    .placeholder,
    .elephant-hint {
      color: @dimtext;
      padding: 20px;
    }

    .error {
      background-color: rgba(191, 97, 106, 0.85);
      padding: 8px;
      border-radius: 4px;
      margin-top: 8px;
    }

    .keybinds {
      padding-top: 8px;
      border-top: 1px solid @border;
      font-size: 12px;
      color: @dimtext;
    }

    .keybind-label {
      padding: 2px 4px;
      border-radius: 4px;
      border: 1px solid @dimtext;
    }

    .keybind-bind {
      opacity: 0.5;
    }
  '';

in {

  config = lib.mkIf config.hyprland.enable {
    home.packages = with pkgs; [ walker qalculate-qt libqalculate ];

    # Elephant is the data provider backend for Walker 2.x.
    # Using the HM module so it runs as a systemd user service (graphical-session.target).
    services.elephant.enable = true;

    home.file.".config/walker/config.toml".text = ''
      theme = "nord"
      close_when_open = true
      click_to_close = true
      single_click_activation = false
      hide_action_hints = true
      hide_return_action = true
      hide_action_hints_dmenu = true
      hide_quick_activation = true

      [shell]
      exclusive_zone = -1
      layer = "overlay"
      anchor_top = true
      anchor_bottom = true
      anchor_left = true
      anchor_right = true

      [placeholders]
      "default" = { input = "Search", list = "No Results" }

      [providers]
      default = ["desktopapplications", "runner"]
      empty = ["desktopapplications"]
      max_results = 8

      [[providers.prefixes]]
      prefix = "="
      provider = "websearch"

      [[providers.prefixes]]
      prefix = "+"
      provider = "calc"

      [[providers.prefixes]]
      prefix = ">"
      provider = "runner"
    '';

    # Walker 2.x theme system:
    #   - Theme directory: ~/.config/walker/themes/nord/
    #   - layout.xml: GTK4 window/widget layout definition
    #   - item.xml: list item template
    #   - style.css: Nord colours
    #   - Copied (not symlinked) so Walker can write to the themes dir.
    home.activation.copyWalkerTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      mkdir -p "$HOME/.config/walker/themes/nord"
      cp --no-preserve=all "${walkerLayout}" "$HOME/.config/walker/themes/nord/layout.xml"
      cp --no-preserve=all "${walkerItem}"   "$HOME/.config/walker/themes/nord/item.xml"
      cp --no-preserve=all "${walkerCss}"    "$HOME/.config/walker/themes/nord/style.css"
    '';

    # Clipboard picker: show cliphist entries in walker dmenu, decode and copy selected.
    home.file.".config/walker/clipboard.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        entry=$(cliphist list | walker -d -p "Paste...")
        [ -n "$entry" ] && printf '%s' "$entry" | cliphist decode | wl-copy
      '';
    };
  };
}
