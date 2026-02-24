-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- UI: Nerd Font 图标模式切换（glyph/ascii）
vim.keymap.set("n", "<leader>ui", "<cmd>NerdFontToggle<cr>", { desc = "Toggle Nerd Font Icons" })

-- 终端：<leader>ft 使用浮动终端（root）
vim.keymap.set("n", "<leader>ft", function()
  Snacks.terminal(nil, { cwd = LazyVim.root(), win = { position = "float" } })
end, { desc = "Terminal Float (Root Dir)" })

-- 搜索：清除高亮
vim.keymap.set("n", "<leader>l", "<cmd>noh<cr>", { desc = "Clear search highlight" })
