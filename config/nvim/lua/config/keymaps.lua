-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 在左侧文件树中显示当前文件位置
vim.keymap.set("n", "<leader>er", "<cmd>Neotree reveal<cr>", { desc = "Reveal current file in tree" })
