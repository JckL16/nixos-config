# modules/home-manager/programs/command-line/nvim/lsp-servers.nix

{ pkgs }:

with pkgs; [
  # Clipboard support
  wl-clipboard
  xclip
  
  # Language servers
  nixd
  lua-language-server
  pyright
  nodePackages.typescript-language-server
  rust-analyzer
  
  # Formatters
  nixpkgs-fmt
  black
  nodePackages.prettier
  
  # Tools for treesitter
  tree-sitter
  nodejs
  
  # Essential tools
  ripgrep
  fd
  gcc
  
  # Git
  git
]
