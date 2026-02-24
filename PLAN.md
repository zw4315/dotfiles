# Dotfiles 安装脚本优化计划

## 当前问题分析

### 现状
- **23 个独立模块**，总计 1177 行代码
- 每个模块 20-50 行，包含大量**重复样板代码**
- Profile 需手动列出全部 23 个模块
- **顺序执行**，即使无依赖也等待
- **依赖关系混乱**（如 dev_tools 应在其他模块前）

### 主要痛点

1. **模块碎片化**
   - rust.sh (23行) + rustup.sh (51行) 实际都是 Rust 相关
   - 分散的文件增加认知负担

2. **配置繁琐**
   ```bash
   # 当前需要列出全部 23 行
   bash=1
   scripts=1
   curl=1
   wget=1
   git=1
   # ... 还有 18 个
   
   # 想要简化但环境变量不够直观
   DOTFILES_PRESET=dev ./init.sh
   ```

3. **重复代码**
   - 每个模块都有相同的结构：shebang、source common.sh、module_main、自执行代码

4. **依赖不明确**
   - dev_tools 应该在所有 LSP 相关模块前执行
   - 但 profile 中位置任意

---

## 优化方案

### 阶段一：模块合并（立即实施）

**目标**：23 个模块 → 6 个核心模块

```
modules/
├── 00-core.sh          # unzip, curl, wget (基础依赖，最先执行)
├── 10-dev-tools.sh     # python3-pip, python3-venv, go (开发依赖)
├── 20-editors.sh       # vim, nvim, treesitter_cli
├── 30-dev-env.sh       # git, rg, fd, ctags, global, clang_format
├── 40-system.sh        # bash, tmux, zoxide, scripts
└── 50-optional.sh      # rust, nvm, opencode, mihomo (可选)
```

**优点**：
- Profile 只需 6 行配置
- 依赖关系清晰（按文件名数字顺序）
- 减少样板代码 70%

### 阶段二：预设配置 CLI（推荐实施）

**目标**：提供渐进式披露的 CLI 接口

**CLI 设计**：
```bash
./init.sh --help
# 输出：
# Usage: ./init.sh [PRESET] [options]
# 
# Presets:
#   --min       最小安装 (core + editors + dev-env)
#   --dev       开发完整 (默认，包含 dev-tools)
#   --full      全部安装 (包含可选组件)
# 
# Options:
#   --dry-run   预览更改
#   --help      显示帮助
#
# Examples:
#   ./init.sh --min          # 最小安装
#   ./init.sh --dev          # 开发完整（默认）
#   ./init.sh --full         # 全部安装
#   ./init.sh --min --dry-run # 预览最小安装

./init.sh --wrong-flag
# 输出：
# Error: Unknown flag '--wrong-flag'
# 
# Usage: ./init.sh [PRESET] [options]
# 
# Presets:
#   --min       最小安装
#   --dev       开发完整 (默认)
#   --full      全部安装
# 
# Run './init.sh --help' for full usage.
```

**渐进式披露设计**：
1. **错误输入** → 只显示简要用法（preset 列表）
2. **--help** → 显示完整帮助（含所有选项、示例）
3. **无参数** → 使用默认 preset（dev），显示简短提示

**实现方式**：
```bash
# init.sh 参数解析
PRESET="dev"  # 默认

while [[ $# -gt 0 ]]; do
  case "$1" in
    --min|--minimal) PRESET="minimal"; shift ;;
    --dev|--develop) PRESET="dev"; shift ;;
    --full|--complete) PRESET="full"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help|-h) show_full_help; exit 0 ;;
    --*) 
      echo "Error: Unknown flag '$1'" >&2
      show_brief_usage >&2
      exit 1
      ;;
    *) 
      echo "Error: Unknown argument '$1'" >&2
      show_brief_usage >&2
      exit 1
      ;;
  esac
done

show_brief_usage() {
  cat <<'EOF'
Usage: ./init.sh [PRESET] [options]

Presets:
  --min       最小安装
  --dev       开发完整 (默认)
  --full      全部安装

Run './init.sh --help' for full usage.
EOF
}

show_full_help() {
  cat <<'EOF'
Usage: ./init.sh [PRESET] [options]

Presets:
  --min       最小安装 (core + editors + dev-env)
  --dev       开发完整 (默认，包含 dev-tools)
  --full      全部安装 (包含可选组件)

Options:
  --dry-run   预览更改
  --help      显示帮助

Examples:
  ./init.sh --min           # 最小安装
  ./init.sh --dev           # 开发完整（默认）
  ./init.sh --full          # 全部安装
  ./init.sh --min --dry-run # 预览最小安装
EOF
}
```

