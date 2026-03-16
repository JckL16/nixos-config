-- Colorizer setup
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
      names = false,
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

-- Neogit setup
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
      untracked = { folded = false, hidden = false },
      unstaged = { folded = false, hidden = false },
      staged = { folded = false, hidden = false },
      stashes = { folded = true, hidden = false },
      unpulled = { folded = true, hidden = false },
      unmerged = { folded = false, hidden = false },
      recent = { folded = true, hidden = false },
    },
  })
end

-- Which-key setup
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
  surround.setup({})
end

-- Nvim-tree setup
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

-- Telescope setup
local telescope = safe_require('telescope')
if telescope then
  telescope.setup({
    defaults = {
      file_ignore_patterns = { "node_modules", ".git/" },
    }
  })
  pcall(telescope.load_extension, 'fzf')
end

-- Treesitter indent helper for use in indentexpr
function _G.ts_indent()
  return require('nvim-treesitter.indent').get_indent(vim.v.lnum)
end

-- Treesitter setup - enable highlighting and indentation per buffer
-- vim.treesitter.start() disables legacy syntax for that buffer, which breaks
-- legacy indent scripts (e.g. python#GetIndent), so we also switch to
-- treesitter-based indentation
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    if pcall(vim.treesitter.start) then
      vim.bo.indentexpr = "v:lua.ts_indent()"
    end
  end,
})

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

-- Comment setup
local comment = safe_require('Comment')
if comment then comment.setup() end

-- Indent blankline
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
