# Dotfiles 架构速查文档

> 本文档面向仓库维护者，用于快速回忆仓库结构和定位代码。反映 **当前实际代码状态**，而非理想设计。

---

## 1. 一句话概括

这是一个 dotfiles 配置库，采用 **Profile → App → OS** 三层架构。但现实中存在**新旧两套并行系统**：

- **新系统**（`apps/` + `init.sh`）：架构清晰，支持 macOS/Linux，但仅有 6 个应用，功能不足。
- **旧系统**（`modules/`）：包含 15+ 功能模块（Go、Python、Node、Rust 等），但全部硬编码 `apt-get`，**且不被 `init.sh` 调用**。

---

## 2. 目录结构总览

```
dotfiles/
├── init.sh                  # 【唯一入口】新系统的主调度器
│
├── lib/
│   ├── common.sh            # 核心工具库（日志、文件链接、Git、Shell注入）
│   ├── darwin.sh            # macOS 平台：Homebrew 封装、defaults 工具
│   ├── linux.sh             # Linux 平台：apt/pacman/dnf/apk 多发行版
│   ├── apt_helpers.sh       # Ubuntu 专用 apt 包装（旧系统重度依赖）
│   ├── appimage.sh          # AppImage 下载器（Linux 专用，主要用于 nvim）
│   └── winget.sh            # Windows 专用
│
├── apps/                    # 【新系统】按应用组织的安装+配置
│   ├── bash/                #   链接 bashrc/profile/aliases，创建 ~/.profile.d
│   ├── git/                 #   安装 git，链接 gitconfig
│   ├── nvim/                #   安装 neovim，链接 config/nvim/ → ~/.config/nvim
│   ├── tmux/                #   安装 tmux，链接 tmux.conf
│   ├── zoxide/              #   安装 zoxide，向 shell rc 注入 init
│   └── mihomo/              #   链接 mihomo 配置（Linux only）
│       # 每个应用目录结构：
│       #   app.sh      → 应用定义（元数据 + 生命周期钩子）
│       #   config/     → 跨平台共享配置（可选）
│       #   darwin.sh   → macOS 覆盖（可选）
│       #   linux.sh    → Linux 覆盖（可选）
│
├── profiles/                # 【Profile 层】场景化组合
│   ├── developer.sh         # 新系统：APPS_COMMON=(bash git zoxide nvim tmux)
│   ├── personal.sh          # 新系统：与 developer 当前相同
│   ├── minimal.sh           # 新系统：bash git zoxide
│   └── ubuntu.sh            # 【旧系统】定义模块开关（00-core=1 等），init.sh 不支持
│
├── os/                      # 【OS 层】平台初始化与系统设置
│   ├── darwin/
│   │   ├── bootstrap.sh     # 首次初始化：安装 Homebrew、运行 Brewfile
│   │   ├── Brewfile         # Homebrew 软件清单
│   │   └── defaults.sh      # macOS 系统偏好（Finder/Dock/键盘等 defaults write）
│   ├── linux/
│   │   ├── bootstrap.sh     # 首次初始化：apt-get update
│   │   └── defaults.sh      # （目前为空壳）
│   └── macos/               # 空目录（与 darwin/ 语义重复，待清理）
│
├── modules/                 # 【旧系统】功能模块（全部硬编码 apt）
│   ├── 00-core.sh           #   curl, wget, unzip
│   ├── 10-dev-tools.sh      #   uv + Python 3.13 + Go（注意：Go 下载 linux-amd64）
│   ├── 20-editors.sh        #   vim/nvim（AppImage）、tree-sitter-cli
│   ├── 30-dev-env.sh        #   git, rg, fd, ctags, global, clang-format
│   ├── 40-system.sh         #   bash 配置链接、tmux 源码编译、zoxide、scripts
│   ├── 50-optional.sh       #   rust, nvm, opencode, mihomo
│   └── tmux.sh, ctags.sh, global.sh, ...  # 子模块
│
├── home/                    # 要链接到 $HOME 的配置文件
│   ├── bashrc, profile, bash_aliases, proxyrc
│   ├── gitconfig, vimrc, tmux.conf
│   ├── profile.d/           #   环境变量片段（go, gtags, nvm, rust, opencode）
│   ├── global/              #   GNU Global (gtags) 配置
│   └── vim/                 #   Vim 脚本和插件（除 plugged 外链接子目录）
│
├── config/                  # XDG 配置目录（链接到 ~/.config/）
│   ├── nvim/                #   Neovim 配置（LazyVim + 自定义）
│   ├── mihomo/              #   Mihomo 代理配置
│   ├── packages.conf        # 【旧系统】包分组定义
│   └── presets.conf         # 【旧系统】预设定义
│
└── scripts/                 # 独立辅助脚本
    ├── proxy, yank, hfget, ab, run_gost, sync_to_gdrive
```

