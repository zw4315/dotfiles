-- Aerial.nvim: 符号大纲（类似 Tagbar）
-- 显示当前文件的符号/标题树，支持 LSP 和 Treesitter
return {
  "stevearc/aerial.nvim",
  event = "LazyFile",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- 使用 LSP + Treesitter 作为后端
    backends = { "lsp", "treesitter", "markdown", "man" },
    -- 布局配置
    layout = {
      -- 默认放置在右侧
      default_direction = "right",
      -- 最小宽度
      min_width = 20,
      -- 最大宽度
      max_width = { 40, 0.2 },
      -- 宽度调整方式
      width = nil,
      -- 是否在右边
      placement = "window",
    },
    -- 是否显示折叠线
    show_guides = true,
    -- 高亮当前符号
    highlight_on_hover = true,
    -- 自动预览
    autojump = false,
    -- 打开时自动跳转
    open_automatic = false,
    -- 过滤器配置
    filter_kind = false, -- 显示所有类型
    -- 键位映射
    keymaps = {
      ["?"] = "actions.show_help",
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.jump",
      ["v"] = "actions.jump_vsplit",
      ["s"] = "actions.jump_split",
      ["p"] = "actions.scroll",
      ["<C-j>"] = "actions.down_and_scroll",
      ["<C-k>"] = "actions.up_and_scroll",
      ["{"] = "actions.prev",
      ["}"] = "actions.next",
      ["[["] = "actions.prev_up",
      ["]]"] = "actions.next_up",
      ["q"] = "actions.close",
      ["o"] = "actions.tree_toggle",
      ["O"] = "actions.tree_toggle_recursive",
      ["za"] = "actions.tree_toggle",
      ["zA"] = "actions.tree_toggle_recursive",
      ["l"] = "actions.tree_open",
      ["zo"] = "actions.tree_open",
      ["L"] = "actions.tree_open_recursive",
      ["zO"] = "actions.tree_open_recursive",
      ["h"] = "actions.tree_close",
      ["zc"] = "actions.tree_close",
      ["H"] = "actions.tree_close_recursive",
      ["zC"] = "actions.tree_close_recursive",
      ["zr"] = "actions.tree_increase_fold_level",
      ["zR"] = "actions.tree_open_all",
      ["zm"] = "actions.tree_decrease_fold_level",
      ["zM"] = "actions.tree_close_all",
      ["zx"] = "actions.tree_sync_folds",
      ["zX"] = "actions.tree_sync_folds",
    },
    -- 图标配置
    icons = {
      collapsed = "▶",
      expanded = "▼",
    },
    -- 向导线
    guides = {
      mid_item = "├ ",
      last_item = "└ ",
      nested_top = "│ ",
      whitespace = "  ",
    },
    -- 浮动窗口配置
    float = {
      border = "rounded",
      relative = "cursor",
      max_height = 0.9,
      min_height = { 8, 0.1 },
      height = nil,
      override = function(conf, source_winid)
        return conf
      end,
    },
    -- 导航窗口配置
    nav = {
      border = "rounded",
      max_height = 0.9,
      min_height = { 10, 0.1 },
      height = nil,
      max_width = 0.5,
      min_width = { 0.2, 20 },
      width = nil,
      autojump = false,
      preview = true,
      win_opts = {
        cursorline = true,
        winblend = 10,
      },
      keymaps = {
        ["<CR>"] = "actions.jump",
        ["<2-LeftMouse>"] = "actions.jump",
        ["<C-v>"] = "actions.jump_vsplit",
        ["<C-s>"] = "actions.jump_split",
        ["p"] = "actions.scroll",
        ["<C-j>"] = "actions.down_and_scroll",
        ["<C-k>"] = "actions.up_and_scroll",
        ["q"] = "actions.close",
      },
    },
    -- LSP 配置
    lsp = {
      -- 优先使用 documentSymbol
      prefer_symbol_kind = {
        "Class",
        "Function",
        "Method",
        "Constructor",
        "Interface",
        "Module",
        "Struct",
        "Trait",
        "Field",
        "Property",
      },
      -- 诊断图标
      diagnostics_trigger_update = true,
      update_when_errors = true,
      update_delay = 300,
    },
    -- 文件类型特定配置
    markdown = {
      -- 解析标题深度
      query = [[
        (atx_heading [
          (atx_h1_marker)
          (atx_h2_marker)
          (atx_h3_marker)
          (atx_h4_marker)
          (atx_h5_marker)
          (atx_h6_marker)
        ] @heading)
      ]],
      -- 捕获组映射
      heading = {
        ["atx_h1_marker"] = 1,
        ["atx_h2_marker"] = 2,
        ["atx_h3_marker"] = 3,
        ["atx_h4_marker"] = 4,
        ["atx_h5_marker"] = 5,
        ["atx_h6_marker"] = 6,
      },
    },
  },
  -- 按键映射
  keys = {
    -- F8: 切换符号大纲侧边栏
    { "<F8>", "<cmd>AerialToggle<cr>", desc = "Toggle Symbol Outline (Aerial)" },
    -- <leader>co: 打开导航窗口
    { "<leader>co", "<cmd>AerialNavOpen<cr>", desc = "Symbol Navigation (Aerial)" },
    -- 可选：其他有用的映射
    { "<leader>cs", "<cmd>AerialOpen<cr>", desc = "Open Symbol Outline" },
    { "<leader>cS", "<cmd>AerialClose<cr>", desc = "Close Symbol Outline" },
  },
}
