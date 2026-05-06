-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.filetype.add({
  pattern = {
    [".*/cmux/cmux%.json"] = "jsonc",
    [".*/cmux/private_cmux%.json"] = "jsonc",
    [".*/cmux/settings%.json"] = "jsonc",
    [".*/cmux/private_settings%.json"] = "jsonc",
  },
})
