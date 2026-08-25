# modules/home-manager/programs/terminals/tmux.nix

{ pkgs, lib, config, ... }:

let
  c = config.theme.colors;
in {

  options = {
    tmux.enable = lib.mkEnableOption "Enable tmux terminal multiplexer";
  };

  config = lib.mkIf config.tmux.enable {
    programs.tmux = {
      enable = true;
      prefix = "C-Space";
      terminal = "tmux-256color";
      historyLimit = 10000;
      mouse = true;
      baseIndex = 1;
      escapeTime = 0;
      keyMode = "vi";

      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
      ];

      extraConfig = ''
        # True color passthrough — required for nvim termguicolors
        set -ga terminal-overrides ",*256col*:Tc"

        # Pane borders
        set -g pane-border-style "fg=${c.nord3}"
        set -g pane-active-border-style "fg=${c.nord8}"

        # Status bar
        set -g status-position bottom
        set -g status-style "bg=${c.nord1},fg=${c.nord4}"
        set -g status-left-length 30
        set -g status-right-length 50

        set -g status-left "#[fg=${c.nord9},bold] #S  "
        set -g status-right "  %H:%M  #[fg=${c.nord9},bold]#H "

        set -g window-status-format "#[fg=${c.nord3}] #I:#W "
        set -g window-status-current-format "#[fg=${c.nord8},bold] #I:#W "
        set -g window-status-separator ""

        # Message / command bar
        set -g message-style "bg=${c.nord3},fg=${c.nord4}"
        set -g message-command-style "bg=${c.nord3},fg=${c.nord8}"
      '';
    };
  };

}
