# Repo 能力盘点 & 回归 Checklist

目的：把当前 `dotfiles` repo 里已经具备的“能力/行为”明确记录下来，后续重构（分层、跨平台、vim/nvim 拆分）时可以像做回归测试一样逐项对照，避免“重构完发现某个小功能丢了”。

> 这份清单以“能力”为中心，而不是以“文件”为中心：同一个能力可能由多个文件共同实现。

## 1) 安装/引导（init.sh）

现状实现：根目录 `init.sh` + `profiles/*.sh` + `modules/*.sh`。

- [ ] 入口：`./init.sh`（支持 `--dry-run`）
- [ ] Profile：`DOTFILES_PROFILE` 选择 profile（默认自动探测）
- [ ] Profile API：`dotfiles_profile_apply` 输出模块列表（每行一个 `name=value`）
- [ ] 链接策略：若目标已是正确软链则跳过；若目标存在且不是软链则备份为 `*.backup.<epoch>`；最后 `ln -sfn`
- [ ] 安装策略：每个模块自行按需安装依赖（Ubuntu 用 apt；少数模块会下载/编译）

## 2) Shell 环境（bash）

对应文件：`home/bashrc`、`home/profile`、`home/bash_aliases`、`home/proxyrc`。

- [ ] 交互 shell 基础体验（PS1、history、completion）保留 Ubuntu 默认逻辑
- [ ] 自动加载 `~/.bash_aliases`
- [ ] 自动加载代理切换：若存在 `~/.proxyrc` 则 source
- [ ] `ls` 配色（`LS_COLORS`）+ `alias ls='ls --color=auto'`
- [ ] `GTAGSLABEL=native-pygments` + `GTAGSCONF=~/.global/gtags.conf`（由 `home/profile` 提供）
- [ ] 若存在 `~/.cargo/env` 则加载 Rust 环境
- [ ] alias：`rm -i`（防误删）、`rg -i`（若有 rg）、若存在 `~/.bash_aliases.local` 则加载（机器私有）
- [ ] 代理快捷键：`puse`/`plis`/`pjump`/`pclash`/`poff`
- [ ] ssh 快捷键（多台机器）：`bd/bd2/yc/hd/centos`（这类建议未来迁到 local）

## 3) 代理能力（proxyrc）

对应文件：`home/proxyrc`、脚本：`scripts/run_gost`（与 jump profile 配合）。

- [ ] WSL 探测：若是 WSL，优先通过默认路由拿 Windows host IP，失败再用 `/etc/resolv.conf` nameserver
- [ ] Profile：`jump`（自建 gost 出口）、`clash`（本机或 Windows host 的 Clash）
- [ ] `proxy_use <profile|off>`：设置/清理 `http_proxy/https_proxy/all_proxy/no_proxy` + `PROXY_MODE`
- [ ] `proxy_list`：列出可用 profile + 当前模式
- [ ] `proxy_toggle`：`off -> jump -> clash -> off`

## 4) Git（基础体验）

对应文件：`home/gitconfig`。

- [ ] 设置 `user.name/user.email`
- [ ] `core.editor=vim`、`core.quotepath=false`
- [ ] 常用 alias：`st/co/fap/c/cm/ca/can/lg`
- [ ] GitHub/Gist credential helper：尝试使用 `gh auth git-credential`（注意：当前写法有条件判断，未来可回归验证其行为是否符合预期）

## 5) Tmux（剪贴板/终端能力）

对应文件：`home/tmux.conf`。

- [ ] 解绑 prefix+数字切窗默认行为，改为：数字键切 pane 并 `resize-pane -Z`
- [ ] 允许 OSC52 passthrough：`allow-passthrough on` + `set-clipboard on`（配合 `scripts/yank`）
- [ ] 终端颜色：`default-terminal xterm-256color` + `terminal-overrides ,*:Tc`

## 6) Vim（经典 Vim + 自定义插件能力）

对应文件：`home/vimrc`、`home/vim/**`。

### 6.1 基础编辑体验
- [ ] leader：`\\`
- [ ] 行号：绝对 + 相对
- [ ] 搜索高亮：`hlsearch`
- [ ] tab=4 + expandtab
- [ ] syntax fold（foldlevel=99）
- [ ] `path+=**`
- [ ] C/C++ 保存自动 `clang-format`（`BufWritePre *.cpp,*.h,*.cc :%!clang-format`）

### 6.2 插件系统 & 插件清单（vim-plug）
- [ ] `vim-plug` 作为插件管理器（plugged 在 `~/.vim/plugged`）
- [ ] floaterm、a.vim、quickhl、gutentags(+gutentags_plus)、fugitive、table-mode/tabular、nerdtree、fzf(+fzf.vim)、tagbar、vim-markdown、polyglot/cpp highlight、主题、surround、maximizer、airline、commentary、bookmarks
- [ ] `FZF_DEFAULT_COMMAND` 使用 `rg --files --hidden --glob "!.git/*"`

### 6.3 自定义增强（本 repo 自带的 vimscript）

