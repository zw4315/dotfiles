#!/usr/bin/env bash

ensure_ctags() {
  command -v ctags >/dev/null 2>&1 && { log "✅ ctags: already installed"; return 0; }

  log "📦 ctags: installing (apt universal-ctags)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd ctags universal-ctags
  log "✅ ctags: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  ctags disabled"; return 0; }
  ensure_ctags
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
