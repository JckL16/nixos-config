-- Protected plugin setup helper
function _G.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Failed to load " .. module .. ": " .. result, vim.log.levels.ERROR)
    return nil
  end
  return result
end

-- Define browse_directory function globally
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