quickhl 增强（`home/vim/after/plugin/quickhl-extra.vim`）：
- [ ] `hh`：统计当前词出现次数/首末行号，并高亮当前词
- [ ] `hx`：清空高亮（README 里写的是 `HH`，以实现为准：当前映射是 `hx`）
- [ ] `hc`：显示当前命中是第几个/总数 + 当前行号
- [ ] `hj/hk`：在命中间相对跳转（支持数字前缀）
- [ ] `hg`：跳到第 N 个命中（支持数字前缀）

rg + fzf 增强（`home/vim/after/plugin/rg_fzf.vim` + `home/vim/autoload/zw/rg.vim`）：
- [ ] `:Rg/:Rgcs/:RgExact/:Rgf`：ripgrep 结果进入 fzf 预览（bat 高亮）
- [ ] `<leader>rfs`：跨文件替换（逐文件 y/n/a/q）
- [ ] `<leader>rf`：当前 buffer 替换（`gc` 确认）

Floaterm 快捷键统一（`home/vim/autoload/zw/floaterm.vim`）：
- [ ] `g:zw_floaterm_prefix` 可配置，默认 `<leader>t`
- [ ] 支持 normal/terminal mode 同一套按键：toggle/new/kill/prev/next

Inbox 浮窗编辑（`home/vim/plugin/inbox_float.vim`）：
- [ ] `:InboxTerm`：用 Floaterm 打开 `~/mgnt/notes/00-inbox.md`（可配置）
- [ ] 默认映射：`<leader>i` 打开、`<leader>I` toggle（若支持）

透明背景（`home/vim/plugin/transparent.vim` + `home/vim/autoload/transparent.vim`）：
- [ ] `:ToggleTransparent` + `<F12>` 切换透明
- [ ] `ColorScheme` 变更后会重新 apply（若处于透明状态）

Focus task（`home/vim/plugin/focus_task.vim`）：
- [ ] `:Ft <minutes> [name...]` 启动倒计时，状态显示在 statusline/airline
- [ ] `:Fc`/`:CancelTask` 取消（实现里提供多个命令别名）
- [ ] 结束时滑动提示（timer 驱动）

Markdown card 自动置顶（`home/vim/after/plugin/card_auto_top.vim`）：
- [ ] 保存 `append.md/review.md/kanban.md` 时，将当前 card（`##` 区块）移动到文件顶部并规范空行

文件元数据系统（`home/vim/plugin/file_metadata.vim`）：
- [ ] 以“项目根”（`.git` 或 `.root`）为基准，在 `<root>/.metadata/` 记录文件元信息
- [ ] `:MetaList/:MetaDesc/:MetaPrune/:MetaMove` 等能力（用于列举/描述/清理/跟随重命名）

## 7) Neovim（lazy.nvim + 复用 Vim 增强）

对应文件：`config/nvim/**`。

- [ ] 通过 `runtimepath` 复用 `~/.vim` + `~/.vim/after` 的自定义 vimscript（与 Vim 行为尽量对齐）
- [ ] keymaps/选项与 `home/vimrc` 基本一致（leader、快捷键、format-on-save 等）
- [ ] 使用 `lazy.nvim` 管理插件，并尽量保持 Vim 侧插件等价
- [ ] lazy.nvim 不存在时自动 `git clone`（首次启动自举）

## 8) 其他脚本能力（~/bin 链接）

对应目录：`scripts/`。

- [ ] `scripts/yank`：OSC52 复制到终端/tmux/X11 剪贴板（tmux 配置已开启 passthrough）
- [ ] `scripts/hfget`：HuggingFace 下载镜像自动切换 + 限速 + 断点续传（生成 `hfget.log`）
- [ ] `scripts/run_gost`：管理 gost 代理（start/stop/status/logs + 自动重启）
- [ ] `scripts/sync_to_gdrive`：rclone 同步到 gdrive（带备份目录与后缀）
- [ ] `scripts/ab`：在笔记目录中搜索 `inbox:: ... ::inbox` 块（支持列文件/打印行号）

## 9) 未来“测试系统”是否不切实际？

不需要追求“像业务代码那样的全量 TDD”，但为 dotfiles/脚本库做一套 **可自动化的回归验证** 是完全现实的，尤其适合你这种“怕丢能力”的重构。

建议把“测试”拆成 3 层，成本从低到高：

1. **静态检查（最划算）**
   - Shell：`shellcheck`（脚本语法/常见坑）、`shfmt`（格式）
   - Lua：`stylua`（格式）、`luacheck`（可选）
2. **可重复的 smoke test（不依赖真实机器状态）**
   - 在临时 `$HOME` 下运行安装脚本（dry-run 或真实链接），断言目标软链是否齐全、备份策略是否生效
   - 验证关键文件可被解析（例如 `git config --file ... -l` 不报错）
3. **工具级集成测试（可选、但更接近真实）**
   - `vim -Nu <vimrc> -c 'q'` / `nvim --headless ...` 确认启动无报错（CI 里可跑）
   - 对自定义 vimscript 命令做“能加载/能调用”的最小验证（不测交互 UI）

这套体系更像“回归测试/契约测试”，很适合 dotfiles：你关注的是“能力还在不在、关键路径能不能跑”，而不是对每个函数做严格单元测试。
