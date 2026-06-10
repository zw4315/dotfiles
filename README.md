# Dotfiles

分层设计的跨平台 dotfiles 管理工程。

## 设计哲学

- **用户只关心"我要什么能力"，不关心"怎么安装"**
- 三层架构：OS 层 → App 层 → Profile 层
- 按应用组织，而非按文件类型组织

## 快速开始

### 快速开始

```bash
# 克隆仓库（private repo 需先配置 SSH key）
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
./init.sh
```

### 常用命令

```bash
# 查看当前机器状态（已装/缺失/未启用/不支持）
./init.sh --check

# 预览要执行的操作（不实际修改）
./init.sh --dry-run

# 应用当前 OS 的默认清单
./init.sh

# 只安装/配置单个应用
./init.sh --app git --dry-run
./init.sh --app git
```

## 架构

```
dotfiles/
├── init.sh              # 入口：检测 OS → 加载 Manifest → 调度 Apps
├── lib/
│   ├── common.sh        # 共享工具（日志、文件操作）
│   ├── darwin.sh        # macOS 平台抽象（brew, defaults）
│   └── linux.sh         # Linux 平台抽象（apt, pacman）
├── apps/                # 【应用层】能力抽象
│   ├── git/
│   │   ├── app.sh       # Git 定义（安装、配置）
│   │   ├── config/      # 跨平台共享配置
│   │   └── darwin.sh    # macOS 覆盖（可选）
│   └── zoxide/
│       ├── app.sh
│       └── darwin.sh
├── os/                  # 【OS 层】平台实现
│   ├── darwin/
│   │   ├── bootstrap.sh # 首次初始化（安装 Homebrew）
│   │   ├── defaults.sh  # 系统偏好设置
│   │   └── Brewfile     # macOS 软件清单
│   └── linux/
│       ├── bootstrap.sh
│       └── defaults.sh
└── manifests/           # 【Manifest 层】OS 安装清单
    ├── catalog.toml     # App 元数据目录
    ├── darwin.toml      # macOS 启用清单
    └── linux.toml       # Linux 启用清单
```

## 添加新应用

创建 `apps/<name>/app.sh`：

```bash
APP_NAME="eza"
APP_BREW_FORMULA="eza"
APP_APT_PACKAGE="eza"

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  echo 'alias ls="eza --icons"' >> "$HOME/.zshrc"
}
```

然后在 `manifests/${OS}.toml` 的对应 section 中添加 `eza = true`。

## 添加新平台支持

1. 创建 `lib/<os>.sh` 实现 `pkg_install` 和 `pkg_is_installed`
2. 创建 `os/<os>/bootstrap.sh` 和 `os/<os>/defaults.sh`
3. 在需要的 app 中按需添加 `apps/<app>/<os>.sh` 覆盖
