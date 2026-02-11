#!/usr/bin/env bash

ensure_curl() {
  command -v curl >/dev/null 2>&1 && { log "✅ curl: already installed"; return 0; }

  log "📦 curl: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd curl curl
  log "✅ curl: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  curl disabled"; return 0; }
  ensure_curl
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
