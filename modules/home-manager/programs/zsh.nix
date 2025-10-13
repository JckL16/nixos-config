# modules/home-manager/zsh.nix

{ pkgs, lib, config, variables, ... }: {
  
  home.packages = with pkgs; [
    fzf
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
  };

}