---

## 3. 执行流程（新系统）

```bash
./init.sh --profile developer

1. parse_args()       → 解析 --profile/--app/--dry-run
2. detect_os()        → $OSTYPE → darwin/linux/windows → source lib/<os>.sh
3. load_profile()     → source profiles/developer.sh
                        合并 APPS_COMMON + APPS_${OS^^} 到 APPS 数组
4. apply_profile()    → 遍历 APPS，对每个 app 调用 run_app()
5. run_app("git")     → source apps/git/app.sh
                        → source apps/git/darwin.sh（如有）
                        → 调用 app_install() / app_configure() / app_post_install()
6. OS 收尾            → source os/darwin/defaults.sh
```

### 旧系统的执行方式（注意：init.sh 不支持）

旧系统由 `profiles/ubuntu.sh` 输出模块开关，然后由外部脚本逐行读取执行：

```bash
# 旧系统调用方式（目前无入口调用它）
source profiles/ubuntu.sh
dotfiles_profile_apply --dev   # 输出 "00-core=1\n10-dev-tools=1\n..."
# 外部脚本会逐行执行：source modules/00-core.sh && module_main 1
```

---

## 4. 核心机制

### 4.1 配置文件链接

三个链接函数（全部支持**自动备份**和 **--dry-run 预览**）：

| 函数 | 用途 | 示例 |
|------|------|------|
| `link_file "$src" "$dst"` | 通用文件/目录链接 | `link_file "$src" "$HOME/.bashrc"` |
| `link_home_file "$src" "$name"` | 链接到 `$HOME` | `link_home_file "apps/git/config/gitconfig" ".gitconfig"` |
| `link_config_dir "$src" "$name"` | 链接到 XDG 配置目录 | `link_config_dir "config/nvim" "nvim"` |

**备份规则**：如果目标已存在（且不是指向同一源的符号链接），自动备份为 `dst.backup.YYYYMMDDHHMMSS`。

### 4.2 App 生命周期

每个应用实现 3 个可选钩子：

```bash
app_install() {       # 安装软件（包管理器、下载、编译）
  pkg_install_auto "$APP_NAME"   # 让 OS 层自动选择包名
}
app_configure() {     # 链接配置文件
  link_home_file "$APP_DIR/config/xxx" ".xxx"
}
app_post_install() {  # 初始化（如 git config）
  :
}
```

**平台覆盖**：`apps/<name>/darwin.sh` 会在 `app.sh` 之后加载，同名函数会**覆盖**（非继承）。

### 4.3 包管理器抽象

`lib/common.sh` 定义桩函数，`lib/darwin.sh` / `lib/linux.sh` 覆盖实现：

| 函数 | darwin 实现 | linux 实现 |
|------|------------|-----------|
| `pkg_install(pkg)` | `brew install` | 检测 apt/pacman/dnf/apk 后安装 |
| `pkg_is_installed(pkg)` | `brew list` | 对应包管理器查询 |
| `pkg_install_auto(app_name)` | 读取 `APP_BREW_FORMULA` | 读取 `APP_APT_PACKAGE` |

---

## 5. macOS 支持状态矩阵

