-- Neo-tree: 文件树插件配置
-- 显示隐藏文件（如 .env）
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- 显示隐藏文件
        show_hidden_count = true,
        hide_dotfiles = false, -- 不隐藏以 . 开头的文件
        hide_gitignored = false, -- 不隐藏 gitignore 的文件
        hide_by_name = {
          -- 可以在这里指定要隐藏的文件/文件夹
          ".git",
          "node_modules",
        },
        never_show = {
          -- 永远隐藏的文件
          ".DS_Store",
        },
      },
    },
  },
}
