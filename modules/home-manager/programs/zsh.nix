# modules/home-manager/zsh.nix
{ pkgs, lib, config, variables, ... }: {
  home.packages = with pkgs; [
    fzf
    pay-respects
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
      update = "nix flake update ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config";
      clean = "nix-collect-garbage";
      fuck = "f";
    };
    
    initContent = ''
      eval "$(pay-respects --alias --shell zsh)"
    '';
  };
}