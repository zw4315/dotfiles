# macOS 支持开发计划

## 1. 现状与问题

当前 `init.sh` 在 `detect_os_profile()` 中把 `Darwin` 直接映射到 `ubuntu` profile，但整个仓库的实现完全绑死 Debian/Ubuntu (`apt-get`)：

- **包管理器**: 所有模块调用 `lib/apt_helpers.sh`，macOS 无 `apt-get`。
- **二进制包**: Go 下载 `linux-amd64` 包、Neovim 下载 Linux AppImage，macOS 无法运行。
- **Shell**: macOS 默认 shell 为 zsh，但 `40-system.sh` 只链接 bash 配置文件。
- **兼容性**: `nproc`、`numfmt` 等命令在 macOS 上缺失或行为不同。

在 macOS 上执行 `./init.sh --dev` 的实际结果是：大部分模块因 `apt` 报错而直接 `die`，能正常工作的只有少数纯配置链接步骤。

## 2. 目标

让 macOS 用户执行 `./init.sh` 能获得与 Ubuntu 用户**等价**的体验：
- 自动检测 macOS 并使用 `macos` profile。
- 使用 Homebrew (`brew`) 替代 `apt-get` 安装系统包。
- 下载 macOS 原生二进制（`darwin-arm64` / `darwin-amd64`）。
- 默认 zsh 配置被正确链接。
- `--dry-run` 在 macOS 上也能正常预览。

## 3. 技术方案

### 3.1 核心抽象：包管理器 helper

新增 `lib/pkg_manager.sh`，提供统一接口，内部根据 OS 分发到 `apt` 或 `brew`：

```bash
# 统一接口（所有模块只调用这个）
dotfiles_pkg_ensure_cmd  <cmd> [<pkg>]   # 确保命令存在，不存在则安装
dotfiles_pkg_install_pkgs <pkg> ...      # 安装一个或多个包
```

实现内部逻辑：
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  source "$DOTFILES/lib/brew_helpers.sh"
  # 调用 brew 实现
else
  source "$DOTFILES/lib/apt_helpers.sh"
  # 调用 apt 实现
