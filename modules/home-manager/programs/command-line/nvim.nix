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
        
        # Git (for neogit)
        git
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
        diffview-nvim  # Dependency for neogit
        
        # Utilities
        comment-nvim
        vim-nix
        
        # Minimal recommended additions
        which-key-nvim
        nvim-autopairs
        trouble-nvim
        todo-comments-nvim
        nvim-surround
        
        # Additional plugins
        alpha-nvim
        nvim-colorizer-lua
      ];

      extraLuaConfig = ''
        -- Disable netrw in favor of nvim-tree
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        
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
        
        -- Define browse_directory function globally BEFORE Alpha setup
        _G.browse_directory = function()
          vim.ui.input({ prompt = "Enter directory path: ", default = vim.fn.getcwd() .. "/" }, function(input)
            if input then
              local expanded_path = vim.fn.expand(input)
              if vim.fn.isdirectory(expanded_path) == 1 then
                vim.cmd("cd " .. vim.fn.fnameescape(expanded_path))
                require("nvim-tree.api").tree.open()
                vim.notify("Changed directory to: " .. expanded_path)
              else
                vim.notify("Not a valid directory: " .. input, vim.log.levels.ERROR)
              end
            end
          end)
        end
        
        -- Alpha (Dashboard) setup
        local alpha = safe_require("alpha")
        if alpha then
          local dashboard = safe_require("alpha.themes.dashboard")
          if dashboard then
            -- Set header
            dashboard.section.header.val = {
              "                                                     ",
              "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ██╗ ",
              "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗  ██║ ",
              "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔██╗ ██║ ",
              "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╗██║ ",
              "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚████║ ",
              "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝  ╚═══╝ ",
              "                                                     ",
            }
            
            -- Set menu
            dashboard.section.buttons.val = {
              dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
              dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
              dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
              dashboard.button("d", "  Browse directory", ":lua browse_directory()<CR>"),
              dashboard.button("e", "  File explorer", ":NvimTreeOpen<CR>"),
              dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
              dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
              dashboard.button("q", "  Quit", ":qa<CR>"),
            }
            
            -- Set footer
            local function footer()
              local total_plugins = #vim.tbl_keys(packer_plugins or {})
              local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
              local version = vim.version()
              local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch
              
              return datetime .. "   " .. total_plugins .. " plugins" .. nvim_version_info
            end
            
            dashboard.section.footer.val = footer()
            
            -- Apply Nord colors
            dashboard.section.header.opts.hl = "Type"
            dashboard.section.buttons.opts.hl = "Keyword"
            dashboard.section.footer.opts.hl = "Comment"
            
            dashboard.opts.opts.noautocmd = true
            alpha.setup(dashboard.opts)
            
            -- Disable folding on alpha buffer
            vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
          end
        end
        
        -- Colorizer setup (exclude certain filetypes and only highlight in comments)
        local colorizer = safe_require("colorizer")
        if colorizer then
          colorizer.setup({
            filetypes = {
              "css",
              "scss",
              "html",
              "javascript",
              "typescript",
              "jsx",
              "tsx",
            },
            user_default_options = {
              RGB = true,
              RRGGBB = true,
              names = false,  -- Disable color names like "black", "white" etc
              RRGGBBAA = true,
              AARRGGBB = true,
              rgb_fn = true,
              hsl_fn = true,
              css = true,
              css_fn = true,
              mode = "background",
              tailwind = true,
              sass = { enable = true, parsers = { "css" } },
              virtualtext = "■",
            },
            buftypes = {},
          })
        end
        
        -- Neogit setup (fixed configuration)
        local neogit = safe_require("neogit")
        if neogit then
          neogit.setup({
            kind = "tab",
            signs = {
              section = { "", "" },
              item = { "", "" },
              hunk = { "", "" },
            },
            integrations = {
              diffview = true,
              telescope = true,
            },
            sections = {
              untracked = {
                folded = false,
                hidden = false,
              },
              unstaged = {
                folded = false,
                hidden = false,
              },
              staged = {
                folded = false,
                hidden = false,
              },
              stashes = {
                folded = true,
                hidden = false,
              },
              unpulled = {
                folded = true,
                hidden = false,
              },
              unmerged = {
                folded = false,
                hidden = false,
              },
              recent = {
                folded = true,
                hidden = false,
              },
            },
          })
        end
        
        -- Which-key setup (v3 with explicit trigger)
        local which_key = safe_require("which-key")
        if which_key then
          which_key.setup({
            preset = "modern",
            delay = function(ctx)
              return 500
            end,
            plugins = {
              marks = true,
              registers = true,
              spelling = {
                enabled = true,
                suggestions = 20,
              },
            },
            win = {
              border = "rounded",
            },
            icons = {
              breadcrumb = "»",
              separator = "➜",
              group = "+",
            },
            triggers = {
              { "<leader>", mode = { "n", "v" } },
            },
          })
          
          -- Register key groups
          which_key.add({
            { "<leader>f", group = "Find" },
            { "<leader>ff", desc = "Find files" },
            { "<leader>fg", desc = "Live grep" },
            { "<leader>fb", desc = "Find buffers" },
            { "<leader>fh", desc = "Help tags" },
            { "<leader>fr", desc = "Recent files" },
            { "<leader>ft", desc = "Find TODOs" },
            
            { "<leader>b", group = "Buffer" },
            { "<leader>bn", desc = "Next buffer" },
            { "<leader>bp", desc = "Previous buffer" },
            { "<leader>bd", desc = "Delete buffer" },
            
            { "<leader>c", group = "Code" },
            { "<leader>ca", desc = "Code action" },
            
            { "<leader>g", group = "Git" },
            { "<leader>gg", desc = "Open Neogit" },
            { "<leader>gc", desc = "Git commit" },
            { "<leader>gp", desc = "Git pull" },
            { "<leader>gP", desc = "Git push" },
            { "<leader>gb", desc = "Git branches" },
            { "<leader>gs", desc = "Git status" },
            
            { "<leader>t", group = "Trouble" },
            { "<leader>tt", desc = "Toggle diagnostics" },
            { "<leader>td", desc = "Document diagnostics" },
            { "<leader>tq", desc = "Quickfix list" },
            { "<leader>tl", desc = "Location list" },
            
            { "<leader>e", desc = "Toggle file explorer" },
            { "<leader>o", desc = "Focus file explorer" },
            { "<leader>w", desc = "Save file" },
            { "<leader>q", desc = "Quit" },
            { "<leader>Q", desc = "Quit all" },
            { "<leader>y", desc = "Yank to clipboard" },
            { "<leader>p", desc = "Paste from clipboard" },
            { "<leader>Y", desc = "Yank line to clipboard" },
            { "<leader>rn", desc = "Rename symbol" },
            { "<leader>d", desc = "Show diagnostics" },
          })
        end

        -- Autopairs setup
        local autopairs = safe_require("nvim-autopairs")
        if autopairs then
          autopairs.setup({
            check_ts = true,
            ts_config = {
              lua = {'string'},
              javascript = {'string', 'template_string'},
            },
            disable_filetype = { "TelescopePrompt" },
            fast_wrap = {
              map = '<M-e>',
              chars = { '{', '[', '(', '"', "'" },
              pattern = [=[[%'%"%>%]%)%}%,]]=],
              end_key = '$',
              keys = 'qwertyuiopzxcvbnmasdfghjkl',
              check_comma = true,
              highlight = 'Search',
              highlight_grey='Comment'
            },
          })
          
          -- Integration with nvim-cmp
          local cmp_autopairs = safe_require('nvim-autopairs.completion.cmp')
          local cmp = safe_require('cmp')
          if cmp and cmp_autopairs then
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
          end
        end
        
        -- Trouble setup
        local trouble = safe_require("trouble")
        if trouble then
          trouble.setup({
            position = "bottom",
            height = 10,
            width = 50,
            icons = true,
            mode = "workspace_diagnostics",
            fold_open = "",
            fold_closed = "",
            group = true,
            padding = true,
            action_keys = {
              close = "q",
              cancel = "<esc>",
              refresh = "r",
              jump = {"<cr>", "<tab>"},
              open_split = { "<c-x>" },
              open_vsplit = { "<c-v>" },
              open_tab = { "<c-t>" },
              jump_close = {"o"},
              toggle_mode = "m",
              toggle_preview = "P",
              hover = "K",
              preview = "p",
              close_folds = {"zM", "zm"},
              open_folds = {"zR", "zr"},
              toggle_fold = {"zA", "za"},
              previous = "k",
              next = "j"
            },
            indent_lines = true,
            auto_open = false,
            auto_close = false,
            auto_preview = true,
            auto_fold = false,
            signs = {
              error = "",
              warning = "",
              hint = "",
              information = "",
              other = ""
            },
            use_diagnostic_signs = false
          })
        end
        
        -- Todo Comments setup
        local todo_comments = safe_require("todo-comments")
        if todo_comments then
          todo_comments.setup({
            signs = true,
            sign_priority = 8,
            keywords = {
              FIX = {
                icon = " ",
                color = "error",
                alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
              },
              TODO = { icon = " ", color = "info" },
              HACK = { icon = " ", color = "warning" },
              WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
              PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
              NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
              TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
            gui_style = {
              fg = "NONE",
              bg = "BOLD",
            },
            merge_keywords = true,
            highlight = {
              multiline = true,
              multiline_pattern = "^.",
              multiline_context = 10,
              before = "",
              keyword = "wide",
              after = "fg",
              pattern = [[.*<(KEYWORDS)\s*:]],
              comments_only = true,
              max_line_len = 400,
              exclude = {},
            },
            colors = {
              error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
              warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
              info = { "DiagnosticInfo", "#2563EB" },
              hint = { "DiagnosticHint", "#10B981" },
              default = { "Identifier", "#7C3AED" },
              test = { "Identifier", "#FF00FF" }
            },
            search = {
              command = "rg",
              args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
              },
              pattern = [[\b(KEYWORDS):]],
            },
          })
        end
        
        -- Nvim-surround setup
        local surround = safe_require("nvim-surround")
        if surround then
          surround.setup({
            keymaps = {
              insert = "<C-g>s",
              insert_line = "<C-g>S",
              normal = "ys",
              normal_cur = "yss",
              normal_line = "yS",
              normal_cur_line = "ySS",
              visual = "S",
              visual_line = "gS",
              delete = "ds",
              change = "cs",
            },
          })
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
            -- Auto-open nvim-tree when opening a directory
            hijack_directories = {
              enable = true,
              auto_open = true,
            },
          })
          
          -- Open nvim-tree when opening a directory
          vim.api.nvim_create_autocmd("VimEnter", {
            callback = function(data)
              local directory = vim.fn.isdirectory(data.file) == 1
              
              if directory then
                vim.cmd.cd(data.file)
                require("nvim-tree.api").tree.open()
              end
            end
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
        
        -- Modern LSP setup using vim.lsp.config
        local cmp_nvim_lsp = safe_require('cmp_nvim_lsp')
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        
        if cmp_nvim_lsp then
          capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
        end
        
        -- LSP servers configuration using new vim.lsp.config API
        local servers = {
          nixd = {
            cmd = { 'nixd' },
            filetypes = { 'nix' },
          },
          lua_ls = {
            cmd = { 'lua-language-server' },
            filetypes = { 'lua' },
            settings = {
              Lua = {
                diagnostics = { globals = {'vim'} },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              }
            }
          },
          pyright = {
            cmd = { 'pyright-langserver', '--stdio' },
            filetypes = { 'python' },
          },
          ts_ls = {
            cmd = { 'typescript-language-server', '--stdio' },
            filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
          },
          rust_analyzer = {
            cmd = { 'rust-analyzer' },
            filetypes = { 'rust' },
            settings = {
              ['rust-analyzer'] = {
                checkOnSave = {
                  command = "clippy"
                },
              }
            }
          },
        }
        
        -- Setup each LSP server using vim.lsp.config
        for server_name, server_config in pairs(servers) do
          if vim.fn.executable(server_config.cmd[1]) == 1 then
            local config = vim.tbl_deep_extend('force', {
              capabilities = capabilities,
              name = server_name,
            }, server_config)
            
            local ok, err = pcall(function()
              vim.lsp.config(server_name, config)
              vim.lsp.enable(server_name)
            end)
            
            if not ok then
              vim.notify("Failed to setup " .. server_name .. ": " .. tostring(err), vim.log.levels.WARN)
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
        
        -- Neogit
        keymap('n', '<leader>gg', '<cmd>Neogit<cr>', { desc = "Open Neogit" })
        keymap('n', '<leader>gc', '<cmd>Neogit commit<cr>', { desc = "Git commit" })
        keymap('n', '<leader>gp', '<cmd>Neogit pull<cr>', { desc = "Git pull" })
        keymap('n', '<leader>gP', '<cmd>Neogit push<cr>', { desc = "Git push" })
        keymap('n', '<leader>gb', '<cmd>Telescope git_branches<cr>', { desc = "Git branches" })
        keymap('n', '<leader>gs', '<cmd>Telescope git_status<cr>', { desc = "Git status" })
        
        -- Trouble keymaps
        keymap('n', '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', { desc = "Toggle diagnostics" })
        keymap('n', '<leader>td', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = "Document diagnostics" })
        keymap('n', '<leader>tq', '<cmd>Trouble qflist toggle<cr>', { desc = "Quickfix list" })
        keymap('n', '<leader>tl', '<cmd>Trouble loclist toggle<cr>', { desc = "Location list" })
        
        -- Todo Comments keymaps
        keymap('n', '<leader>ft', '<cmd>TodoTelescope<cr>', { desc = "Find TODOs" })
        keymap('n', ']t', function() require("todo-comments").jump_next() end, { desc = "Next TODO" })
        keymap('n', '[t', function() require("todo-comments").jump_prev() end, { desc = "Previous TODO" })
        
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
