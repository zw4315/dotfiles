#!/usr/bin/env bash

ensure_rg() {
  command -v rg >/dev/null 2>&1 && { log "✅ rg: already installed"; return 0; }

  log "📦 rg: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd rg ripgrep
  log "✅ rg: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  rg disabled"; return 0; }
  ensure_rg
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
