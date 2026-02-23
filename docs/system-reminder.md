# System Reminder - 本次改造总结

日期：2026-02-24

## 目标

- 修复 gtags / Git / UI / Notes 键位冲突
- 将 gtags 自动数据库策略落实到代码与文档
- 将 Telekasten 键位改为更清晰的 notes 前缀方案
- 更新过期文档，确保与当前实现一致

## 已完成改动

### 1) gtags 键位与自动数据库

- 文件：`config/nvim/lua/plugins/gtags.lua`
- 新增键位：
  - `<leader>gd` 定义
  - `<leader>gr` 引用
  - `<leader>gs` 符号
  - `<leader>gf` 当前文件
- 自动更新策略：
  - `BufReadPost`：若数据库不存在则全量生成
  - `BufWritePost`：单文件增量更新
  - `VimLeavePre`：退出前全量更新兜底

### 2) Git 键位精简

- 文件：`config/nvim/lua/plugins/lazygit.lua`
- 仅保留 `<leader>gg` 作为 LazyGit 入口
- 删除大写 `G` 系列快捷键，减少维护负担

### 3) 释放冲突键位给 gtags

- 文件：`config/nvim/lua/plugins/keymaps-overrides.lua`
- 关闭 LazyVim 默认的：
  - `<leader>gd`
  - `<leader>gs`
  - `<leader>gg`

说明：`<leader>gg` 由 `lazygit.nvim` 重新接管为 Git 单一入口。

### 4) UI 图标切换键位改为小写

- 文件：`config/nvim/lua/plugins/ui-icons.lua`
- `NerdFontToggle` 快捷键从 `<leader>uI` 改为 `<leader>ui`

同时：

- 文件：`config/nvim/lua/config/keymaps.lua`
- 显式绑定 `<leader>ui` 到 `:NerdFontToggle`

### 5) Telekasten 键位重构（`o*`）

- 文件：`config/nvim/lua/plugins/telekasten.lua`
- 键位改为：
  - `<leader>op` panel
  - `<leader>od` today
  - `<leader>ow` this week
  - `<leader>on` new note
  - `<leader>ol` follow link
  - `<leader>oc` calendar
  - `<leader>of` find
  - `<leader>os` search
- 新增 markdown 下 `[[wikilink]]` 场景 `<C-CR>` 跟随/创建链接（终端兼容性相关）

### 6) 统一搜索高亮清理键

- 文件：`config/nvim/lua/config/keymaps.lua`
- 显式绑定 `<leader>l` 为 `:noh`

## 文档更新

- 重写：`docs/nvim/KEYMAP.md`
- 重写：`docs/nvim/CODE_READING.md`
- 更新：`config/nvim/README.user.md`

文档已对齐为当前实现：

- gtags 实际键位与自动策略
- Git 单一入口 `<leader>gg`
- Telekasten `o*` 前缀
- UI 图标切换 `<leader>ui`

## 验证

- `nvim --headless '+qa'` 启动无错误
- 关键键位检查通过：
  - `<leader>gd/gr/gs/gf`
  - `<leader>gg`
  - `<leader>ui`
  - `<leader>od/on/of/os/op`
  - `:Gtags` 命令可用

## 追加修复（安装链路相关）

在完成键位与文档改造后，进一步修复了先前审视中发现的安装/环境问题：

1. `home/profile.d/nvm.sh`
   - 修复 `\&\&` 误写为 `&&`
   - 修复 `bash_completion` 错误 source 到 `nvm.sh` 的问题

2. Python 工具链迁移（pyenv -> uv）
   - 删除 `home/profile.d/pyenv.sh`，不再维护 pyenv profile 逻辑
   - `modules/10-dev-tools.sh` 改为使用 `uv` 安装 Python 3.13
   - 使用 `~/.local/bin/python` 和 `~/.local/bin/python3` 软链接统一到 uv 的 3.13

3. 新增 `modules/zoxide.sh`
   - 补齐 `40-system.sh` 依赖的模块缺失问题
   - 使用 `apt_helpers` 保持安装逻辑一致

4. `modules/50-optional.sh`
   - `nvm` / `opencode` / `mihomo` 改为“即使已安装也执行模块”，确保 profile/config 链接始终可修复

5. `modules/mihomo.sh`
   - 删除重复定义的 `ensure_mihomo_config()`
   - 修复原有配置探测条件判断错误

6. `config/nvim/lua/plugins/mason-config.lua`
   - Go 路径从 `/usr/local/go/bin` 改为 `~/.local/go/bin`
   - 与 dotfiles 的 Go 安装位置保持一致
