# 未来架构改进方向

> 本文档记录可能的架构优化方案，供未来参考。
> 当前不实施，仅作为设计思路和演进方向的记录。

---

## 背景

当前 dotfiles 架构在功能上已经满足需求，但从软件工程角度看，仍有改进空间：

- **开闭原则 (OCP)**：添加新安装场景需要修改核心代码
- **单一职责 (SRP)**：某些模块承担过多职责
- **耦合度**：模块间存在隐式依赖
- **可测试性**：缺乏抽象层，难以单元测试

---

## 方案一：分层架构 + 插件化

### 核心思想

采用经典的分层架构，通过依赖注入和策略模式实现可扩展的安装系统。

### 目录结构

```
dotfiles/
├── config/
│   ├── packages.yaml       # 声明式配置（What）
│   └── presets.yaml        # Preset 定义
├── lib/
│   ├── core/               # 领域层
│   │   ├── package.lua     # Package 实体
│   │   ├── installer.lua   # 安装器接口
│   │   └── checker.lua     # 检查器接口
│   ├── infrastructure/     # 基础设施层
│   │   ├── apt.lua         # Apt 安装器
│   │   ├── pip.lua         # Pip 安装器
│   │   ├── tarball.lua     # 二进制安装器
│   │   └── github.lua      # GitHub release 安装器
│   └── application/        # 应用层
│       ├── install.lua     # 安装服务
│       ├── check.lua       # 检查服务
│       └── preset.lua      # Preset 解析
└── init.lua                # 入口（依赖注入）
```

### 核心设计

```lua
-- lib/core/installer.lua
local Installer = {}
Installer.__index = Installer

function Installer:new(config)
  -- 策略模式：根据配置返回不同安装器
  if config.type == "apt" then
    return AptInstaller:new(config)
  elseif config.type == "pip" then
    return PipInstaller:new(config)
  elseif config.type == "github" then
    return GitHubInstaller:new(config)
  end
end

-- 具体实现符合开闭原则
local AptInstaller = setmetatable({}, {__index = Installer})
function AptInstaller:install()
  return spawn.apt({ "install", "-y", self.config.name })
end
```

### Preset 配置化

```yaml
# config/presets.yaml
presets:
  minimal:
    extends: []
    packages:
      - core.curl
      - core.wget
      - editors.nvim
      
  dev:
    extends: [minimal]  # 继承
    packages:
      - dev-tools.go
      - dev-tools.rust
      - system.tmux
      
  web:
    extends: [dev]      # 组合
    packages:
      - optional.nvm
      - optional.node
```

### 优点

- ✅ **开闭原则**：新安装方式 = 新 Installer 类，不修改核心
- ✅ **单一职责**：每个 Installer 只处理一种安装方式
- ✅ **可测试**：接口清晰，可 Mock 测试
- ✅ **可扩展**：插件化架构，社区可贡献新 Installer

### 缺点

- 架构复杂度高
- 需要学习成本
- 对当前规模可能过度设计

---

## 方案二：Unix 哲学 - 单一职责工具链

### 核心思想

不做大而全的 init.sh，拆分为独立、可组合的小工具。

### 目录结构

```
bin/
├── dot-check              # 检查状态（只做检查）
├── dot-install            # 执行安装（只做安装）
├── dot-status             # 显示状态（只读）
└── dot-doctor             # 诊断修复

lib/
├── checkers/              # 每个 checker 独立
│   ├── apt.lua
│   ├── pip.lua
│   └── binary.lua
└── installers/            # 每个 installer 独立
    ├── apt.lua
    ├── pip.lua
    └── github.lua
```

### 使用方式

```bash
# 检查但不安装
dot-check

# 只看 nvim 相关
dot-check --filter nvim

# 只安装缺失的
dot-install --missing-only

# 修复特定问题
dot-doctor --fix python3-venv

# 组合使用
dot-check | dot-install --from-stdin
```

### 优点

- ✅ **Unix 哲学**：Do one thing and do it well
- ✅ **可组合**：管道组合，灵活使用
- ✅ **可测试**：每个工具独立测试
- ✅ **简单**：没有复杂架构，直接了当

### 缺点

- 学习成本（需记忆多个命令）
- 组合逻辑复杂时难以维护
- 状态共享困难

---

## 方案三：声明式 + 幂等（Infrastructure as Code）

### 核心思想

像 Ansible/Terraform 那样，声明期望状态，工具自动同步。

### 配置示例

