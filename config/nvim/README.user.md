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
- `fd-find`（命令是 `fdfind`）

默认 Ubuntu profile 会在检测到缺失依赖时自动用 `apt-get` 安装（根据 `profiles/ubuntu.sh` 的 `APT_DEPS` 显式映射）；如果你不希望自动安装，把 `profiles/ubuntu.sh` 里的 `INSTALL_DEPS=auto` 改成 `INSTALL_DEPS=0`（或直接删掉 `APT_DEPS`）。

如果你安装了 AppImage 版 `nvim` 但 `nvim --version` 仍显示旧版本，通常是 PATH 优先级问题：请用 `~/.local/bin/nvim --version` 验证，并把 `~/.local/bin` 放到 PATH 前面。

本仓库默认会通过 `path` 模块把下面这行写入 `~/.profile` / `~/.bashrc`（只追加一次）：

```sh
export PATH="$HOME/.local/bin:$PATH"
```

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
