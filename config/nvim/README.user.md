# Neovim（LazyVim）新机器上手

这份仓库会把 `config/nvim` 链接到你的 `~/.config/nvim`（见根目录 `init.sh` + `modules/nvim.sh`）。而 `config/nvim` 本身使用的是官方 **LazyVim starter**。

## 1) 安装（Ubuntu）

1. clone 本仓库
2. 运行：
   - 预演：`./init.sh --dry-run`
   - 执行：`./init.sh`

完成后：`~/.config/nvim` 会指向本仓库的 `config/nvim`。

## 2) 第一次打开

- 直接运行 `nvim`
- 按提示等待插件安装完成（LazyVim 会自动 bootstrap）

LazyVim/本仓库常用外部依赖（建议安装）：

- `nvim`（LazyVim 对 Neovim 版本有要求；本仓库在 Ubuntu 上会在需要时用 AppImage 安装到 `~/.local/bin/nvim`）
- `rg`（ripgrep）
- `fd`（Ubuntu 上 `fd-find` 的命令是 `fdfind`；本仓库的 `fd` 模块会在需要时创建 `~/.local/bin/fd` 作为兼容入口）

默认 Ubuntu profile 会启用对应的安装模块（如 `rg/fd/curl/wget` 等），缺少时会自动用 `apt-get` 安装。

如果你安装了 AppImage 版 `nvim` 但 `nvim --version` 仍显示旧版本，通常是 PATH 优先级问题：请用 `~/.local/bin/nvim --version` 验证，并把 `~/.local/bin` 放到 PATH 前面。
本仓库默认会通过 `bash` 模块把 `home/profile` 链接到 `~/.profile`，并在其中设置 `PATH`（包含 `~/.local/bin`）。

常用命令：

- `:Lazy` 打开插件管理界面
- `:Lazy sync` 同步插件

## 3) 示例：笔记双链 / Backlinks（obsidian.nvim）

本仓库示例配置文件：

- `config/nvim/lua/plugins/obsidian.lua`

默认假设你的笔记目录在：

- `~/mgnt/notes`

常用命令（在 markdown 里）：

- `:ObsidianBacklinks` 查看反向链接
- `:ObsidianLinks` 查看链接
- `:ObsidianQuickSwitch` 快速切换笔记
- `:ObsidianNew` 新建笔记

如果你的 notes 目录不是 `~/mgnt/notes`，请修改 `config/nvim/lua/plugins/obsidian.lua` 里的 workspace 路径。

## 4) 日历 + Zettelkasten / 日记联动（telekasten.nvim + calendar-vim）

配置文件：

- `config/nvim/lua/plugins/telekasten.lua`

默认笔记目录：

- `~/mgnt/agenda`（可用环境变量覆盖：`ZK_NOTES_DIR=/path/to/notes`）

常用操作：

- `<leader>zt`：打开/创建今天的 daily note
- `<leader>zc`：打开日历（在日历里选择日期并回车，会打开/创建当天 daily note）
- `<leader>zp`：telekasten 面板
- `<leader>zf`：查找笔记
- `<leader>zg`：全文搜索
