# modules/home-manager/programs/nvim.nix
{ pkgs, lib, config, ... }:

{
  options = {
    nvim.enable = lib.mkEnableOption "Enable nvim home-manager configuration";
  };

  config = lib.mkIf config.nvim.enable {
    programs.neovim = {
      enable = true;
      
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      
      extraPackages = with pkgs; [
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
        
        # Tools
        ripgrep
        fd
        gcc
      ];

      plugins = with pkgs.vimPlugins; [
        # Essential dependencies
        plenary-nvim
        nvim-web-devicons
        
        # Theme
        nord-nvim
        
        # File navigation
        nvim-tree-lua
        telescope-nvim
        telescope-fzf-native-nvim
        
        # LSP & Completion
        nvim-lspconfig
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
        
        # Utilities
        comment-nvim
        vim-nix
      ];

      extraLuaConfig = ''
        -- Basic settings
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.smartindent = true
        vim.opt.wrap = false
        vim.opt.swapfile = false
        vim.opt.backup = false
        vim.opt.hlsearch = false
        vim.opt.incsearch = true
        vim.opt.termguicolors = true
        vim.opt.scrolloff = 8
        vim.opt.updatetime = 50
        vim.opt.colorcolumn = "80"
        
        -- Clipboard settings
        vim.opt.clipboard = "unnamedplus"
        
        if os.getenv("WAYLAND_DISPLAY") then
          vim.g.clipboard = {
            name = 'wl-clipboard',
            copy = {
              ['+'] = 'wl-copy',
              ['*'] = 'wl-copy',
            },
            paste = {
              ['+'] = 'wl-paste --no-newline',
              ['*'] = 'wl-paste --no-newline',
            },
            cache_enabled = 1,
          }
        end
        
        -- Leader key
        vim.g.mapleader = " "
        
        -- Nord theme setup
        vim.cmd[[colorscheme nord]]
        
        -- Protected plugin setup
        local function safe_require(module)
          local ok, result = pcall(require, module)
          if not ok then
            vim.notify("Failed to load " .. module .. ": " .. result, vim.log.levels.ERROR)
            return nil
          end
          return result
        end
        
        -- Nvim-tree setup with Nord colors
        local nvim_tree = safe_require("nvim-tree")
        if nvim_tree then
          nvim_tree.setup({
            view = { width = 30 },
            filters = { dotfiles = false },
            renderer = {
              icons = {
                show = {
                  file = true,
                  folder = true,
                  folder_arrow = true,
                  git = true,
                },
              },
            },
          })
        end
        
        -- Telescope setup with Nord theme
        local telescope = safe_require('telescope')
        if telescope then
          telescope.setup({
            defaults = {
              file_ignore_patterns = { "node_modules", ".git/" },
            }
          })
          pcall(telescope.load_extension, 'fzf')
        end
        
        -- Treesitter setup
        local treesitter = safe_require('nvim-treesitter.configs')
        if treesitter then
          treesitter.setup({
            highlight = { 
              enable = true,
              additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
          })
        end
        
        -- Modern LSP setup
        local lspconfig = safe_require('lspconfig')
        if lspconfig then
          local cmp_nvim_lsp = safe_require('cmp_nvim_lsp')
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          
          if cmp_nvim_lsp then
            capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
          end
          
          -- LSP servers configuration
          local servers = {
            nixd = {
              exe = 'nixd',
            },
            lua_ls = {
              exe = 'lua-language-server',
              settings = {
                Lua = {
                  diagnostics = { globals = {'vim'} },
                  workspace = { checkThirdParty = false },
                  telemetry = { enable = false },
                }
              }
            },
            pyright = {
              exe = 'pyright',
            },
            ts_ls = {
              exe = 'typescript-language-server',
            },
            rust_analyzer = {
              exe = 'rust-analyzer',
            },
          }
          
          -- Setup each LSP server
          for server_name, server_config in pairs(servers) do
            if vim.fn.executable(server_config.exe) == 1 then
              local config = { capabilities = capabilities }
              if server_config.settings then
                config.settings = server_config.settings
              end
              
              local ok, err = pcall(function()
                lspconfig[server_name].setup(config)
              end)
              
              if not ok then
                vim.notify("Failed to setup " .. server_name .. ": " .. tostring(err), vim.log.levels.WARN)
              end
            end
          end
        end
        
        -- Completion setup with Nord colors
        local cmp = safe_require('cmp')
        if cmp then
          local luasnip = safe_require('luasnip')
          
          cmp.setup({
            snippet = {
              expand = function(args)
                if luasnip then
                  luasnip.lsp_expand(args.body)
                end
              end,
            },
            window = {
              completion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip and luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                else
                  fallback()
                end
              end, { 'i', 's' }),
              ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip and luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { 'i', 's' }),
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
            }, {
              { name = 'buffer' },
              { name = 'path' },
            })
          })
        end
        
        -- Lualine with Nord theme
        local lualine = safe_require('lualine')
        if lualine then 
          lualine.setup({ 
            options = { 
              theme = 'nord',
              component_separators = { left = '|', right = '|'},
              section_separators = { left = ' ', right = ' '},
            }
          }) 
        end
        
        -- Bufferline with Nord colors
        local bufferline = safe_require('bufferline')
        if bufferline then 
          bufferline.setup({
            options = {
              diagnostics = "nvim_lsp",
              offsets = {
                {
                  filetype = "NvimTree",
                  text = "File Explorer",
                  highlight = "Directory",
                  separator = true
                }
              },
              separator_style = "slant",
            },
            highlights = require("nord").bufferline.highlights({
              italic = true,
              bold = true,
            }),
          }) 
        end
        
        -- Gitsigns with Nord colors
        local gitsigns = safe_require('gitsigns')
        if gitsigns then 
          gitsigns.setup({
            signs = {
              add = { text = '+' },
              change = { text = '~' },
              delete = { text = '_' },
              topdelete = { text = '-' },
              changedelete = { text = '~' },
            }
          }) 
        end
        
        local comment = safe_require('Comment')
        if comment then comment.setup() end
        
        -- Indent blankline with Nord colors
        local ibl = safe_require('ibl')
        if ibl then
          ibl.setup({
            indent = { 
              char = "|",
            },
            scope = { 
              enabled = true,
              show_start = false,
              show_end = false,
            },
          })
        end
        
        -- Keymaps
        local keymap = vim.keymap.set
        
        -- File explorer
        keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle file explorer" })
        keymap('n', '<leader>o', ':NvimTreeFocus<CR>', { desc = "Focus file explorer" })
        
        -- Telescope
        keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = "Find files" })
        keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "Live grep" })
        keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "Find buffers" })
        keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = "Help tags" })
        keymap('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = "Recent files" })
        
        -- Clipboard
        keymap({'n', 'v'}, '<leader>y', '"+y', { desc = "Yank to clipboard" })
        keymap({'n', 'v'}, '<leader>p', '"+p', { desc = "Paste from clipboard" })
        keymap('n', '<leader>Y', '"+Y', { desc = "Yank line to clipboard" })
        
        -- LSP
        keymap('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
        keymap('n', 'gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
        keymap('n', 'gi', vim.lsp.buf.implementation, { desc = "Go to implementation" })
        keymap('n', 'go', vim.lsp.buf.type_definition, { desc = "Go to type definition" })
        keymap('n', 'K', vim.lsp.buf.hover, { desc = "Hover documentation" })
        keymap('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename" })
        keymap('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code action" })
        keymap('n', 'gr', vim.lsp.buf.references, { desc = "References" })
        keymap('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
        keymap('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
        keymap('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostics" })
        
        -- Buffer navigation
        keymap('n', '<leader>bn', ':bnext<CR>', { desc = "Next buffer" })
        keymap('n', '<leader>bp', ':bprevious<CR>', { desc = "Previous buffer" })
        keymap('n', '<leader>bd', ':bdelete<CR>', { desc = "Delete buffer" })
        keymap('n', '<Tab>', ':bnext<CR>', { desc = "Next buffer" })
        keymap('n', '<S-Tab>', ':bprevious<CR>', { desc = "Previous buffer" })
        
        -- Save and quit
        keymap('n', '<leader>w', ':w<CR>', { desc = "Save" })
        keymap('n', '<leader>q', ':q<CR>', { desc = "Quit" })
        keymap('n', '<leader>Q', ':qa<CR>', { desc = "Quit all" })
        
        -- Better window navigation
        keymap('n', '<C-h>', '<C-w>h', { desc = "Window left" })
        keymap('n', '<C-j>', '<C-w>j', { desc = "Window down" })
        keymap('n', '<C-k>', '<C-w>k', { desc = "Window up" })
        keymap('n', '<C-l>', '<C-w>l', { desc = "Window right" })
        
        -- Resize windows
        keymap('n', '<C-Up>', ':resize -2<CR>', { desc = "Decrease height" })
        keymap('n', '<C-Down>', ':resize +2<CR>', { desc = "Increase height" })
        keymap('n', '<C-Left>', ':vertical resize -2<CR>', { desc = "Decrease width" })
        keymap('n', '<C-Right>', ':vertical resize +2<CR>', { desc = "Increase width" })
        
        -- Better indenting
        keymap('v', '<', '<gv', { desc = "Indent left" })
        keymap('v', '>', '>gv', { desc = "Indent right" })
        
        -- Move text up and down
        keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = "Move text down" })
        keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = "Move text up" })
      '';
    };
  };
}