fi
```

**好处**：
- 模块代码不用写 `if Darwin` 分支，保持简洁。
- 未来支持其他发行版（如 Arch/Fedora）只需新增 helper。

### 3.2 OS 下载工具抽象

新增 `lib/platform.sh`，提供平台相关的变量和函数：

```bash
platform_os()       # linux | darwin
platform_arch()     # amd64 | arm64
platform_tar_ext()  # tar.gz
platform_go_suffix() # darwin-arm64 / linux-amd64
platform_nvim_asset() # nvim-macos-arm64.tar.gz / nvim-linux-x86_64.appimage
platform_nproc()    # CPU 核心数（兼容 macOS）
platform_human_size() # 替代 numfmt
```

### 3.3 Profile 体系

- 新增 `profiles/macos.sh`，模块列表与 `ubuntu.sh` 保持一致。
- `init.sh` 的 `detect_os_profile()` 中 `Darwin*)` 改为 `echo macos`。

## 4. 具体任务清单

### Phase 1: 基础设施（必须先完成）

| # | 任务 | 文件 | 说明 |
|---|------|------|------|
| 1.1 | 新建 `lib/platform.sh` | `lib/platform.sh` | OS/arch 检测、nproc 兼容、文件大小格式化 |
| 1.2 | 新建 `lib/brew_helpers.sh` | `lib/brew_helpers.sh` | 仿 apt_helpers，提供 `dotfiles_brew_ensure_cmd` / `dotfiles_brew_install_pkgs` |
| 1.3 | 新建 `lib/pkg_manager.sh` | `lib/pkg_manager.sh` | 统一封装，自动按 OS 路由到 apt 或 brew |
| 1.4 | 新建 `profiles/macos.sh` | `profiles/macos.sh` | 模块列表同 ubuntu.sh（minimal/dev/full） |
| 1.5 | 修改 OS 检测 | `init.sh` | `Darwin*) echo macos` |

### Phase 2: 模块改造（逐个替换 apt 依赖）

| # | 任务 | 文件 | 改造点 |
|---|------|------|--------|
| 2.1 | 改造 core 模块 | `modules/00-core.sh` | 用 `dotfiles_pkg_ensure_cmd` 替代直接调用 apt_helpers |
| 2.2 | 改造 dev-tools 模块 | `modules/10-dev-tools.sh` | ① 移除 `apt-get` 硬检查；② Go 下载地址用 `platform_go_suffix()`；③ `numfmt` 替换为 `platform_human_size()` |
| 2.3 | 改造 editors 模块 | `modules/20-editors.sh` | ① tree-sitter build deps 用 `pkg_manager`；② Neovim 安装逻辑改为用 `platform_nvim_asset()` 下载对应压缩包并解压（AppImage 仅 Linux） |
| 2.4 | 改造 dev-env 模块 | `modules/30-dev-env.sh` | git/rg/fd/ctags/global/clang-format 全部改用 `dotfiles_pkg_ensure_cmd` |
| 2.5 | 改造 system 模块 | `modules/40-system.sh` | ① 新增 zsh 配置链接（`.zshrc`、`.zprofile`）；② tmux/zoxide 安装走统一接口 |
| 2.6 | 改造 tmux 子模块 | `modules/tmux.sh` | ① build deps 走 `pkg_manager`；② `nproc` 替换为 `platform_nproc()` |
| 2.7 | 改造 zoxide 子模块 | `modules/zoxide.sh` | 改用 `dotfiles_pkg_ensure_cmd` |
| 2.8 | 改造 ctags 子模块 | `modules/ctags.sh` | 改用 `dotfiles_pkg_ensure_cmd` |
| 2.9 | 改造 global 子模块 | `modules/global.sh` | 改用 `dotfiles_pkg_ensure_cmd` |
| 2.10 | 改造 clang-format 子模块 | `modules/clang_format.sh` | 改用 `dotfiles_pkg_ensure_cmd` |

### Phase 3: AppImage / 二进制安装器改造

| # | 任务 | 文件 | 改造点 |
|---|------|------|--------|
| 3.1 | 改造 appimage 安装器 | `lib/appimage.sh` | ① 增加 `platform_os` 判断；② macOS 时不下载 AppImage，改为下载 `nvim-macos-*.tar.gz` 并解压到 `~/.local/bin`；③ 保持 Linux 路径不变 |

### Phase 4: zsh 配置支持

| # | 任务 | 文件 | 改造点 |
|---|------|------|--------|
| 4.1 | 新建 zsh 配置文件 | `home/zshrc`、`home/zprofile`（或 `home/zsh/` 目录） | 与现有 bash 配置等价：加载 `profile.d/*.sh`、设置 PATH、alias 等 |
| 4.2 | 修改 system 模块 | `modules/40-system.sh` | 新增 `setup_zsh()` 函数，链接 `.zshrc`、`.zprofile` |

### Phase 5: 测试与验证

| # | 任务 | 说明 |
|---|------|------|
| 5.1 | `--dry-run` 全路径验证 | 在干净 macOS 环境（或新用户目录）跑 `./init.sh --dev --dry-run`，确认无报错 |
| 5.2 | 实际安装验证 | 跑 `./init.sh --dev`，确认所有工具可执行 (`nvim`、`go`、`rg`、`fd`、`tmux`、`zoxide` 等) |
| 5.3 | 回归测试 | 在 Ubuntu 上再跑一遍，确保 Linux 路径没被改坏 |
| 5.4 | shellcheck 检查 | 所有新增/修改的 `.sh` 文件过 `shellcheck` |

## 5. 关键实现细节

### 5.1 Homebrew 安装前置检查

`brew_helpers.sh` 不应自动安装 Homebrew（耗时太长），而是：
```bash
dotfiles_brew_require() {
  command -v brew >/dev/null 2>&1 || die "Homebrew not found. Install from https://brew.sh"
}
```

### 5.2 Neovim macOS 安装方式

macOS 不支持 AppImage，推荐从 GitHub release 下载 `.tar.gz`：
```bash
# Darwin 路径
nvim_tar="nvim-macos-arm64.tar.gz"
curl -fL ... -o "$tmp/$nvim_tar"
tar -C "$tmp" -xzf "$tmp/$nvim_tar"
# 把 bin/nvim 复制/链接到 ~/.local/bin/nvim
```

或者更简单地用 `brew install neovim`，但考虑到仓库当前自己管理版本（AppImage），为了保持控制权，建议继续手动下载 release tarball。

### 5.3 Go macOS 安装

Go 官方 release 有 `darwin-amd64` 和 `darwin-arm64` 的 `.tar.gz`，解压逻辑与 Linux 相同，只是 URL 中的 `linux-amd64` 替换为平台相关字符串。

### 5.4 zsh 与 bash 配置复用

为避免维护两套 alias/PATH，zsh 配置应**source bash 配置**或共用 `profile.d/` 机制：

```bash
# home/zshrc
# Source bash aliases if they exist
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

# Source proxy settings
[[ -f ~/.proxyrc ]] && source ~/.proxyrc

# Add ~/.local/bin to PATH
export PATH="$HOME/.local/bin:$PATH"
```

## 6. 优先级建议

按以下顺序推进，每完成一个 Phase 就可以验证一次：

```
Phase 1 (基础设施) → Phase 2 (模块改造) → Phase 3 (AppImage) → Phase 4 (zsh) → Phase 5 (测试)
```

如果时间有限，**最小可用集**是：
1. `lib/pkg_manager.sh` + `lib/brew_helpers.sh`
2. `profiles/macos.sh` + `init.sh` OS 检测修复
3. 改造 `40-system.sh`（加 zsh 配置链接）
4. 改造 `10-dev-tools.sh`（Go 平台化）
5. 改造 `20-editors.sh`（Neovim 平台化）

这样至少能让 macOS 用户把 **dotfiles 链接 + 核心开发工具** 跑起来，其他的 `apt` 报错可以后续逐个修。

## 7. 文档更新

改造完成后需更新：
- `AGENTS.md`：补充 macOS 相关规范（brew helper 用法、平台抽象层）。
- `docs/SETUP.md`：增加 macOS 使用说明（需先装 Homebrew）。
- `README.md`：在支持平台里加上 macOS。
