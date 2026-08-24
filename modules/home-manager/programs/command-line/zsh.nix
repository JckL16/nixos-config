# modules/home-manager/programs/command-line/zsh.nix

{ pkgs, lib, config, variables, ... }:
let
  c = config.theme.colors;
  batTheme = {
    "nord"        = "Nord";
    "gruvbox"     = "gruvbox-dark";
    "dracula"     = "Dracula";
    "tokyo-night" = "base16";
  }.${variables.theme} or "Nord";
in {
  home.packages = with pkgs; [
    pay-respects
    eza
    ripgrep
    fd
    tealdeer
    btop
    duf
    dust
    procs
    delta
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --hidden --exclude .git";
    fileWidgetCommand = "fd --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
  };

  programs.bat = {
    enable = true;
    config = {
      theme = batTheme;
      pager = "less -FR";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[❯](bold ${c.success})";
        error_symbol   = "[❯](bold ${c.urgent})";
      };
      directory = {
        style = "bold ${c.accentBlue}";
        truncation_length = 4;
        truncate_to_repo = false;
      };
      git_branch = {
        symbol = " ";
        style  = "bold ${c.accent}";
      };
      git_status = {
        style = "bold ${c.urgent}";
      };
      cmd_duration = {
        min_time = 2000;
        style    = "bold ${c.warning}";
      };
      username = {
        format     = "[$user]($style)@";
        style_user = "bold ${c.nord7}";
        show_always = false;
      };
      hostname = {
        format = "[$hostname]($style) ";
        style  = "bold ${c.success}";
        ssh_only = true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
      expireDuplicatesFirst = true;
    };

    shellAliases = {
      # Nixos aliases
      switch = "sudo nixos-rebuild switch --flake ~/nixos-config";
      test = "sudo nixos-rebuild test --flake ~/nixos-config";
      dry-run = "sudo nixos-rebuild dry-run --flake ~/nixos-config";
      update = "nix flake update --flake ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config";
      clean = "nix-collect-garbage";
      install-bootloader = "sudo nixos-rebuild boot --install-bootloader --flake ~/nixos-config";

      # Pay pay-respects alias (correction of earlier written command)
      fuck = "f";

      # Eza aliases (ls replacement)
      ls = "eza --icons --group-directories-first";
      ll = "eza --icons --group-directories-first -l";
      la = "eza --icons --group-directories-first -la";
      lt = "eza --icons --group-directories-first --tree";
      tree = "eza --icons --group-directories-first --tree";

      # Zoxide alias (cd replacement)
      cd = "z";

      # Git shortcuts
      gst = "git status";
      gco = "git checkout";
      gp = "git push";
      gl = "git pull";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Safety nets
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Nix helpers
      nix-search = "nix search nixpkgs";

      # Open files with default application
      open = "xdg-open";

      rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
    };

    initContent = ''
      eval "$(pay-respects --alias --shell zsh)"

      # Better directory navigation
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS

      # Better globbing
      setopt EXTENDED_GLOB

      # FZF tab completion helpers
      _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
      }

      _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
      }

      # ESC ESC to prepend sudo (replaces oh-my-zsh sudo plugin)
      sudo-command-line() {
        [[ -z $BUFFER ]] && zle up-history
        if [[ $BUFFER == sudo\ * ]]; then
          LBUFFER="''${LBUFFER#sudo }"
        else
          LBUFFER="sudo $LBUFFER"
        fi
      }
      zle -N sudo-command-line
      bindkey "^[^[" sudo-command-line

      # Open host config dir in nvim, then rebuild
      update-config() {
        nvim ~/nixos-config/hosts/$(hostname)/
        sudo nixos-rebuild switch --flake ~/nixos-config
      }

      # Extract various archive formats (replaces oh-my-zsh extract plugin)
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2)  tar xjf "$1"        ;;
            *.tar.gz)   tar xzf "$1"        ;;
            *.tar.xz)   tar xJf "$1"        ;;
            *.tar.zst)  tar --zstd -xf "$1" ;;
            *.tar)      tar xf "$1"         ;;
            *.bz2)      bunzip2 "$1"        ;;
            *.gz)       gunzip "$1"         ;;
            *.xz)       unxz "$1"           ;;
            *.zip)      unzip "$1"          ;;
            *.7z)       7z x "$1"           ;;
            *.rar)      unrar x "$1"        ;;
            *.Z)        uncompress "$1"     ;;
            *)          echo "'$1' cannot be extracted" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      # Reduce ESC delay for vi mode switching
      KEYTIMEOUT=1

      # Vi mode - cursor shape (beam in insert, block in normal)
      zle-keymap-select() {
        if [[ $KEYMAP == vicmd ]]; then
          echo -ne '\e[2 q'
        else
          echo -ne '\e[6 q'
        fi
      }
      zle -N zle-keymap-select
      zle-line-init() { echo -ne '\e[6 q'; }
      zle -N zle-line-init

      # Edit current command in nvim (v in normal mode)
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd 'v' edit-command-line

      # Ctrl+A/E in vi insert mode
      bindkey '^A' beginning-of-line
      bindkey '^E' end-of-line

      # Ctrl+Arrow for word-by-word navigation
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANRWIDTH = "80";
    MANROFFOPT = "-c";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
