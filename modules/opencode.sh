#!/usr/bin/env bash

ensure_opencode() {
  if command -v opencode >/dev/null 2>&1; then
    log "✅ opencode: already installed"
    return 0
  fi

  log "📦 opencode: installing via https://opencode.ai/install"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: curl -fsSL https://opencode.ai/install | bash"
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- https://opencode.ai/install | bash -s -- --no-modify-path
  else
    die "Need curl or wget to install opencode"
  fi

  # 安装后需要更新 PATH 才能找到 opencode
  export PATH="$HOME/.opencode/bin:$PATH"
  command -v opencode >/dev/null 2>&1 || die "opencode install failed"
  log "✅ opencode: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  opencode disabled"; return 0; }
  ensure_opencode
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
