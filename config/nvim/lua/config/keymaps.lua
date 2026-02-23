-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 在左侧文件树中显示当前文件位置
vim.keymap.set("n", "<leader>er", "<cmd>Neotree reveal<cr>", { desc = "Reveal current file in tree" })

-- UI: Nerd Font 图标模式切换（glyph/ascii）
vim.keymap.set("n", "<leader>ui", "<cmd>NerdFontToggle<cr>", { desc = "Toggle Nerd Font Icons" })

-- 搜索：清除高亮
vim.keymap.set("n", "<leader>l", "<cmd>noh<cr>", { desc = "Clear search highlight" })
