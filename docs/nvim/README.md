# Neovim 配置文档

本目录包含 Neovim 配置的详细说明。

## 模块结构

重构后使用 6 个核心模块，按数字顺序执行：

```
modules/
├── 00-core.sh          # 基础依赖 (curl, wget, unzip)
├── 10-dev-tools.sh     # 开发依赖 (uv Python 3.13, go)
├── 20-editors.sh       # 编辑器 (vim, nvim, treesitter_cli)
├── 30-dev-env.sh       # 开发工具 (git, lazygit, rg, fd, ctags, global, clang_format)
├── 40-system.sh        # 系统工具 (bash, tmux, zoxide, scripts)
└── 50-optional.sh      # 可选组件 (rust, nvm, opencode, mihomo)
```

### 配置文件

所有软件包定义在独立的配置文件中：

**config/packages.conf** - 包清单
```
core=
  curl
  wget
  unzip

dev-tools=
  uv
  python-3.13-via-uv
  go

...
```

**config/presets.conf** - 预设定义
```
minimal=
  core
  editors
  dev-env

dev=
  core
  dev-tools
  editors
  dev-env
  system

full=
  core
  dev-tools
  editors
  dev-env
  system
  optional
```

## 文件列表

| 文档 | 内容 |
|------|------|
| [treesitter.md](./treesitter.md) | Treesitter 语法高亮、文本对象 |
| [search-plugins.md](./search-plugins.md) | 搜索增强插件 (hlslens, interestingwords) |

## 使用方式

```bash
# 查看帮助
./init.sh --help

# 最小安装（核心 + 编辑器 + 开发环境）
./init.sh --min

# 开发完整（默认，包含 dev-tools）
./init.sh --dev

# 全部安装（包含可选组件）
./init.sh --full

# 预览安装
./init.sh --dev --dry-run
```

## 配置文件位置

```
config/nvim/lua/plugins/
├── treesitter.lua          # Treesitter 配置
├── hlslens.lua            # 搜索计数
├── interestingwords.lua   # 多词高亮
├── mason-config.lua       # Mason 配置
├── python.lua             # Python 开发
└── ...
```
