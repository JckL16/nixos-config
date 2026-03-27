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
keymap('n', '<leader>fk', '<cmd>Telescope keymaps<cr>', { desc = "Find keymaps" })
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

-- Toggle line wrap
keymap('n', '<leader>uw', ':set wrap!<CR>', { desc = "Toggle line wrap" })
