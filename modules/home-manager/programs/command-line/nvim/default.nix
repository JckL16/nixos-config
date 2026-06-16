# modules/home-manager/programs/command-line/nvim/default.nix

{ pkgs, lib, config, inputs, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  options = {
    nvim.enable = lib.mkEnableOption "Enable nvim home-manager configuration";
  };

  config = lib.mkIf config.nvim.enable {
    programs.nixvim = {
      enable = true;
      nixpkgs.source = inputs.nixpkgs;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;

      globals = {
        mapleader = " ";
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
      };

      opts = {
        number = true;
        relativenumber = true;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        wrap = false;
        swapfile = false;
        backup = false;
        hlsearch = false;
        incsearch = true;
        termguicolors = true;
        scrolloff = 8;
        updatetime = 50;
        colorcolumn = "80";

      };

      autoCmd = [
        {
          event = "FileType";
          pattern = "python";
          command = "setlocal shiftwidth=4 tabstop=4 softtabstop=4";
        }
        {
          event = "FileType";
          pattern = [ "c" "cpp" ];
          command = "setlocal shiftwidth=4 tabstop=4 softtabstop=4";
        }
        {
          event = "FileType";
          pattern = "markdown";
          command = "setlocal wrap linebreak";
        }
        {
          event = "VimEnter";
          callback.__raw = ''
            function(data)
              local directory = vim.fn.isdirectory(data.file) == 1
              if directory then
                vim.cmd.cd(data.file)
                require("nvim-tree.api").tree.open()
              end
            end
          '';
        }
      ];

      colorschemes.nord.enable = true;

      extraPackages = with pkgs; [
        wl-clipboard
        xclip
        ripgrep
        fd
        gcc
        git
        tree-sitter
        nodejs
      ];

      extraConfigLua = ''
        -- Wayland clipboard
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

        -- Browse directory helper
        function _G.browse_directory()
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

        -- nvim-autopairs cmp integration
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
      '';

      keymaps = [
        # File explorer
        { mode = "n"; key = "<leader>e"; action = ":NvimTreeToggle<CR>"; options.desc = "Toggle file explorer"; }
        { mode = "n"; key = "<leader>o"; action = ":NvimTreeFocus<CR>"; options.desc = "Focus file explorer"; }
        # Telescope
        { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
        { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Live grep"; }
        { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; options.desc = "Find buffers"; }
        { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Help tags"; }
        { mode = "n"; key = "<leader>fr"; action = "<cmd>Telescope oldfiles<cr>"; options.desc = "Recent files"; }
        # Neogit
        { mode = "n"; key = "<leader>gg"; action = "<cmd>Neogit<cr>"; options.desc = "Open Neogit"; }
        { mode = "n"; key = "<leader>gc"; action = "<cmd>Neogit commit<cr>"; options.desc = "Git commit"; }
        { mode = "n"; key = "<leader>gp"; action = "<cmd>Neogit pull<cr>"; options.desc = "Git pull"; }
        { mode = "n"; key = "<leader>gP"; action = "<cmd>Neogit push<cr>"; options.desc = "Git push"; }
        { mode = "n"; key = "<leader>gb"; action = "<cmd>Telescope git_branches<cr>"; options.desc = "Git branches"; }
        { mode = "n"; key = "<leader>gs"; action = "<cmd>Telescope git_status<cr>"; options.desc = "Git status"; }
        # Trouble
        { mode = "n"; key = "<leader>tt"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Toggle diagnostics"; }
        { mode = "n"; key = "<leader>td"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; options.desc = "Document diagnostics"; }
        { mode = "n"; key = "<leader>tq"; action = "<cmd>Trouble qflist toggle<cr>"; options.desc = "Quickfix list"; }
        { mode = "n"; key = "<leader>tl"; action = "<cmd>Trouble loclist toggle<cr>"; options.desc = "Location list"; }
        # Todo Comments
        { mode = "n"; key = "<leader>ft"; action = "<cmd>TodoTelescope<cr>"; options.desc = "Find TODOs"; }
        { mode = "n"; key = "<leader>fk"; action = "<cmd>Telescope keymaps<cr>"; options.desc = "Find keymaps"; }
        { mode = "n"; key = "]t"; action.__raw = ''function() require("todo-comments").jump_next() end''; options.desc = "Next TODO"; }
        { mode = "n"; key = "[t"; action.__raw = ''function() require("todo-comments").jump_prev() end''; options.desc = "Previous TODO"; }
        # Clipboard
        { mode = [ "n" "v" ]; key = "<leader>y"; action = ''"+y''; options.desc = "Yank to clipboard"; }
        { mode = [ "n" "v" ]; key = "<leader>p"; action = ''"+p''; options.desc = "Paste from clipboard"; }
        { mode = "n"; key = "<leader>Y"; action = ''"+Y''; options.desc = "Yank line to clipboard"; }
        { mode = [ "n" "v" ]; key = "<leader>d"; action = ''"_d''; options.desc = "Delete to black hole"; }
        # LSP
        { mode = "n"; key = "gd"; action.__raw = "vim.lsp.buf.definition"; options.desc = "Go to definition"; }
        { mode = "n"; key = "gD"; action.__raw = "vim.lsp.buf.declaration"; options.desc = "Go to declaration"; }
        { mode = "n"; key = "gi"; action.__raw = "vim.lsp.buf.implementation"; options.desc = "Go to implementation"; }
        { mode = "n"; key = "go"; action.__raw = "vim.lsp.buf.type_definition"; options.desc = "Go to type definition"; }
        { mode = "n"; key = "K"; action.__raw = "vim.lsp.buf.hover"; options.desc = "Hover documentation"; }
        { mode = "n"; key = "<leader>rn"; action.__raw = "vim.lsp.buf.rename"; options.desc = "Rename"; }
        { mode = "n"; key = "<leader>ca"; action.__raw = "vim.lsp.buf.code_action"; options.desc = "Code action"; }
        { mode = "n"; key = "gr"; action.__raw = "vim.lsp.buf.references"; options.desc = "References"; }
        { mode = "n"; key = "[d"; action.__raw = "vim.diagnostic.goto_prev"; options.desc = "Previous diagnostic"; }
        { mode = "n"; key = "]d"; action.__raw = "vim.diagnostic.goto_next"; options.desc = "Next diagnostic"; }
        { mode = "n"; key = "<leader>ld"; action.__raw = "vim.diagnostic.open_float"; options.desc = "Show diagnostics"; }
        # Buffer navigation
        { mode = "n"; key = "<leader>bn"; action = ":bnext<CR>"; options.desc = "Next buffer"; }
        { mode = "n"; key = "<leader>bp"; action = ":bprevious<CR>"; options.desc = "Previous buffer"; }
        { mode = "n"; key = "<leader>bd"; action = ":bdelete<CR>"; options.desc = "Delete buffer"; }
        { mode = "n"; key = "<Tab>"; action = ":bnext<CR>"; options.desc = "Next buffer"; }
        { mode = "n"; key = "<S-Tab>"; action = ":bprevious<CR>"; options.desc = "Previous buffer"; }
        # Save and quit
        { mode = "n"; key = "<leader>w"; action = ":w<CR>"; options.desc = "Save"; }
        { mode = "n"; key = "<leader>q"; action = ":q<CR>"; options.desc = "Quit"; }
        { mode = "n"; key = "<leader>Q"; action = ":qa<CR>"; options.desc = "Quit all"; }
        # Window / pane navigation (handled by tmux-navigator; works across nvim splits and tmux panes)
        { mode = "n"; key = "<C-h>"; action = "<cmd>TmuxNavigateLeft<cr>"; options.desc = "Navigate left"; }
        { mode = "n"; key = "<C-j>"; action = "<cmd>TmuxNavigateDown<cr>"; options.desc = "Navigate down"; }
        { mode = "n"; key = "<C-k>"; action = "<cmd>TmuxNavigateUp<cr>"; options.desc = "Navigate up"; }
        { mode = "n"; key = "<C-l>"; action = "<cmd>TmuxNavigateRight<cr>"; options.desc = "Navigate right"; }
        # Resize windows
        { mode = "n"; key = "<C-Up>"; action = ":resize -2<CR>"; options.desc = "Decrease height"; }
        { mode = "n"; key = "<C-Down>"; action = ":resize +2<CR>"; options.desc = "Increase height"; }
        { mode = "n"; key = "<C-Left>"; action = ":vertical resize -2<CR>"; options.desc = "Decrease width"; }
        { mode = "n"; key = "<C-Right>"; action = ":vertical resize +2<CR>"; options.desc = "Increase width"; }
        # Indenting
        { mode = "v"; key = "<"; action = "<gv"; options.desc = "Indent left"; }
        { mode = "v"; key = ">"; action = ">gv"; options.desc = "Indent right"; }
        # Move text
        { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move text down"; }
        { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move text up"; }
        # Toggle wrap
        { mode = "n"; key = "<leader>uw"; action = ":set wrap!<CR>"; options.desc = "Toggle line wrap"; }
      ];

      plugins = {
        # File navigation
        nvim-tree = {
          enable = true;
          settings = {
            view.width = 30;
            filters.dotfiles = false;
            renderer.icons.show = {
              file = true;
              folder = true;
              folder_arrow = true;
              git = true;
            };
            hijack_directories = {
              enable = true;
              auto_open = true;
            };
          };
        };

        telescope = {
          enable = true;
          settings.defaults.file_ignore_patterns = [ "node_modules" ".git/" ];
          extensions.fzf-native.enable = true;
        };

        # Treesitter
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            nix lua python javascript typescript rust bash json yaml markdown html css
          ];
        };

        # Completion
        cmp = {
          enable = true;
          settings = {
            snippet.expand.__raw = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
            window = {
              completion.__raw = "require('cmp').config.window.bordered()";
              documentation.__raw = "require('cmp').config.window.bordered()";
            };
            mapping.__raw = ''
              require('cmp').mapping.preset.insert({
                ['<C-b>'] = require('cmp').mapping.scroll_docs(-4),
                ['<C-f>'] = require('cmp').mapping.scroll_docs(4),
                ['<C-Space>'] = require('cmp').mapping.complete(),
                ['<C-e>'] = require('cmp').mapping.abort(),
                ['<CR>'] = require('cmp').mapping.confirm({ select = true }),
                ['<Tab>'] = require('cmp').mapping(function(fallback)
                  if require('cmp').visible() then
                    require('cmp').select_next_item()
                  elseif require('luasnip').expand_or_jumpable() then
                    require('luasnip').expand_or_jump()
                  else
                    fallback()
                  end
                end, { 'i', 's' }),
                ['<S-Tab>'] = require('cmp').mapping(function(fallback)
                  if require('cmp').visible() then
                    require('cmp').select_prev_item()
                  elseif require('luasnip').jumpable(-1) then
                    require('luasnip').jump(-1)
                  else
                    fallback()
                  end
                end, { 'i', 's' }),
              })
            '';
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "buffer"; }
              { name = "path"; }
            ];
          };
        };

        luasnip.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-buffer.enable = true;
        cmp-path.enable = true;
        cmp-cmdline.enable = true;
        cmp_luasnip.enable = true;

        # UI
        lualine = {
          enable = true;
          settings.options = {
            theme = "nord";
            component_separators = { left = "|"; right = "|"; };
            section_separators = { left = " "; right = " "; };
          };
        };

        bufferline = {
          enable = true;
          settings.options = {
            diagnostics = "nvim_lsp";
            offsets = [
              {
                filetype = "NvimTree";
                text = "File Explorer";
                highlight = "Directory";
                separator = true;
              }
            ];
            separator_style = "slant";
          };
        };

        indent-blankline = {
          enable = true;
          settings = {
            indent.char = "|";
            scope = {
              enabled = true;
              show_start = false;
              show_end = false;
            };
          };
        };

        # Git
        gitsigns = {
          enable = true;
          settings.signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "_";
            topdelete.text = "-";
            changedelete.text = "~";
          };
        };

        fugitive.enable = true;

        neogit = {
          enable = true;
          settings = {
            kind = "tab";
            integrations.diffview = true;
          };
        };

        diffview.enable = true;

        # Utilities
        comment.enable = true;
        nix.enable = true;

        which-key = {
          enable = true;
          settings = {
            preset = "modern";
            delay = 500;
            win.border = "rounded";
            icons = {
              breadcrumb = "»";
              separator = "➜";
              group = "+";
            };
            spec = [
              { __unkeyed-1 = "<leader>f"; group = "Find"; }
              { __unkeyed-1 = "<leader>b"; group = "Buffer"; }
              { __unkeyed-1 = "<leader>c"; group = "Code"; }
              { __unkeyed-1 = "<leader>g"; group = "Git"; }
              { __unkeyed-1 = "<leader>t"; group = "Trouble"; }
            ];
          };
        };

        nvim-autopairs = {
          enable = true;
          settings = {
            check_ts = true;
            ts_config = {
              lua = [ "string" ];
              javascript = [ "string" "template_string" ];
            };
            disable_filetype = [ "TelescopePrompt" ];
            fast_wrap = {
              map = "<M-e>";
              chars = [ "{" "[" "(" "\"" "'" ];
              pattern.__raw = ''[=[[%'%"%>%]%)%}%,]]=]'';
              end_key = "$";
              keys = "qwertyuiopzxcvbnmasdfghjkl";
              check_comma = true;
              highlight = "Search";
              highlight_grey = "Comment";
            };
          };
        };

        trouble = {
          enable = true;
          settings = {
            auto_close = false;
            auto_preview = true;
            focus = false;
          };
        };

        todo-comments = {
          enable = true;
          settings = {
            signs = true;
            sign_priority = 8;
            keywords = {
              FIX = { icon = " "; color = "error"; alt = [ "FIXME" "BUG" "FIXIT" "ISSUE" ]; };
              TODO = { icon = " "; color = "info"; };
              HACK = { icon = " "; color = "warning"; };
              WARN = { icon = " "; color = "warning"; alt = [ "WARNING" "XXX" ]; };
              PERF = { icon = " "; alt = [ "OPTIM" "PERFORMANCE" "OPTIMIZE" ]; };
              NOTE = { icon = " "; color = "hint"; alt = [ "INFO" ]; };
              TEST = { icon = "⏲ "; color = "test"; alt = [ "TESTING" "PASSED" "FAILED" ]; };
            };
            highlight = {
              multiline = true;
              multiline_pattern = "^.";
              multiline_context = 10;
              before = "";
              keyword = "wide";
              after = "fg";
              comments_only = true;
              max_line_len = 400;
            };
            colors = {
              error = [ "DiagnosticError" "ErrorMsg" "#DC2626" ];
              warning = [ "DiagnosticWarn" "WarningMsg" "#FBBF24" ];
              info = [ "DiagnosticInfo" "#2563EB" ];
              hint = [ "DiagnosticHint" "#10B981" ];
              default = [ "Identifier" "#7C3AED" ];
              test = [ "Identifier" "#FF00FF" ];
            };
          };
        };

        nvim-surround.enable = true;
        web-devicons.enable = true;
        tmux-navigator.enable = true;

        colorizer = {
          enable = true;
          settings = {
            filetypes = {
              __unkeyed-1 = "css";
              __unkeyed-2 = "scss";
              __unkeyed-3 = "html";
              __unkeyed-4 = "javascript";
              __unkeyed-5 = "typescript";
              __unkeyed-6 = "jsx";
              __unkeyed-7 = "tsx";
            };
            user_default_options = {
              RGB = true;
              RRGGBB = true;
              names = false;
              RRGGBBAA = true;
              AARRGGBB = true;
              rgb_fn = true;
              hsl_fn = true;
              css = true;
              css_fn = true;
              mode = "background";
              tailwind = true;
              virtualtext = "■";
            };
          };
        };

        # LSP
        lsp = {
          enable = true;
          servers = {
            nixd.enable = true;
            lua_ls = {
              enable = true;
              settings.Lua = {
                diagnostics.globals = [ "vim" ];
                workspace.checkThirdParty = false;
                telemetry.enable = false;
              };
            };
            pyright.enable = true;
            ts_ls.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
              settings."rust-analyzer".check.command = "clippy";
            };
            clangd.enable = true;
            bashls.enable = true;
            jsonls.enable = true;
            yamlls.enable = true;
            html.enable = true;
            cssls.enable = true;
            dockerls.enable = true;
          };
        };
      };
    };
  };
}
