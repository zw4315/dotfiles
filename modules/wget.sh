#!/usr/bin/env bash

ensure_wget() {
  command -v wget >/dev/null 2>&1 && { log "✅ wget: already installed"; return 0; }

  log "📦 wget: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd wget wget
  log "✅ wget: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  wget disabled"; return 0; }
  ensure_wget
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
