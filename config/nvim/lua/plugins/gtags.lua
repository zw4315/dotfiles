-- gtags 配置 - 支持全局代码跳转
-- 与 LSP 共存，提供快速代码导航

return {
  -- 自动生成 tags（ctags + gtags）
  {
    "ludovicchabant/vim-gutentags",
    event = "VeryLazy",
    config = function()
      -- 启用 gtags 模块
      vim.g.gutentags_modules = { "ctags", "gtags_cscope" }
      
      -- 缓存目录
      vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/tags")
      
      -- 项目根目录标记
      vim.g.gutentags_project_root = { ".root", ".git", ".hg", ".svn", ".bzr", 
        "_darcs", "package.json", "Cargo.toml", "go.mod", "Makefile", "CMakeLists.txt" }
      
      -- 关闭自动跳转目录
      vim.g.gutentags_plus_switch = 1
      
      -- 调试选项（需要时取消注释）
      -- vim.g.gutentags_trace = 1
      -- vim.g.gutentags_define_advanced_commands = 1
    end,
  },
  
  -- gtags 增强插件
  {
    "skywind3000/gutentags_plus",
    event = "VeryLazy",
    dependencies = { "ludovicchabant/vim-gutentags" },
    config = function()
      -- 按键映射
      local opts = { noremap = true, silent = true }
      
      -- gtags 跳转
      -- 注意：避免与 lazygit (<leader>gg) 冲突
      vim.keymap.set("n", "<leader>Gd", "<cmd>Gtags<cr>", vim.tbl_extend("force", opts, { desc = "Gtags definition" }))
      vim.keymap.set("n", "<leader>Gr", "<cmd>Gtags -r<cr>", vim.tbl_extend("force", opts, { desc = "Gtags references" }))
      vim.keymap.set("n", "<leader>Gs", "<cmd>Gtags -s<cr>", vim.tbl_extend("force", opts, { desc = "Gtags symbol" }))
      vim.keymap.set("n", "<leader>Gg", "<cmd>Gtags -g<cr>", vim.tbl_extend("force", opts, { desc = "Gtags grep" }))
      
      -- 与 LSP 配合：G 前缀用于 gtags（大写 G 避免与 lazygit 冲突）
      -- <leader>Gd - gtags 定义（快速）
      -- gd - LSP 定义（精确）
      -- <leader>Gr - gtags 引用（快速）
      -- gr - LSP 引用（精确）
      -- <leader>Gg - gtags grep（注意：不是 <leader>gg，避免与 lazygit 冲突）
    end,
  },
}
