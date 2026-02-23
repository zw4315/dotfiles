#!/usr/bin/env bash
# 00-core.sh - 基础依赖模块
# 安装核心工具：curl, wget, unzip
# 这些是所有预设都需要的基础依赖

ensure_curl() {
  command -v curl >/dev/null 2>&1 && { log "✅ curl: already installed"; return 0; }

  log "📦 curl: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd curl curl
  log "✅ curl: installed"
}

ensure_wget() {
  command -v wget >/dev/null 2>&1 && { log "✅ wget: already installed"; return 0; }

  log "📦 wget: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd wget wget
  log "✅ wget: installed"
}

ensure_unzip() {
  command -v unzip >/dev/null 2>&1 && { log "✅ unzip: already installed"; return 0; }

  log "📦 unzip: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd unzip unzip
  log "✅ unzip: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  core disabled"; return 0; }

  log "🔧 Installing core dependencies..."
  ensure_curl
  ensure_wget
  ensure_unzip
  log "✅ Core dependencies installed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
