#!/usr/bin/env bash
# =============================================================================
# macOS 首次引导脚本
# =============================================================================
# 在全新 macOS 系统上运行一次，安装基础依赖。
# =============================================================================

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=/dev/null
source "$DOTFILES/lib/common.sh"
# shellcheck source=/dev/null
source "$DOTFILES/lib/darwin.sh"

log "Bootstrapping macOS environment..."

# 1. 安装 Homebrew
ensure_brew

# 2. 安装 Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  log "Installing Xcode Command Line Tools..."
  xcode-select --install
  log_warn "Please complete the installation dialog, then re-run."
  exit 0
fi

# 3. 创建必要的目录
ensure_dir "$HOME/.config"
ensure_dir "$HOME/.local/bin"

# 4. 通过 Brewfile 安装基础软件（可选）
BREWFILE="$DOTFILES/os/darwin/Brewfile"
if [[ -f "$BREWFILE" ]]; then
  log "Installing packages from Brewfile..."
  brew bundle --file="$BREWFILE"
fi

log_success "macOS bootstrap complete!"
