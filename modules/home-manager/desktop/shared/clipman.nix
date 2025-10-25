# modules/home-manager/shared/clipman.nix

{ pkgs, lib, config, ... }: {
  config = lib.mkIf config.sway.enable {
    # Enable clipman service
    services.clipman = {
      enable = true;
      systemdTarget = "sway-session.target";
    };

    # Add clipman to home packages
    home.packages = with pkgs; [
      clipman
    ];

    # Rofi script for clipman
    home.file.".config/rofi/clipman.sh" = {
      text = ''
        #!/usr/bin/env bash
        clipman pick --tool=CUSTOM --tool-args="rofi -dmenu -theme clipman"
      '';
      executable = true;
    };

    # Clipman-specific Rofi theme (matched to main rofi config)
    home.file.".config/rofi/clipman.rasi".text = ''
      * {
        background: #2E3440;
        background-alt: #3B4252;
        foreground: #D8DEE9;
        foreground-alt: #ECEFF4;
        accent: #88C0D0;
        urgent: #BF616A;
        selected: #5E81AC;
        selected-text: #ECEFF4;
        border-color: #4C566A;
      }
      
      window {
        background-color: @background;
        border: 1px;
        border-color: @border-color;
        padding: 5px;
        width: 600px;
      }
      
      mainbox {
        border: 0;
        padding: 0;
        background-color: @background;
      }
      
      message {
        border: 2px 0px 0px;
        border-color: @border-color;
        padding: 1px;
        background-color: @background;
      }
      
      textbox {
        text-color: @foreground;
        background-color: @background;
      }
      
      inputbar {
        children: [ prompt,textbox-prompt-colon,entry,case-indicator ];
        padding: 8px 12px;
        background-color: @background;
      }
      
      textbox-prompt-colon {
        expand: false;
        str: ":";
        margin: 0px 0.3em 0em 0em;
        text-color: @foreground;
        background-color: @background;
      }
      
      entry {
        text-color: @foreground;
        background-color: @background;
        placeholder: "Search clipboard...";
        placeholder-color: @foreground-alt;
      }
      
      case-indicator {
        text-color: @foreground;
        background-color: @background;
      }
      
      prompt {
        text-color: @accent;
        background-color: @background;
        str: "Clipboard";
      }
      
      listview {
        fixed-height: 0;
        border: 2px 0px 0px;
        border-color: @border-color;
        spacing: 4px;
        scrollbar: true;
        padding: 4px 0px 0px;
        lines: 8;
        columns: 1;
        cycle: false;
        dynamic: true;
        layout: vertical;
        fixed-columns: true;
        background-color: @background;
      }
      
      element {
        border: 0;
        padding: 4px 8px;
        background-color: @background;
        text-color: @foreground;
      }
      
      element-text {
        text-color: inherit;
        background-color: inherit;
      }
      
      element.normal.normal {
        background-color: @background;
        text-color: @foreground;
      }
      
      element.normal.urgent {
        background-color: @urgent;
        text-color: @foreground-alt;
      }
      
      element.normal.active {
        background-color: @background;
        text-color: @foreground;
      }
      
      element.selected.normal {
        background-color: @selected;
        text-color: @selected-text;
      }
      
      element.selected.urgent {
        background-color: @urgent;
        text-color: @foreground-alt;
      }
      
      element.selected.active {
        background-color: @selected;
        text-color: @selected-text;
      }
      
      element.alternate.normal {
        background-color: @background;
        text-color: @foreground;
      }
      
      element.alternate.urgent {
        background-color: @urgent;
        text-color: @foreground-alt;
      }
      
      element.alternate.active {
        background-color: @background;
        text-color: @foreground;
      }
      
      scrollbar {
        width: 4px;
        border: 0;
        handle-color: @foreground;
        handle-width: 8px;
        padding: 0;
        background-color: @background-alt;
      }
    '';
  };
}
