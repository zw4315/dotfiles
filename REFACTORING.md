# 重构总结

## 变更概述

按照 PLAN.md 完成了 dotfiles 安装系统的重构。

### 模块重构

**重构前**: 23 个独立模块  
**重构后**: 6 个核心模块 + 10 个子模块

| 新模块 | 包含内容 | 说明 |
|--------|----------|------|
| 00-core.sh | curl, wget, unzip | 基础依赖 |
| 10-dev-tools.sh | python3-pip, python3-venv, go | 开发依赖 |
| 20-editors.sh | vim, nvim, treesitter_cli | 编辑器配置 |
| 30-dev-env.sh | git, lazygit, rg, fd, ctags, global, clang_format | 开发工具链 |
| 40-system.sh | bash, tmux, zoxide, scripts | 系统工具 |
| 50-optional.sh | rust, nvm, opencode, mihomo | 可选组件 |

### CLI 接口

新增渐进式披露的帮助系统：

```bash
./init.sh --help     # 完整帮助
./init.sh --min      # 最小安装
./init.sh --dev      # 开发完整（默认）
./init.sh --full     # 全部安装
```

错误输入显示简要用法：
```bash
./init.sh --wrong
# Error: Unknown flag '--wrong'
# Usage: ./init.sh [PRESET] [options]
# ...
```

### 依赖关系

通过文件名数字前缀确保执行顺序：
- 00-core 最先执行
- 50-optional 最后执行
- 子模块由主模块调用

### 收益

- **配置简化**: 从 23 行减少到 1 个参数
- **依赖清晰**: 通过文件名数字顺序
- **向后兼容**: 保留子模块调用方式
- **渐进式披露**: 错误输入显示简要帮助

## 测试验证

```bash
# 测试通过
./init.sh --help              # 显示完整帮助
./init.sh --min --dry-run     # minimal 预设 ✓
./init.sh --dev --dry-run     # dev 预设 ✓
./init.sh --full --dry-run    # full 预设 ✓
./init.sh --wrong             # 错误处理 ✓
```

## 后续建议

1. **YAML 软件清单**: 可考虑添加 config/packages.yaml 定义软件元数据
2. **状态检查**: 可实现 `./init.sh --status` 查看安装状态
3. **并行安装**: 如需要可实施阶段三的并行化

详见 PLAN.md 和 FUTURE.md
