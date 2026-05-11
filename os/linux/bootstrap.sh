#!/usr/bin/env bash
# =============================================================================
# Linux 首次引导脚本
# =============================================================================
# 在全新 Linux 系统上运行一次，安装基础依赖。
# =============================================================================

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=/dev/null
source "$DOTFILES/lib/common.sh"
# shellcheck source=/dev/null
source "$DOTFILES/lib/linux.sh"

log "Bootstrapping Linux environment..."

# 创建必要的目录
ensure_dir "$HOME/.config"
ensure_dir "$HOME/.local/bin"

# 更新包列表（apt 系统）
case "$PKG_MANAGER" in
  apt)
    sudo apt-get update
    ;;
esac

log_success "Linux bootstrap complete!"
