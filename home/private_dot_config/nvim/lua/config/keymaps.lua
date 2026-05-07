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

-- 矢印キー → ウィンドウ移動 (Normal モードのみ)
-- Karabiner-Elements で Ctrl+hjkl → 矢印キーにマッピングしているため、
-- NeoVim 側で矢印キーをウィンドウ移動に割り当てることで、
-- Ctrl+hjkl によるウィンドウ移動を復元する。
-- Insert モード: 矢印キーはデフォルトのカーソル移動のまま（変更不要）
-- Visual モード: 矢印キーはデフォルトの選択範囲移動のまま（変更不要）
-- Terminal モード: 矢印キーはデフォルトのカーソル移動のまま（Esc Esc で Normal に戻ってから移動）
vim.keymap.set("n", "<Left>", "<C-w>h", { desc = "Go to Left Window", silent = true })
vim.keymap.set("n", "<Down>", "<C-w>j", { desc = "Go to Lower Window", silent = true })
vim.keymap.set("n", "<Up>", "<C-w>k", { desc = "Go to Upper Window", silent = true })
vim.keymap.set("n", "<Right>", "<C-w>l", { desc = "Go to Right Window", silent = true })
