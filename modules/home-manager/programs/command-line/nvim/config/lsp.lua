-- Modern LSP setup using vim.lsp.config
local cmp_nvim_lsp = safe_require('cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()

if cmp_nvim_lsp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- LSP servers configuration
-- Servers are only enabled if their binary is found on the system
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
        check = {
          command = "clippy"
        },
      }
    }
  },
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  },
  clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  },
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'sh', 'bash' },
  },
  jsonls = {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
  },
  yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose' },
  },
  html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html', 'templ' },
  },
  cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
  },
  dockerls = {
    cmd = { 'docker-langserver', '--stdio' },
    filetypes = { 'dockerfile' },
  },
  terraformls = {
    cmd = { 'terraform-ls', 'serve' },
    filetypes = { 'terraform', 'terraform-vars' },
  },
  zls = {
    cmd = { 'zls' },
    filetypes = { 'zig' },
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
