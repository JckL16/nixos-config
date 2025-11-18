-- Modern LSP setup using vim.lsp.config
local cmp_nvim_lsp = safe_require('cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()

if cmp_nvim_lsp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- LSP servers configuration
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

-- Setup each LSP server
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
