# modules/home-manager/shared/rofi.nix

{ pkgs, lib, config, ... }: {

  config = lib.mkIf config.hyprland.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      theme = "nord";
      extraConfig = {
        combi-modi = "drun,run";
        modi = "combi,drun,run,window";
        matching = "fuzzy";
        sort = true;
        sorting-method = "fzf";
        drun-use-desktop-cache = true;
        drun-reload-desktop-cache = true;
        levenshtein-sort = true;
        case-sensitive = false;
        show-icons = false;
        display-drun = "Apps";
        display-run = "Run";
        display-window = "Windows";
        display-combi = "Search";
      };
    };

    home.file.".config/rofi/web-search.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        query=$(rofi -dmenu -p "Web Search" -theme-str 'listview { enabled: false; }')
        [ -z "$query" ] && exit 0
        encoded=$(echo -n "$query" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read()))")
        xdg-open "https://www.google.com/search?q=$encoded"
      '';
    };

    home.file.".config/rofi/nord.rasi".text = ''
      * {
          background:             #2E3440;
          background-alt:         #3B4252;
          foreground:             #D8DEE9;
          foreground-alt:         #ECEFF4;
          accent:                 #88C0D0;
          urgent:                 #BF616A;
          selected:               #5E81AC;
          selected-text:          #ECEFF4;
          border-color:           #4C566A;
      }

      window {
          background-color: @background;
          border:           1px;
          border-color:     @border-color;
          padding:          5px;
          width:            600px;
      }

      mainbox {
          border:  0;
          padding: 0;
          background-color: @background;
      }

      message {
          border:       2px 0px 0px;
          border-color: @border-color;
          padding:      1px;
          background-color: @background;
      }

      textbox {
          text-color: @foreground;
          background-color: @background;
      }

      inputbar {
          children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
          padding:    8px 12px;
          background-color: @background;
      }

      textbox-prompt-colon {
          expand:     false;
          str:        ":";
          margin:     0px 0.3em 0em 0em;
          text-color: @foreground;
          background-color: @background;
      }

      entry {
          text-color: @foreground;
          background-color: @background;
      }

      case-indicator {
          text-color: @foreground;
          background-color: @background;
      }

      prompt {
          text-color: @accent;
          background-color: @background;
      }

      listview {
          fixed-height: 0;
          border:       2px 0px 0px;
          border-color: @border-color;
          spacing:      4px;
          scrollbar:    true;
          padding:      4px 0px 0px;
          lines:        8;
          columns:      1;
          cycle:        false;
          dynamic:      true;
          layout:       vertical;
          fixed-columns: true;
          background-color: @background;
      }

      element {
          border:  0;
          padding: 4px 8px;
          background-color: @background;
          text-color: @foreground;
      }

      element-text {
          text-color: inherit;
          background-color: inherit;
      }

      element-icon {
          background-color: inherit;
          size: 1em;
      }

      element.normal.normal {
          background-color: @background;
          text-color:       @foreground;
      }

      element.normal.urgent {
          background-color: @urgent;
          text-color:       @foreground-alt;
      }

      element.normal.active {
          background-color: @background;
          text-color:       @foreground;
      }

      element.selected.normal {
          background-color: @selected;
          text-color:       @selected-text;
      }

      element.selected.urgent {
          background-color: @urgent;
          text-color:       @foreground-alt;
      }

      element.selected.active {
          background-color: @selected;
          text-color:       @selected-text;
      }

      element.alternate.normal {
          background-color: @background;
          text-color:       @foreground;
      }

      element.alternate.urgent {
          background-color: @urgent;
          text-color:       @foreground-alt;
      }

      element.alternate.active {
          background-color: @background;
          text-color:       @foreground;
      }

      scrollbar {
          width:        4px;
          border:       0;
          handle-color: @foreground;
          handle-width: 8px;
          padding:      0;
          background-color: @background-alt;
      }

      mode-switcher {
          border:       2px 0px 0px;
          border-color: @border-color;
          background-color: @background;
      }

      button {
          spacing:    0;
          text-color: @foreground;
          background-color: @background;
      }

      button.selected {
          background-color: @background-alt;
          text-color:       @accent;
      }
    '';
  };
}