| 功能 | 新系统 apps/ | 旧系统 modules/ | macOS 可用性 | 备注 |
|------|-------------|----------------|-------------|------|
| bash 配置 | ✅ `apps/bash` | ✅ `40-system.sh` | ✅ 可用 | aliases 已含 darwin 分支 |
| git | ✅ `apps/git` | ✅ `30-dev-env.sh` | ✅ 可用 | gitconfig 链接 |
| nvim | ✅ `apps/nvim` | ✅ `20-editors.sh` | ✅ 可用 | brew install neovim |
| tmux | ✅ `apps/tmux` | ✅ `modules/tmux.sh` | ✅ 可用 | brew install tmux |
| zoxide | ✅ `apps/zoxide` | ✅ `modules/zoxide.sh` | ✅ 可用 | 含 darwin.sh 覆盖 |
| rg (ripgrep) | ❌ 无 | ✅ `30-dev-env.sh` | ❌ 缺失 | 需新增 app |
| fd | ❌ 无 | ✅ `30-dev-env.sh` | ❌ 缺失 | 需新增 app |
| fzf | ❌ 无 | ❌ 无 | ❌ 缺失 | 需新增 app |
| Go | ❌ 无 | ✅ `10-dev-tools.sh` | ❌ 缺失 | 下载硬编码 linux-amd64 |
| Python (uv) | ❌ 无 | ✅ `10-dev-tools.sh` | ⚠️ 部分 | uv 本身跨平台，但旧模块 apt 前置检查会失败 |
| Node (nvm) | ❌ 无 | ✅ `modules/nvm.sh` | ⚠️ 部分 | nvm 跨平台，但旧模块未被 init.sh 调用 |
| Rust | ❌ 无 | ✅ `modules/rustup.sh` | ⚠️ 部分 | rustup 跨平台，但旧模块未被 init.sh 调用 |
| ctags | ❌ 无 | ✅ `modules/ctags.sh` | ❌ 缺失 | 需新增 app |
| global (gtags) | ❌ 无 | ✅ `modules/global.sh` | ❌ 缺失 | 需新增 app |
| clang-format | ❌ 无 | ✅ `modules/clang_format.sh` | ❌ 缺失 | 需新增 app |
| zsh 配置 | ❌ 无 | ❌ 无 | ❌ 缺失 | macOS 默认 shell，无配置 |
| mihomo | ✅ `apps/mihomo` | ✅ `modules/mihomo.sh` | ✅ 可用 | 已跨平台 |

**结论**：新系统在 macOS 上只有最基础的 6 个应用可用。大量开发工具（Go、Node、Rust、各种 CLI 工具）只能通过旧系统安装，而旧系统完全无法在 macOS 运行。

---

## 6. 关键技术债

1. **init.sh 与旧模块系统断裂**：旧系统的 15 个模块没有任何入口能调用它们。`profiles/ubuntu.sh` 输出的是模块开关文本，但 `init.sh` 只认 `APPS` 数组。
2. **配置位置不统一**：nvim 配置在根目录 `config/nvim/`（历史遗留），而 git/bash 配置在 `apps/*/config/`（新规范）。
3. **语义重复目录**：`os/darwin/` 和 `os/macos/` 并存，后者为空。
4. **旧模块的 `log` 函数与新系统不兼容**：旧模块使用 `log "✅ ..."`，新系统使用 `log_success` / `log_info`。

---

## 7. 快速定位代码

| 我想改... | 去哪里找 |
|-----------|---------|
| 增加一个新应用 | `apps/<name>/app.sh` → 在 `profiles/*.sh` 的 `APPS_COMMON` 中添加 |
| macOS 包名与 Linux 不同 | 在 `app.sh` 中同时声明 `APP_BREW_FORMULA` 和 `APP_APT_PACKAGE` |
| 某个应用在 macOS 上行为不同 | 创建 `apps/<name>/darwin.sh`，覆盖对应生命周期函数 |
| macOS 系统设置 | `os/darwin/defaults.sh`（`defaults write`） |
| Homebrew 相关逻辑 | `lib/darwin.sh`（前缀检测、brew 安装、包管理） |
| 添加 shell 环境变量片段 | 创建 `home/profile.d/<name>.sh`，在对应 app 的 `app_configure()` 中链接 |
| 配置文件链接工具 | `lib/common.sh` → `link_file()` / `link_home_file()` / `link_config_dir()` |
| 新机器的首次初始化 | `os/darwin/bootstrap.sh` 或 `os/linux/bootstrap.sh` |

---

## 8. 常用命令

```bash
# 列出可用 profiles
./init.sh --list-profiles

# 预览（不实际执行）
./init.sh --profile developer --dry-run
./init.sh --app git --dry-run

# 安装单个应用
./init.sh --app nvim

# 应用完整 profile
./init.sh --profile developer

# ShellCheck 检查
shellcheck init.sh lib/*.sh apps/*/app.sh profiles/*.sh os/*/*.sh
```
