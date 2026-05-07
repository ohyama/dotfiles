-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.textwidth = 72
    vim.opt_local.colorcolumn = "72"
    vim.opt_local.formatoptions:append("t") -- textwidth で自動改行
    vim.opt_local.formatoptions:append("m") -- マルチバイト文字の境界で改行可能
    vim.opt_local.formatoptions:append("M") -- マルチバイト結合時にスペースを挿入しない
    -- gq を textwidth ベースで動かすため formatexpr を空にする
    vim.opt_local.formatexpr = ""
  end,
})
