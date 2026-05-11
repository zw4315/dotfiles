#!/usr/bin/env bash

ensure_zoxide() {
  command -v zoxide >/dev/null 2>&1 && { log "✅ zoxide: already installed"; return 0; }

  log "📦 zoxide: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd zoxide zoxide
  log "✅ zoxide: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  zoxide disabled"; return 0; }
  ensure_zoxide
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
