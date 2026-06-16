# modules/home-manager/programs/terminals/tmux.nix

{ pkgs, lib, config, ... }:

let
  colors = import ../../theme/nordic-colors.nix;
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
        set -g pane-border-style "fg=${colors.nord3}"
        set -g pane-active-border-style "fg=${colors.nord8}"

        # Status bar — Nord theme
        set -g status-position bottom
        set -g status-style "bg=${colors.nord1},fg=${colors.nord4}"
        set -g status-left-length 30
        set -g status-right-length 50

        set -g status-left "#[fg=${colors.nord9},bold] #S  "
        set -g status-right "  %H:%M  #[fg=${colors.nord9},bold]#H "

        set -g window-status-format "#[fg=${colors.nord3}] #I:#W "
        set -g window-status-current-format "#[fg=${colors.nord8},bold] #I:#W "
        set -g window-status-separator ""

        # Message / command bar
        set -g message-style "bg=${colors.nord3},fg=${colors.nord4}"
        set -g message-command-style "bg=${colors.nord3},fg=${colors.nord8}"
      '';
    };
  };

}
