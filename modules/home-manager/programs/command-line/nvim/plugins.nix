# modules/home-manager/programs/command-line/nvim/plugins.nix

{ pkgs }:

with pkgs.vimPlugins; [
  # Essential dependencies
  plenary-nvim
  nvim-web-devicons
  
  # Theme
  nord-nvim
  
  # File navigation
  nvim-tree-lua
  telescope-nvim
  telescope-fzf-native-nvim
  
  # Completion
  nvim-cmp
  cmp-nvim-lsp
  cmp-buffer
  cmp-path
  cmp-cmdline
  luasnip
  cmp_luasnip
  
  # Syntax highlighting
  (nvim-treesitter.withPlugins (p: [
    p.nix
    p.lua
    p.python
    p.javascript
    p.typescript
    p.rust
    p.bash
    p.json
    p.yaml
    p.markdown
    p.html
    p.css
  ]))
  
  # UI improvements
  lualine-nvim
  bufferline-nvim
  indent-blankline-nvim
  
  # Git integration
  gitsigns-nvim
  vim-fugitive
  neogit
  diffview-nvim
  
  # Utilities
  comment-nvim
  vim-nix
  which-key-nvim
  nvim-autopairs
  trouble-nvim
  todo-comments-nvim
  nvim-surround
  
  # Additional
  nvim-colorizer-lua
]
