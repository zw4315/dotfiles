# Neovim 配置说明（`config/nvim`）

这是一套独立的 Neovim 配置（不依赖 Vim 的 `~/.vim`），使用 `lazy.nvim` 管理插件，目标是跨平台可启动 + 核心功能可用。

## 入口与结构

- `init.lua`：极简入口；设置 `mapleader`，加载 `lua/zw/*`，bootstrap `lazy.nvim`，然后加载 `lua/plugins/*`。
- `lua/zw/`：自定义“能力层”（选项/命令/键位/自动命令 + 小工具）。
- `lua/plugins/`：插件声明与配置（lazy spec）。
- `after/plugin/`、`plugin/`：少量 Vimscript（兼容旧能力）。

## 自定义能力（`lua/zw/*`）

### 1) 基础选项（`lua/zw/options.lua`）

- 常用编辑选项：相对行号、`hlsearch`、tab=4 + `expandtab`、语法折叠等。
- `termguicolors=true`
- 外部工具探测：仅在系统存在 `ctags/gtags` 时启用 gutentags 相关插件（否则禁用）。

### 2) 命令封装（`lua/zw/commands.lua`）

提供与旧 Vim 习惯接近的用户命令（缺依赖时只 warn，不崩溃）：

- `:Files`：等价 `telescope.find_files({ hidden=true })`
- `:History`：等价 `telescope.oldfiles()`
- `:Rg [query]`：等价 `telescope.live_grep()`（依赖 `rg`）
- 替换入口由 `nvim-spectre` 提供（见键位）。

### 3) 键位（`lua/zw/keymaps.lua`）

Leader 为 `\`。

- 查找/搜索
  - `<C-p>`：Files
  - `<leader>g`：live grep
  - `<leader>o`：recent files
- 替换（Spectre）
  - `<leader>rfs`：全项目替换 UI
  - `<leader>rf`：当前文件替换 UI
- 文件树/大纲/终端/窗口
  - `<C-n>`：NvimTreeToggle
  - `<leader>n`：NvimTreeFindFile
  - `<F8>`：AerialToggle（替代 Tagbar）
  - `<leader>tt`：ToggleTerm（浮动终端）
  - `<leader>m`：Maximize
- 其他小工具
  - `<F12>`：ToggleTransparent（透明背景）
  - `<leader>i`：打开 Inbox 浮窗
  - `<leader>x`：插入 `inbox:: ... ::inbox` 块
  - `<F5>`（insert）：插入时间戳

### 4) 自动命令（`lua/zw/autocmds.lua`）

- C/C++ 保存前自动 `clang-format`（仅当系统存在 `clang-format`）。
- Markdown 特定文件（`append.md`/`review.md`/`kanban.md`）保存前：把当前 `##` card 置顶并规范空行（“卡片置顶”能力）。

### 5) 透明背景（`lua/zw/transparent.lua`）

- 命令：`:ToggleTransparent`
- 映射：`<F12>`
- 在 `ColorScheme` 事件后自动重新 apply。

### 6) Inbox 浮窗（`lua/zw/inbox.lua`）

- 命令：`:Inbox`
- 映射：`<leader>i`
- 默认文件：`~/mgnt/notes/00-inbox.md`
  - 如不可写，会 fallback 到 `stdpath("state")/inbox.md`
  - headless 模式下不会开浮窗，直接 `:edit`（避免 CI/脚本卡住）
- 可配置：`vim.g.inbox_file`

### 7) Focus Task 计时器（`lua/zw/focus_task.lua`）

- `:Ft <minutes> [name...]`：启动倒计时
- `:Fc`：取消
- `:AddTask` / `:CancelTask`：别名
- 状态显示：写入 `vim.g.focus_task_status`，`lualine` 会展示（见 `lua/plugins/ui.lua`）。

## Vimscript 能力（少量保留）

### 1) QuickHL 增强（`after/plugin/quickhl-extra.vim`）

依赖 `t9md/vim-quickhl`，提供：

- `hh`：统计 + 高亮当前词
- `hc`：当前命中序号/总数
- `hj`/`hk`：命中间跳转
- `hg`：跳到第 N 个命中
- `hx`：清空高亮

### 2) 文件元数据（`plugin/file_metadata.vim`）

在项目根（`.git` 或 `.root`）下维护 `<root>/.metadata/*`，用于给文件附加描述/跟随重命名：

- `:MetaList` / `:MetaDesc` / `:MetaPrune` / `:MetaMove`

## 插件集合（`lua/plugins/*`）

### `lua/plugins/editor.lua`

- 终端：`toggleterm.nvim`
- 文件树：`nvim-tree.lua`
- 搜索：`telescope.nvim`（依赖 `plenary.nvim`；grep 依赖外部 `rg`）
- 替换 UI：`nvim-spectre`（依赖 `rg`）
- Git：`gitsigns.nvim`
- 大纲：`aerial.nvim`
- 窗口最大化：`maximize.nvim`
- 注释：`Comment.nvim`
- 环绕：`nvim-surround`

### `lua/plugins/ui.lua`

- 主题：`onedark.nvim`
- 状态栏：`lualine.nvim`（展示 `focus_task_status`）

### `lua/plugins/vim-compat.lua`

保留少量 Vim 生态插件：

- `vim-quickhl`、`vim-table-mode`、`tabular`、`vim-markdown`
- `vim-gutentags`/`gutentags_plus`（仅当系统存在 `ctags/gtags` 时启用）

## 与 LazyVim 的重叠点（用于 review）

LazyVim（或基于它的发行版）通常已经内置/推荐了：

- 文件树、telescope、toggleterm、lualine、gitsigns、comment/surround、outline（或 symbols）等同类能力
- 更完整的 LSP/格式化/诊断体系（例如 `conform.nvim`/`nvim-lint` 等）

你可以把这份配置理解为：

- 适合“只要最小可用 + 保留少量个人工作流（inbox/计时/卡片置顶/metadata）”的独立配置；
- 如果你更想获得“开箱即用的完整 IDE 体验”，LazyVim 可能更省时间，但需要接受它的默认体系并在其框架内做定制。

## 调试/CI 相关

- `DOTFILES_NVIM_SKIP_BOOTSTRAP=1`：不 bootstrap `lazy.nvim`（用于无网络/headless 验证启动）。