```yaml
# config/desired-state.yaml
system:
  - name: curl
    state: present    # 确保安装
    version: ">=7.0"
    
  - name: python3-venv
    state: present
    
  - name: go
    state: present
    version: ">=1.23.0"
    source: 
      type: github_release
      repo: golang/go
      asset_pattern: "go{{version}}.linux-amd64.tar.gz"

  - name: old-tool
    state: absent     # 确保卸载
```

### 执行逻辑

```lua
-- 读取期望状态
local desired = load_config("config/desired-state.yaml")

-- 读取当前状态
local current = check_all()

-- 计算差异 (类似 Terraform plan)
local diff = calculate_diff(desired, current)

-- 应用差异（幂等）
apply_diff(diff)  -- 多次执行结果相同
```

### 使用方式

```bash
# 查看将做什么（类似 terraform plan）
./init.sh --plan

# 应用变更
./init.sh --apply

# 不确认直接应用
./init.sh --apply --auto-approve

# 检查漂移（实际状态 vs 期望状态）
./init.sh --drift
```

### 优点

- ✅ **声明式**：只关心 What，不关心 How
- ✅ **幂等**：多次执行结果一致，安全可靠
- ✅ **可审计**：状态变更可追溯
- ✅ **自文档化**：配置文件即文档

### 缺点

- 实现复杂度高
- 需要维护状态（或每次扫描）
- 学习曲线陡峭
- 可能过度设计

---

## 方案对比

| 维度 | 方案一：分层架构 | 方案二：Unix工具链 | 方案三：声明式 |
|------|-----------------|-------------------|---------------|
| **开闭原则** | ⭐⭐⭐ 极好 | ⭐⭐ 好 | ⭐⭐⭐ 极好 |
| **复杂度** | 中等 | 低 | 高 |
| **学习成本** | 中 | 低 | 高 |
| **灵活性** | 高 | 高 | 极高 |
| **实现难度** | 中等 | 低 | 高 |
| **测试性** | 好 | 极好 | 好 |
| **适用场景** | 大型项目/团队协作 | 简单需求/个人使用 | 复杂环境管理 |

---

## 演进路径建议

### 阶段 1：现状（当前）

```
modules/*.sh  →  顺序执行
profile.sh    →  配置哪些模块
```

### 阶段 2：简单改进（近期可考虑）

```
init.sh
  ├── check()   # 检查状态
  ├── plan()    # 计算需要做什么
  └── apply()   # 执行安装
```

不改动架构，只增加内部函数。

### 阶段 3：子命令化（未来）

```
./init.sh check   # 只检查
./init.sh plan    # 显示计划
./init.sh apply   # 执行安装
```

CLI 接口改进，内部仍可用 shell。

### 阶段 4：架构重构（远期）

根据实际需求选择：
- **个人使用** → 方案二（Unix 工具链）
- **团队协作** → 方案一（分层架构）
- **复杂环境** → 方案三（声明式）

---

## 决策参考

### 何时考虑这些方案？

**立即做**（保持现状）：
- 当前系统工作正常
- 没有扩展需求
- 个人使用为主

**短期考虑**（阶段 2-3）：
- 频繁在新机器上初始化
- 需要更清晰的调试/诊断能力
- 想支持部分安装/检查

**长期考虑**（阶段 4）：
- 多人协作维护 dotfiles
- 需要支持多种 OS/环境
- 想成为开源项目供他人使用

### 当前建议

**暂不实施任何架构重构**，原因：

1. **当前规模**：23 个模块不算多，维护成本可控
2. **个人使用**：不需要复杂的团队协作功能
3. **工作正常**：现有架构满足需求，改动风险大于收益
4. **优先级**：功能完善 > 架构优雅

**记录本文档的目的**：

- 为未来可能的需求变化预留设计思路
- 当现有架构成为瓶颈时，有明确的演进方向
- 避免重复思考已讨论过的问题

---

## 附录：参考项目

### 优秀案例

1. **Homebrew**（方案二风格）
   - `brew install`、`brew doctor`、`brew cleanup`
   - 单一职责，可组合

2. **Ansible**（方案三风格）
   - 声明式配置
   - 幂等执行

3. **Terraform**（方案三风格）
   - plan/apply 工作流
   - 状态管理

4. **Stow**（极简 Unix 风格）
   - 只做一件事：符号链接管理

### 反模式警示

- ❌ **过度工程**：小项目用复杂架构
- ❌ **过早优化**：没有痛点就重构
- ❌ **大 rewrite**：一次性全部重写

---

**最后更新**：2026-02-23
**状态**：设计文档，暂不实施
