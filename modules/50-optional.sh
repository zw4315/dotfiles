#!/usr/bin/env bash
# 50-optional.sh - 可选组件模块
# 安装可选工具：rust, nvm, opencode, mihomo

# Rust + rustup
ensure_rust() {
  # 检查 rustup
  if command -v rustup >/dev/null 2>&1 || [[ -x "$HOME/.cargo/bin/rustup" ]]; then
    log "✅ rustup: already installed"
  else
    log "📦 rustup: installing"
    # shellcheck source=/dev/null
    source "${DOTFILES:?}/modules/rustup.sh"
    module_main 1
  fi

  # 配置 rust 环境
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/rust.sh"
  module_main 1
}

# NVM (Node Version Manager)
ensure_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    log "✅ nvm: already installed"
    return 0
  fi

  log "📦 nvm: installing"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/nvm.sh"
  module_main 1
}

# Opencode
ensure_opencode() {
  command -v opencode >/dev/null 2>&1 && { log "✅ opencode: already installed"; return 0; }

  log "📦 opencode: installing"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/opencode.sh"
  module_main 1
}

# Mihomo (代理工具)
ensure_mihomo() {
  command -v mihomo >/dev/null 2>&1 || command -v clash >/dev/null 2>&1 && { 
    log "✅ mihomo: already installed"
    return 0
  }

  log "📦 mihomo: installing"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/mihomo.sh"
  module_main 1
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  optional disabled"; return 0; }

  log "🔧 Installing optional components..."
  ensure_rust
  ensure_nvm
  ensure_opencode
  ensure_mihomo
  log "✅ Optional components installed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