**profiles/ubuntu.sh 对应修改**：
```bash
dotfiles_profile_apply() {
  local preset="${1:-dev}"  # 从参数接收，默认 dev
  
  case "$preset" in
    minimal|--min)
      echo "00-core=1"
      echo "20-editors=1"
      echo "30-dev-env=1"
      ;;
    dev|--dev|default)
      echo "00-core=1"
      echo "10-dev-tools=1"
      echo "20-editors=1"
      echo "30-dev-env=1"
      echo "40-system=1"
      ;;
    full|--full)
      echo "00-core=1"
      echo "10-dev-tools=1"
      echo "20-editors=1"
      echo "30-dev-env=1"
      echo "40-system=1"
      echo "50-optional=1"
      ;;
  esac
}
```

### 阶段三：智能依赖声明（未来扩展）

**目标**：模块自声明依赖

```bash
# modules/20-editors.sh
MODULE_DEPENDS="00-core,10-dev-tools"  # 自动确保先执行
MODULE_PRIORITY=20                      # 执行顺序
```

然后 init.sh 自动拓扑排序执行。

---

## 实施计划

### 第一步：合并模块（1-2 小时）

1. [ ] 创建 `modules/00-core.sh` - 合并 curl.sh + wget.sh + unzip
2. [ ] 创建 `modules/10-dev-tools.sh` - 已有，保留
3. [ ] 创建 `modules/20-editors.sh` - 合并 vim.sh + nvim.sh + treesitter_cli.sh
4. [ ] 创建 `modules/30-dev-env.sh` - 合并 git.sh + rg.sh + fd.sh + ctags.sh + global.sh + clang_format.sh
5. [ ] 创建 `modules/40-system.sh` - 合并 bash.sh + tmux.sh + zoxide.sh + scripts.sh
6. [ ] 创建 `modules/50-optional.sh` - 合并 rust.sh + rustup.sh + nvm.sh + opencode.sh + mihomo.sh
7. [ ] 删除旧模块文件
8. [ ] 更新 `profiles/ubuntu.sh`

### 第二步：预设配置 CLI（30 分钟）

1. [ ] 修改 `init.sh` 添加 CLI 参数解析（--min, --dev, --full, --help）
2. [ ] 实现渐进式披露帮助系统
3. [ ] 修改 `profiles/ubuntu.sh` 支持 preset 参数
4. [ ] 测试所有参数组合
5. [ ] 更新文档

---

## 预期收益

| 指标 | 当前 | 优化后 | 收益 |
|------|------|--------|------|
| 模块数量 | 23 | 6 | **-74%** |
| 配置行数 | 23 行 | 1 行 | **-96%** |
| 代码重复 | 高 | 低 | **-70%** |
| 依赖清晰度 | 混乱 | 明确 | **高** |

---

## 风险评估

### 低风险
- ✅ 模块合并：只改文件组织，不改逻辑
- ✅ 预设配置：完全向后兼容
- ✅ 智能依赖：可选功能，不影响现有流程

### 向后兼容
- 旧的手动配置方式仍然支持
- 可随时切换回单模块模式

---

## 决策点

**请决定**：

1. **是否实施阶段一（模块合并）？**
   - 推荐：是，收益高，风险低

2. **是否实施阶段二（预设配置 CLI）？**
   - 推荐：是，CLI 接口更直观，渐进式披露体验好

3. **是否实施阶段三（智能依赖）？**
   - 可选：未来需要更复杂依赖管理时实施

4. **优先实施哪个阶段？**
   - 建议：阶段一 → 阶段二 → 阶段三

### 附加功能：软件清单与状态检查（YAML 配置）

**目标**：创建可视化软件清单，安装前可检查所有软件状态

