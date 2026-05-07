-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- VS Code 統合ターミナルでの Shift+数字バグへの対策
-- https://github.com/neovim/neovim/issues/38651
if vim.env.TERM_PROGRAM == "vscode" then
  local shifted_digits = {
    -- JIS (日本語) キーボード配列の場合
    -- ["<S-1>"] = "!",
    -- ["<S-2>"] = '"',
    -- ["<S-3>"] = "#",
    -- ["<S-4>"] = "$",
    -- ["<S-5>"] = "%",
    -- ["<S-6>"] = "&",
    -- ["<S-7>"] = "'",
    -- ["<S-8>"] = "(",
    -- ["<S-9>"] = ")",
    -- US (英字) 配列の場合
    ["<S-1>"] = "!",
    ["<S-2>"] = "@",
    ["<S-3>"] = "#",
    ["<S-4>"] = "$",
    ["<S-5>"] = "%",
    ["<S-6>"] = "^",
    ["<S-7>"] = "&",
    ["<S-8>"] = "*",
    ["<S-9>"] = "(",
    ["<S-0>"] = ")",
  }

  for lhs, rhs in pairs(shifted_digits) do
    vim.keymap.set({ "n", "x", "i" }, lhs, rhs, { noremap = true, silent = true })
    vim.keymap.set("c", lhs, function()
      return rhs
    end, { expr = true, noremap = true })
  end
end
