return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- 可选: 用于在浮动窗口边框显示图标
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- 设置快捷键
  -- 使用大写 G 因为 lazygit 是低频操作，小写 g 留给高频的 gtags
  keys = {
    { "<leader>Gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    { "<leader>Gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (当前文件)" },
    { "<leader>Gc", "<cmd>LazyGitConfig<cr>", desc = "LazyGit 配置" },
  },
}
