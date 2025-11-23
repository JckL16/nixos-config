# modules/home-manager/programs/command-line/zsh.nix

{ pkgs, lib, config, variables, ... }: {
  home.packages = with pkgs; [
    fzf
    pay-respects
    eza
    bat
    ripgrep
    fd
    tldr
    btop
    duf
    dust
    procs
    delta
  ];
  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "fzf"
        "sudo"
        "command-not-found"
        "colored-man-pages"
        "extract"
      ];
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
    };
    
    initContent = ''
      eval "$(pay-respects --alias --shell zsh)"
      
      # Better history search with fzf
      bindkey '^R' fzf-history-widget
      
      # Better directory navigation
      setopt AUTO_CD              # Type directory name to cd
      setopt AUTO_PUSHD           # Make cd push old directory onto stack
      setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
      
      # Better globbing
      setopt EXTENDED_GLOB
    '';
  };
  
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
