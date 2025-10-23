# modules/home-manager/programs/zsh.nix

{ pkgs, lib, config, variables, ... }: {
  home.packages = with pkgs; [
    fzf
    pay-respects
    eza
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
      ];
    };
    
    shellAliases = {
      switch = "sudo nixos-rebuild switch --flake ~/nixos-config";
      test = "sudo nixos-rebuild test --flake ~/nixos-config";
      dry-run = "sudo nixos-rebuild dry-run --flake ~/nixos-config";
      update = "nix flake update --flake ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config";
      clean = "nix-collect-garbage";
      fuck = "f";

      # Eza aliases
      ls = "eza --icons --group-directories-first";
      ll = "eza --icons --group-directories-first -l";
      la = "eza --icons --group-directories-first -la";
      lt = "eza --icons --group-directories-first --tree";
      tree = "eza --icons --group-directories-first --tree";
    };
    
    initContent = ''
      eval "$(pay-respects --alias --shell zsh)"
    '';
  };
}
