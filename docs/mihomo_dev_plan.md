# mihomo 安装与 CLI 使用文档开发计划

目标：在 dotfiles 中集成 mihomo 代理工具，并更新 CLI 使用文档说明如何配置节点。

## 1. 安装 mihomo

### 1.1 下载 mihomo 二进制

- 从官方 releases 下载对应平台的二进制文件
- 验证 sha256sum 签名

### 1.2 安装脚本

在 `scripts/` 目录下创建 `install_mihomo.sh`：

```bash
#!/bin/bash
# 安装 mihomo 到 ~/.local/bin 或系统路径
```

### 1.3 配置目录

- 创建 `config/mihomo/` 目录
- 放置 `config.yaml` 配置文件

## 2. 配置节点

### 2.1 配置文件结构

在 `config/mihomo/config.yaml` 中配置：

- `proxies`: 代理节点列表
- `proxy-groups`: 代理组
- `rules`: 规则配置
- `listen`: 监听地址

### 2.2 节点来源

- 订阅链接（URL）
- 本地 YAML/JSON 配置
- 手动添加

## 3. CLI 使用文档

在 `docs/` 目录下创建 `mihomo_usage.md`：

### 3.1 常用命令

- 启动 mihomo：`mihomo -f config.yaml`
- 后台运行：`mihomo -f config.yaml -d .`
- 停止：发送 SIGTERM 信号
- 测试节点：`mihomo test` 或手动 curl 检测

### 3.2 配置示例

```bash
# 启动代理
mihomo -f ~/.config/mihomo/config.yaml

# 指定工作目录
mihomo -f ~/.config/mihomo/config.yaml -d ~/.config/mihomo

# 查看帮助
mihomo --help
```

### 3.3 注意事项

- 端口冲突检测
- 日志查看
- 自动重启配置

## 4. 任务清单

- [ ] 创建 `scripts/install_mihomo.sh`
- [ ] 创建 `config/mihomo/config.yaml` 模板
- [ ] 创建 `docs/mihomo_usage.md` 使用文档
- [ ] 在 `init.sh` 中集成 mihomo 安装（可选）