**YAML 配置文件结构**：
```yaml
# config/packages.yaml - 软件清单定义
packages:
  core:
    name: "Core Dependencies"
    description: "基础依赖，所有预设都会安装"
    tools:
      - name: curl
        description: "数据传输工具"
        check_cmd: "curl --version"
        required_by: [minimal, dev, full]
      
      - name: wget
        description: "文件下载工具"
        check_cmd: "wget --version"
        required_by: [minimal, dev, full]
      
      - name: unzip
        description: "解压工具"
        check_cmd: "unzip -v"
        required_by: [minimal, dev, full]

  dev-tools:
    name: "Development Tools"
    description: "开发环境基础工具"
    tools:
      - name: python3-pip
        description: "Python 包管理器"
        check_cmd: "pip3 --version"
        required_by: [dev, full]
      
      - name: python3-venv
        description: "Python 虚拟环境"
        check_cmd: "python3 -m venv --help"
        required_by: [dev, full]
      
      - name: go
        description: "Go 语言环境"
        check_cmd: "go version"
        required_by: [dev, full]
        version: ">=1.23.0"

  editors:
    name: "Editors"
    description: "代码编辑器"
    tools:
      - name: vim
        description: "Vim 编辑器"
        check_cmd: "vim --version"
        required_by: [minimal, dev, full]
      
      - name: nvim
        description: "Neovim 编辑器"
        check_cmd: "nvim --version"
        required_by: [minimal, dev, full]

  dev-env:
    name: "Development Environment"
    description: "开发环境工具链"
    tools:
      - name: git
        description: "版本控制"
        check_cmd: "git --version"
        required_by: [minimal, dev, full]
      
      - name: rg
        description: "快速搜索 (ripgrep)"
        check_cmd: "rg --version"
        required_by: [minimal, dev, full]
      
      - name: fd
        description: "快速查找 (fd)"
        check_cmd: "fd --version"
        required_by: [minimal, dev, full]

  system:
    name: "System Tools"
    description: "系统增强工具"
    tools:
      - name: tmux
        description: "终端复用器"
        check_cmd: "tmux -V"
        required_by: [dev, full]
      
      - name: zoxide
        description: "智能目录跳转"
        check_cmd: "zoxide --version"
        required_by: [dev, full]

  optional:
    name: "Optional Tools"
    description: "可选组件"
    tools:
      - name: rust
        description: "Rust 工具链"
        check_cmd: "rustc --version"
        required_by: [full]
      
      - name: nvm
        description: "Node 版本管理"
        check_cmd: "nvm --version"
        required_by: [full]
```

**CLI 状态检查功能**：
```bash
./init.sh --status
# 输出：
# 📋 Package Status Report
# ================================
# 
# Preset: dev (default)
# 
# [✅] core (3/3 installed)
#   ✅ curl        7.81.0      /usr/bin/curl
#   ✅ wget        1.21.2      /usr/bin/wget
#   ✅ unzip       6.0         /usr/bin/unzip
# 
# [⚠️ ] dev-tools (1/3 installed)
#   ✅ python3-pip 22.0.2      /usr/bin/pip3
#   ❌ python3-venv            (will be installed)
#   ❌ go                      (will be installed, need >=1.23.0)
# 
# [✅] editors (2/2 installed)
#   ✅ vim         8.2.4832    /usr/bin/vim
#   ✅ nvim        0.11.2      /usr/local/bin/nvim
# 
# [✅] dev-env (4/4 installed)
#   ...
# 
# Summary: 12/15 packages installed
# Missing: 3 packages will be installed

./init.sh --status --yaml
# 输出 YAML 格式的详细报告

./init.sh --status --min
# 查看 minimal preset 的状态
```

**功能说明**：
1. **YAML 清单**：所有软件定义在 `config/packages.yaml`，易于查看和维护
2. **状态检查**：`--status` 检查每个软件的安装状态和版本
3. **Preset 过滤**：根据选择的 preset 显示相关软件
4. **视觉反馈**：✅ 已安装，❌ 未安装，⚠️ 版本不符合要求
5. **详细报告**：显示安装路径、版本号、缺失项

---

## 参考命令

```bash
# 查看当前模块
ls -la modules/*.sh | wc -l

# 统计代码行数
wc -l modules/*.sh

# 查看帮助
./init.sh --help

# 测试安装（预览）
./init.sh --min --dry-run

# 实际安装
./init.sh --dev      # 开发完整（默认）
./init.sh --min      # 最小安装
./init.sh --full     # 全部安装

# 错误输入示例（显示简要用法）
./init.sh --wrong
```
