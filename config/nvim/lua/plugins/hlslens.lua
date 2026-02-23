-- nvim-hlslens: 搜索高亮和计数显示
-- 在搜索时显示 (1/10) 这样的匹配计数
return {
  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    config = function()
      require("hlslens").setup({
        -- 当光标移出匹配范围时清除高亮
        calm_down = false,
        -- 只为最近的匹配项添加 lens
        nearest_only = false,
        -- 何时显示浮动窗口
        nearest_float_when = "auto",
      })

      -- 按键映射
      local kopts = { noremap = true, silent = true }

      -- n/N 跳转时更新 lens
      vim.api.nvim_set_keymap(
        "n",
        "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require("hlslens").start()<CR>]],
        kopts
      )
      vim.api.nvim_set_keymap(
        "n",
        "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require("hlslens").start()<CR>]],
        kopts
      )

      -- */# 搜索时启动 lens
      vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require("hlslens").start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require("hlslens").start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require("hlslens").start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require("hlslens").start()<CR>]], kopts)

      -- <leader>l 清除搜索高亮
      vim.api.nvim_set_keymap("n", "<leader>l", "<Cmd>noh<CR>", { desc = "Clear search highlight" })
    end,
  },
}
