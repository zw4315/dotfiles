-- Bookmarks.nvim: 强大的书签管理插件
-- 使用 SQLite 存储书签，支持 Telescope 快速检索
return {
  "LintaoAmons/bookmarks.nvim",
  -- pin the plugin at specific version for stability
  -- backup your bookmark sqlite db when there are breaking changes (major version change)
  tag = "3.2.0",
  dependencies = {
    { "kkharji/sqlite.lua" },
    { "nvim-telescope/telescope.nvim" },
    { "stevearc/dressing.nvim" },
  },
  config = function()
    local opts = {
      -- 提示符配置
      signs = {
        mark = { icon = "🔖", color = "red", line_bg = "#572626" },
      },

      -- picker 配置
      picker = {
        -- 排序方式: "last_visited" | "created_date"
        sort_by = "last_visited",
      },

      -- 树形视图配置
      treeview = {
        -- 窗口分割尺寸
        window_split_dimension = 30,
      },
    }

    require("bookmarks").setup(opts)
  end,
  keys = {
    -- 添加/编辑/切换书签
    { "<leader>ba", "<cmd>BookmarksMark<cr>", desc = "Add/Edit Bookmark" },
    -- 跳转到书签（选择器）
    { "<leader>bg", "<cmd>BookmarksGoto<cr>", desc = "Goto Bookmark" },
    -- 选择并切换书签列表
    { "<leader>bl", "<cmd>BookmarksLists<cr>", desc = "List Bookmarks" },
    -- 跳转到下一个书签（按行号）
    { "<leader>bn", "<cmd>BookmarksGotoNext<cr>", desc = "Next Bookmark" },
    -- 跳转到上一个书签（按行号）
    { "<leader>bp", "<cmd>BookmarksGotoPrev<cr>", desc = "Previous Bookmark" },
    -- 跳转到列表中下一个书签
    { "<leader>bN", "<cmd>BookmarksGotoNextInList<cr>", desc = "Next Bookmark in List" },
    -- 跳转到列表中上一个书签
    { "<leader>bP", "<cmd>BookmarksGotoPrevInList<cr>", desc = "Previous Bookmark in List" },
    -- 搜索书签内容（Grep）
    { "<leader>bs", "<cmd>BookmarksGrep<cr>", desc = "Search Bookmarks" },
    -- 打开书签树视图
    { "<leader>bt", "<cmd>BookmarksTree<cr>", desc = "Bookmarks Tree" },
    -- 查询书签（SQL）
    { "<leader>bq", "<cmd>BookmarksQuery<cr>", desc = "Query Bookmarks" },
    -- 显示书签插件信息
    { "<leader>bi", "<cmd>BookmarksInfo<cr>", desc = "Bookmarks Info" },
    -- 打开命令选择器
    { "<leader>bc", "<cmd>BookmarksCommands<cr>", desc = "Bookmark Commands" },
  },
}
